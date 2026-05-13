import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import EisenNotion 1.0

Window {
    id: taskDialog
    width: 480
    height: 500
    color: "transparent"
    flags: Qt.Dialog | Qt.FramelessWindowHint
    modality: Qt.ApplicationModal

    property string editingTaskId: ""
    property date selectedDate: new Date()
    property int currentMonth: selectedDate.getMonth()
    property int currentYear: selectedDate.getFullYear()

    function daysInMonth(year, month) { return new Date(year, month + 1, 0).getDate() }
    function firstDayOfWeek(year, month) { return new Date(year, month, 1).getDay() }

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

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 8

                    Text {
                        text: editingTaskId ? "Редактировать задачу" : "Новая задача"
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
                        onClicked: {
                            clearFields()
                            taskDialog.close()
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    property real lastMouseX: 0
                    property real lastMouseY: 0
                    onPressed: {
                        lastMouseX = mouseX
                        lastMouseY = mouseY
                    }
                    onPositionChanged: {
                        var deltaX = mouseX - lastMouseX
                        var deltaY = mouseY - lastMouseY
                        taskDialog.x += deltaX
                        taskDialog.y += deltaY
                    }
                }
            }

            // Тело диалога
            ColumnLayout {
                Layout.fillWidth: true
                Layout.margins: 16
                spacing: 14

                TextField {
                    id: titleField
                    placeholderText: "Название задачи"
                    Layout.fillWidth: true
                    font.pixelSize: 14
                    color: "#2C3E50"
                    placeholderTextColor: "#95A5A6"
                    background: Rectangle {
                        radius: 6
                        color: "#F7F9FB"
                        border.color: "#D5DCE3"
                    }
                }

                TextArea {
                    id: descField
                    placeholderText: "Описание (можно Markdown)"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80
                    font.pixelSize: 13
                    color: "#2C3E50"
                    placeholderTextColor: "#95A5A6"
                    background: Rectangle {
                        radius: 6
                        color: "#F7F9FB"
                        border.color: "#D5DCE3"
                    }
                }

                // Комбобокс важности
                ComboBox {
                    id: quadrantBox
                    model: ["Без категории (входящие)", "Срочно-важно", "Срочно-неважно", "Несрочно-важно", "Несрочно-неважно"]
                    currentIndex: 0
                    font.pixelSize: 13
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36

                    delegate: ItemDelegate {
                        width: parent.width
                        text: modelData
                        font.pixelSize: 13
                        highlighted: parent.highlightedIndex === index
                        background: Rectangle {
                            color: highlighted ? "#3498DB" : "transparent"
                            radius: 4
                        }
                        contentItem: Text {
                            text: modelData
                            font: parent.font
                            color: highlighted ? "white" : "#2C3E50"
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    background: Rectangle {
                        radius: 6
                        color: "#F7F9FB"
                        border.color: "#D5DCE3"
                    }

                    indicator: Text {
                        text: "▼"
                        font.pixelSize: 10
                        color: "#7F8C8D"
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                // Дата и время
                RowLayout {
                    Text {
                        text: "Дата и время:"
                        font.pixelSize: 13
                        color: "#2C3E50"
                    }

                    Button {
                        id: dateButton
                        text: selectedDate.toLocaleDateString(Qt.locale(), "dd.MM.yyyy")
                        font.pixelSize: 13
                        palette { buttonText: "#2C3E50" }
                        onClicked: calendarPopup.open()
                        background: Rectangle {
                            radius: 6
                            color: "#F7F9FB"
                            border.color: "#D5DCE3"
                        }
                    }

                    TextField {
                        id: timeField
                        placeholderText: "12:00"
                        inputMask: "00:00"
                        font.pixelSize: 13
                        color: "#2C3E50"
                        placeholderTextColor: "#95A5A6"
                        Layout.preferredWidth: 70
                        text: "12:00"
                        validator: RegularExpressionValidator { regularExpression: /^(0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]$/ }
                        background: Rectangle {
                            radius: 6
                            color: "#F7F9FB"
                            border.color: "#D5DCE3"
                        }
                    }
                }

                // Всплывающий календарь с белым фоном
                Popup {
                    id: calendarPopup
                    width: 280
                    height: 280
                    modal: true
                    closePolicy: Popup.CloseOnPressOutside | Popup.CloseOnEscape
                    x: dateButton.x
                    y: dateButton.y + dateButton.height

                    background: Rectangle {
                        color: "#FFFFFF"
                        radius: 8
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 4
                        RowLayout {
                            Button { text: "<"; onClicked: { if (currentMonth === 0) { currentMonth = 11; currentYear-- } else { currentMonth-- } } }
                            Label {
                                text: new Date(currentYear, currentMonth).toLocaleDateString(Qt.locale(), "MMMM yyyy")
                                font.pixelSize: 14; Layout.fillWidth: true; horizontalAlignment: Text.AlignHCenter
                                color: "#2C3E50"
                            }
                            Button { text: ">"; onClicked: { if (currentMonth === 11) { currentMonth = 0; currentYear++ } else { currentMonth++ } } }
                        }
                        GridLayout {
                            columns: 7; Layout.fillWidth: true
                            Repeater { model: ["Пн","Вт","Ср","Чт","Пт","Сб","Вс"]; delegate: Label { text: modelData; font.pixelSize: 11; horizontalAlignment: Text.AlignHCenter; color: "#7F8C8D" } }
                        }
                        GridLayout {
                            id: daysGrid; columns: 7; Layout.fillWidth: true
                            Repeater {
                                model: {
                                    var days = []; var firstDay = firstDayOfWeek(currentYear, currentMonth)
                                    var startOffset = (firstDay + 6) % 7
                                    for (var i = 0; i < startOffset; i++) days.push(0)
                                    var total = daysInMonth(currentYear, currentMonth)
                                    for (var d = 1; d <= total; d++) days.push(d)
                                    while (days.length % 7 !== 0) days.push(0)
                                    return days
                                }
                                delegate: Rectangle {
                                    width: 30; height: 30
                                    color: modelData === 0 ? "transparent" : (new Date(currentYear, currentMonth, modelData).toDateString() === selectedDate.toDateString() ? "#3498DB" : "transparent")
                                    radius: 4
                                    Label {
                                        anchors.centerIn: parent
                                        text: modelData !== 0 ? modelData : ""
                                        font.pixelSize: 12
                                        color: modelData !== 0 && new Date(currentYear, currentMonth, modelData).toDateString() === selectedDate.toDateString() ? "white" : "#2C3E50"
                                    }
                                    MouseArea { anchors.fill: parent; enabled: modelData !== 0; onClicked: { selectedDate = new Date(currentYear, currentMonth, modelData); calendarPopup.close() } }
                                }
                            }
                        }
                    }
                }

                TextField {
                    id: tagsField
                    placeholderText: "Теги через запятую"
                    Layout.fillWidth: true
                    font.pixelSize: 13
                    color: "#2C3E50"
                    placeholderTextColor: "#95A5A6"
                    background: Rectangle { radius: 6; color: "#F7F9FB"; border.color: "#D5DCE3" }
                }

                TextField {
                    id: projectField
                    placeholderText: "Проект"
                    Layout.fillWidth: true
                    font.pixelSize: 13
                    color: "#2C3E50"
                    placeholderTextColor: "#95A5A6"
                    background: Rectangle { radius: 6; color: "#F7F9FB"; border.color: "#D5DCE3" }
                }

                // Комбобокс повтора
                ComboBox {
                    id: recurrenceBox
                    model: ["Без повтора", "Ежедневно", "Еженедельно", "Ежемесячно", "Ежегодно", "По будням"]
                    currentIndex: 0
                    font.pixelSize: 13
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36

                    delegate: ItemDelegate {
                        width: parent.width
                        text: modelData
                        font.pixelSize: 13
                        highlighted: parent.highlightedIndex === index
                        background: Rectangle {
                            color: highlighted ? "#3498DB" : "transparent"
                            radius: 4
                        }
                        contentItem: Text {
                            text: modelData
                            font: parent.font
                            color: highlighted ? "white" : "#2C3E50"
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    background: Rectangle {
                        radius: 6
                        color: "#F7F9FB"
                        border.color: "#D5DCE3"
                    }

                    indicator: Text {
                        text: "▼"
                        font.pixelSize: 10
                        color: "#7F8C8D"
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                // Кнопки Отмена и Сохранить
                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 6
                    spacing: 12
                    Item { Layout.fillWidth: true }

                    Button {
                        text: "Отмена"
                        Layout.preferredWidth: 130
                        Layout.preferredHeight: 36
                        font.pixelSize: 13
                        palette {
                            button: "transparent"
                            buttonText: "#2C3E50"
                        }
                        background: Rectangle {
                            radius: 6
                            color: "transparent"
                            border.color: "#D5DCE3"
                            border.width: 1
                        }
                        onClicked: {
                            clearFields()
                            taskDialog.close()
                        }
                    }

                    Button {
                        text: "Сохранить"
                        Layout.preferredWidth: 130
                        Layout.preferredHeight: 36
                        font.pixelSize: 13
                        palette {
                            button: "#3498DB"
                            buttonText: "#FFFFFF"
                        }
                        background: Rectangle {
                            radius: 6
                            color: parent.palette.button
                        }
                        onClicked: accept()
                    }
                    Item { Layout.fillWidth: true }
                }
            }
        }
    }

    function accept() {
        var quadIndex = quadrantBox.currentIndex - 1
        var dateStr = selectedDate.toISOString().split('T')[0]
        var timeStr = timeField.text + ":00"
        var deadlineStr = dateStr + "T" + timeStr

        let taskObj = {
            title: titleField.text,
            description: descField.text,
            quadrant: quadIndex,
            deadline: deadlineStr,
            tags: tagsField.text.split(',').map(t => t.trim()).filter(t => t.length > 0),
            project: projectField.text,
            recurrenceRule: ["", "daily", "weekly", "monthly", "yearly", "weekdays"][recurrenceBox.currentIndex]
        };

        if (editingTaskId) {
            taskObj.id = editingTaskId;
            TaskManager.editTask(editingTaskId, taskObj);
        } else {
            TaskManager.addTask(taskObj);
        }
        clearFields();
        taskDialog.close()
    }

    function loadTask(task) {
        if (task) {
            editingTaskId = task.id;
            titleField.text = task.title || "";
            descField.text = task.description || "";
            var q = task.quadrant !== undefined ? task.quadrant : -1;
            quadrantBox.currentIndex = q + 1;

            if (task.deadline) {
                var dt = new Date(task.deadline);
                if (!isNaN(dt.getTime())) {
                    selectedDate = dt;
                    currentMonth = dt.getMonth();
                    currentYear = dt.getFullYear();
                    var hours = dt.getHours().toString().padStart(2, '0');
                    var minutes = dt.getMinutes().toString().padStart(2, '0');
                    timeField.text = hours + ":" + minutes;
                } else {
                    selectedDate = new Date();
                    currentMonth = selectedDate.getMonth();
                    currentYear = selectedDate.getFullYear();
                    timeField.text = "12:00";
                }
            } else {
                selectedDate = new Date();
                currentMonth = selectedDate.getMonth();
                currentYear = selectedDate.getFullYear();
                timeField.text = "12:00";
            }

            tagsField.text = task.tags ? task.tags.join(", ") : "";
            projectField.text = task.project || "";
            var rules = ["", "daily", "weekly", "monthly", "yearly", "weekdays"];
            var idx = rules.indexOf(task.recurrenceRule || "");
            recurrenceBox.currentIndex = idx >= 0 ? idx : 0;
            taskDialog.show();
        }
    }

    function clearFields() {
        editingTaskId = "";
        titleField.clear();
        descField.clear();
        quadrantBox.currentIndex = 0;
        selectedDate = new Date();
        currentMonth = selectedDate.getMonth();
        currentYear = selectedDate.getFullYear();
        timeField.text = "12:00";
        tagsField.clear();
        projectField.clear();
        recurrenceBox.currentIndex = 0;
    }
}