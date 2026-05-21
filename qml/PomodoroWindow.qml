import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import EisenNotion 1.0

Window {
    id: pomodoroWindow
    width: 500
    height: 400
    color: "transparent"
    flags: Qt.Dialog | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    modality: Qt.NonModal
    visible: false

    property string currentTaskTitle: ""
    property int remainingSeconds: 0
    property bool running: false
    property bool onBreak: false

    property int workDuration: TaskManager.pomodoroWorkDuration
    property int breakDuration: TaskManager.pomodoroBreakDuration
    property int totalSeconds: onBreak ? breakDuration * 60 : workDuration * 60

    Timer {
        id: countdownTimer
        interval: 1000
        repeat: true
        running: pomodoroWindow.running && pomodoroWindow.remainingSeconds > 0
        onTriggered: {
            pomodoroWindow.remainingSeconds--;
            if (pomodoroWindow.remainingSeconds <= 0) {
                TaskManager.playNotificationSound();
                var msg = pomodoroWindow.onBreak ? "Отдых завершён! Начинаем работу." : "Работа завершена! Время отдыха.";
                var comp = Qt.createComponent("qrc:/qml/NotificationPopup.qml");
                if (comp.status === Component.Ready) {
                    var popup = comp.createObject(pomodoroWindow, {"message": msg, "parentWindow": pomodoroWindow});
                    popup.show();
                }
                if (pomodoroWindow.onBreak) {
                    pomodoroWindow.onBreak = false;
                    pomodoroWindow.totalSeconds = pomodoroWindow.workDuration * 60;
                } else {
                    pomodoroWindow.onBreak = true;
                    pomodoroWindow.totalSeconds = pomodoroWindow.breakDuration * 60;
                }
                pomodoroWindow.remainingSeconds = pomodoroWindow.totalSeconds;
                pomodoroWindow.running = true;
            }
        }
    }

    Component.onCompleted: {
        var savedX = TaskManager.dialogX
        var savedY = TaskManager.dialogY
        if (savedX !== -1 && savedY !== -1) {
            x = savedX
            y = savedY
        } else {
            x = Screen.desktopAvailableWidth / 2 - width / 2
            y = Screen.desktopAvailableHeight / 2 - height / 2
        }
    }
    onXChanged: TaskManager.dialogX = x
    onYChanged: TaskManager.dialogY = y

    function startWork() {
        onBreak = false;
        totalSeconds = workDuration * 60;
        remainingSeconds = totalSeconds;
        running = true;
    }
    function startBreak() {
        onBreak = true;
        totalSeconds = breakDuration * 60;
        remainingSeconds = totalSeconds;
        running = true;
    }
    function stop() {
        running = false;
        remainingSeconds = 0;
    }
    function togglePause() {
        running = !running;
    }
    function startWithTask(task) {
        currentTaskTitle = task.title || "Без названия";
        startWork();
        pomodoroWindow.show();
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 4
        radius: 12
        color: "#FFFFFF"
        border.color: "#E0E4E8"
        border.width: 1

        Rectangle {
            anchors.fill: parent
            anchors.margins: -2
            radius: 14
            color: "transparent"
            border.color: "#18000000"
            border.width: 2
            z: -1
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // Заголовок
            Rectangle {
                Layout.fillWidth: true
                height: 40
                radius: 12
                color: "#F7F9FB"
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: 12
                    color: parent.color
                }

                MouseArea {
                    anchors.fill: parent
                    anchors.rightMargin: 35
                    property real lastMouseX: 0
                    property real lastMouseY: 0
                    onPressed: {
                        lastMouseX = mouseX
                        lastMouseY = mouseY
                    }
                    onPositionChanged: {
                        var deltaX = mouseX - lastMouseX
                        var deltaY = mouseY - lastMouseY
                        pomodoroWindow.x += deltaX
                        pomodoroWindow.y += deltaY
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 8

                    Text {
                        text: currentTaskTitle ? ("🍅 " + currentTaskTitle) : "🍅 Pomodoro"
                        font.pixelSize: 15
                        font.family: "Segoe UI"
                        color: "#2C3E50"
                        Layout.fillWidth: true
                    }
                    Button {
                        text: "✕"
                        flat: true
                        font.pixelSize: 16
                        palette { buttonText: "#95A5A6" }
                        z: 10
                        onClicked: pomodoroWindow.close()
                    }
                }
            }

            // Основная часть
            ColumnLayout {
                Layout.fillWidth: true
                Layout.margins: 16
                spacing: 14

                // Прогресс-бар
                Rectangle {
                    Layout.fillWidth: true
                    height: 8
                    radius: 4
                    color: "#E0E4E8"
                    Rectangle {
                        height: parent.height
                        radius: 4
                        color: onBreak ? "#2ECC71" : "#E74C3C"
                        width: parent.width * Math.min(1, (totalSeconds - remainingSeconds) / Math.max(1, totalSeconds))
                        Behavior on width { NumberAnimation { duration: 200 } }
                    }
                }

                // Таймер
                Text {
                    text: {
                        var mins = Math.floor(remainingSeconds / 60);
                        var secs = remainingSeconds % 60;
                        return ("0" + mins).slice(-2) + ":" + ("0" + secs).slice(-2);
                    }
                    font.pixelSize: 56
                    font.family: "Segoe UI"
                    font.bold: true
                    color: onBreak ? "#2ECC71" : "#E74C3C"
                    Layout.alignment: Qt.AlignHCenter
                }

                // Настройки длительности с кнопками – и +
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Text {
                        text: "Работа (мин):"
                        font.pixelSize: 13
                        font.family: "Segoe UI"
                        font.bold: true
                        color: "#1a237e"
                    }

                    Button {
                        text: "–"
                        font.pixelSize: 14
                        font.bold: true
                        palette { buttonText: "#1a237e" }
                        background: Rectangle {
                            radius: 6
                            color: "transparent"
                            border.color: "#3f51b5"
                            border.width: 1
                        }
                        implicitWidth: 30
                        implicitHeight: 30
                        onClicked: {
                            if (workDuration > 1) {
                                workDuration--;
                                TaskManager.pomodoroWorkDuration = workDuration;
                                if (!onBreak && !running) {
                                    totalSeconds = workDuration * 60;
                                    remainingSeconds = 0;
                                }
                            }
                        }
                    }

                    Text {
                        text: workDuration
                        font.pixelSize: 14
                        font.family: "Segoe UI"
                        font.bold: true
                        color: "#1a237e"
                        horizontalAlignment: Text.AlignHCenter
                        Layout.preferredWidth: 40
                    }

                    Button {
                        text: "+"
                        font.pixelSize: 14
                        font.bold: true
                        palette { buttonText: "#1a237e" }
                        background: Rectangle {
                            radius: 6
                            color: "transparent"
                            border.color: "#3f51b5"
                            border.width: 1
                        }
                        implicitWidth: 30
                        implicitHeight: 30
                        onClicked: {
                            if (workDuration < 120) {
                                workDuration++;
                                TaskManager.pomodoroWorkDuration = workDuration;
                                if (!onBreak && !running) {
                                    totalSeconds = workDuration * 60;
                                    remainingSeconds = 0;
                                }
                            }
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: "Отдых (мин):"
                        font.pixelSize: 13
                        font.family: "Segoe UI"
                        font.bold: true
                        color: "#1a237e"
                    }

                    Button {
                        text: "–"
                        font.pixelSize: 14
                        font.bold: true
                        palette { buttonText: "#1a237e" }
                        background: Rectangle {
                            radius: 6
                            color: "transparent"
                            border.color: "#3f51b5"
                            border.width: 1
                        }
                        implicitWidth: 30
                        implicitHeight: 30
                        onClicked: {
                            if (breakDuration > 1) {
                                breakDuration--;
                                TaskManager.pomodoroBreakDuration = breakDuration;
                                if (onBreak && !running) {
                                    totalSeconds = breakDuration * 60;
                                    remainingSeconds = 0;
                                }
                            }
                        }
                    }

                    Text {
                        text: breakDuration
                        font.pixelSize: 14
                        font.family: "Segoe UI"
                        font.bold: true
                        color: "#1a237e"
                        horizontalAlignment: Text.AlignHCenter
                        Layout.preferredWidth: 40
                    }

                    Button {
                        text: "+"
                        font.pixelSize: 14
                        font.bold: true
                        palette { buttonText: "#1a237e" }
                        background: Rectangle {
                            radius: 6
                            color: "transparent"
                            border.color: "#3f51b5"
                            border.width: 1
                        }
                        implicitWidth: 30
                        implicitHeight: 30
                        onClicked: {
                            if (breakDuration < 60) {
                                breakDuration++;
                                TaskManager.pomodoroBreakDuration = breakDuration;
                                if (onBreak && !running) {
                                    totalSeconds = breakDuration * 60;
                                    remainingSeconds = 0;
                                }
                            }
                        }
                    }
                }

                // Кнопки управления
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Button {
                        text: running ? "⏸" : "▶"
                        Layout.fillWidth: true
                        Layout.preferredHeight: 44
                        font.pixelSize: 18
                        font.bold: true
                        palette {
                            button: running ? "#F39C12" : "#3498DB"
                            buttonText: "#FFFFFF"
                        }
                        background: Rectangle {
                            radius: 8
                            color: parent.palette.button
                        }
                        onClicked: {
                            if (remainingSeconds <= 0 && !running) {
                                if (onBreak) startBreak();
                                else startWork();
                            } else {
                                togglePause();
                            }
                        }
                    }

                    Button {
                        text: "⏹"
                        Layout.fillWidth: true
                        Layout.preferredHeight: 44
                        font.pixelSize: 18
                        font.bold: true
                        palette { button: "#E74C3C"; buttonText: "#FFFFFF" }
                        background: Rectangle {
                            radius: 8
                            color: parent.palette.button
                        }
                        onClicked: stop()
                    }
                }

                // Переключатели режимов
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Button {
                        text: "🍅 Работа"
                        Layout.fillWidth: true
                        flat: true
                        highlighted: !onBreak
                        palette { buttonText: "#1a237e" }
                        font.bold: true
                        font.family: "Segoe UI"
                        onClicked: { stop(); startWork(); }
                    }
                    Button {
                        text: "☕ Отдых"
                        Layout.fillWidth: true
                        flat: true
                        highlighted: onBreak
                        palette { buttonText: "#1a237e" }
                        font.bold: true
                        font.family: "Segoe UI"
                        onClicked: { stop(); startBreak(); }
                    }
                }
            }
        }
    }
}