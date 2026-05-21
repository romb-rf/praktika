import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import EisenNotion 1.0

Item {
    id: root
    property string viewMode: "week"
    property date currentDate: new Date()

    property var monthNames: [
        "Январь", "Февраль", "Март", "Апрель", "Май", "Июнь",
        "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"
    ]

    property int refreshCounter: 0

    Connections {
        target: TaskManager
        function onDataChanged() {
            refreshCounter++;
            if (selectedDay) selectedDayTasks = tasksForDate(selectedDay);
        }
    }

    function formatDateShort(d) { return d.getDate() + " " + monthNames[d.getMonth()].substring(0, 3) + "." }
    function formatMonthYear(d) { return monthNames[d.getMonth()] + " " + d.getFullYear() }

    // Модель календаря из C++, теперь передаём локальную дату
       property var cellModel: {
           var _ = refreshCounter;
           var year = currentDate.getFullYear();
           var month = ("0" + (currentDate.getMonth() + 1)).slice(-2);
           var day = ("0" + currentDate.getDate()).slice(-2);
           var iso = year + "-" + month + "-" + day;
           return JSON.parse(JSON.stringify(TaskManager.calendarModel(viewMode, iso)));
       }
    function tasksForDate(date) {
        if (!date || isNaN(date.getTime())) return [];
        var key = date.toISOString().split('T')[0];
        for (var i = 0; i < cellModel.length; i++) {
            var cell = cellModel[i];
            if (cell.dateStr === key) {
                return cell.tasks;
            }
        }
        return [];
    }

    function quadrantColor(q) {
        switch (q) {
            case 0: return "#E74C3C";
            case 1: return "#F39C12";
            case 2: return "#2ECC71";
            default: return "#95A5A6";
        }
    }

    property date selectedDay: new Date()
    property var selectedDayTasks: []

    ColumnLayout {
        anchors.fill: parent
        spacing: 8

        // Навигация
        Rectangle {
            Layout.fillWidth: true
            height: 36
            radius: 8
            color: "#F7F9FB"
            border.color: "#D5DCE3"

            RowLayout {
                anchors.fill: parent
                anchors.margins: 4
                spacing: 4

                Button {
                    text: "<"
                    flat: true
                    font.pixelSize: 14
                    palette { buttonText: "#2C3E50" }
                    background: Rectangle {
                        radius: 4; color: "transparent"
                        border.color: "#2C3E50"; border.width: 1
                    }
                    implicitWidth: 30; implicitHeight: 30
                    onClicked: {
                        if (viewMode === "week") currentDate = new Date(currentDate.getFullYear(), currentDate.getMonth(), currentDate.getDate() - 7);
                        else currentDate = new Date(currentDate.getFullYear(), currentDate.getMonth() - 1, 1);
                    }
                }

                Text {
                    text: {
                        if (viewMode === "week") {
                            if (cellModel.length >= 7) {
                                var start = new Date(cellModel[0].dateStr);
                                var end = new Date(cellModel[6].dateStr);
                                return formatDateShort(start) + " – " + formatDateShort(end) + " " + end.getFullYear();
                            }
                            return "";
                        } else {
                            return formatMonthYear(currentDate);
                        }
                    }
                    font.bold: true; font.pixelSize: 14; Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter; color: "#2C3E50"
                }

                Button {
                    text: ">"
                    flat: true
                    font.pixelSize: 14
                    palette { buttonText: "#2C3E50" }
                    background: Rectangle {
                        radius: 4; color: "transparent"
                        border.color: "#2C3E50"; border.width: 1
                    }
                    implicitWidth: 30; implicitHeight: 30
                    onClicked: {
                        if (viewMode === "week") currentDate = new Date(currentDate.getFullYear(), currentDate.getMonth(), currentDate.getDate() + 7);
                        else currentDate = new Date(currentDate.getFullYear(), currentDate.getMonth() + 1, 1);
                    }
                }
            }
        }

        // Кнопки режимов
        RowLayout {
            Layout.fillWidth: true
            spacing: 6
            Button {
                text: "Неделя"; highlighted: viewMode === "week"; flat: true
                background: Rectangle {
                    radius: 6; color: parent.highlighted ? "#3f51b5" : "transparent"
                    border.color: "#3f51b5"; border.width: 1
                }
                contentItem: Text {
                    text: parent.text; font: parent.font
                    color: parent.highlighted ? "#FFFFFF" : "#1a237e"
                    horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                }
                onClicked: viewMode = "week"
            }
            Button {
                text: "Месяц"; highlighted: viewMode === "month"; flat: true
                background: Rectangle {
                    radius: 6; color: parent.highlighted ? "#3f51b5" : "transparent"
                    border.color: "#3f51b5"; border.width: 1
                }
                contentItem: Text {
                    text: parent.text; font: parent.font
                    color: parent.highlighted ? "#FFFFFF" : "#1a237e"
                    horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                }
                onClicked: viewMode = "month"
            }
        }

        // Основная область
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                Loader {
                    anchors.fill: parent
                    active: viewMode === "week"
                    sourceComponent: weekView
                }
                Loader {
                    anchors.fill: parent
                    active: viewMode === "month"
                    sourceComponent: monthView
                }
            }

            // Боковая панель задач
            Rectangle {
                Layout.preferredWidth: 160
                Layout.fillHeight: true
                color: "#F7F9FB"
                radius: 8
                border.color: "#D5DCE3"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 6

                    Text {
                        text: selectedDay ? ("Задачи на " + formatDateShort(selectedDay) + " " + selectedDay.getFullYear()) : ""
                        font.bold: true; font.pixelSize: 13; font.family: "Segoe UI"; color: "#2C3E50"
                        Layout.fillWidth: true
                    }

                    Button {
                        text: "+ Новая задача"
                        Layout.fillWidth: true; font.pixelSize: 12; font.family: "Segoe UI"; font.bold: true
                        palette { button: "#3498DB"; buttonText: "#FFFFFF" }
                        background: Rectangle { radius: 6; color: parent.palette.button }
                        onClicked: taskDialog.showForDate(selectedDay)
                    }

                    ListView {
                        id: dayTaskList
                        Layout.fillWidth: true; Layout.fillHeight: true; clip: true; spacing: 4
                        model: selectedDayTasks
                        delegate: Rectangle {
                            width: parent.width; height: 32; color: "white"; radius: 6; border.color: "#E0E4E8"
                            RowLayout {
                                anchors.fill: parent; anchors.margins: 6; spacing: 6
                                Rectangle { width: 4; height: parent.height - 12; color: quadrantColor(modelData.quadrant); radius: 2 }
                                Text {
                                    text: modelData.title; font.pixelSize: 12; font.family: "Segoe UI"; font.bold: true
                                    color: "#1a237e"; elide: Text.ElideRight; Layout.fillWidth: true
                                }
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: taskDialog.loadTask(modelData)
                            }
                        }
                    }
                }
            }
        }
    }

    // ---------- Делегат дня (универсальный для недели и месяца) ----------
    Component {
        id: dayDelegate
        Rectangle {
            id: dayCell
            property bool hasDay: modelData && modelData.day > 0
            property var tasks: hasDay ? modelData.tasks : []
            property string dateStr: hasDay ? modelData.dateStr : ""
            property bool isToday: hasDay && modelData.isToday
            property int maxVisible: 3

            // Размеры: ширина – fill, высота – для недели 100, для месяца квадрат
            Layout.fillWidth: true
            Layout.preferredHeight: root.viewMode === "week" ? 100 : width
            color: hasDay ? "white" : "transparent"
            border.color: hasDay ? "#E0E4E8" : "transparent"
            radius: 6

            Rectangle {
                anchors.fill: parent; radius: 6; z: -1
                color: isToday ? "#EBF5FF" : "transparent"
            }

            Column {
                anchors.fill: parent; anchors.margins: 4; spacing: 2
                visible: hasDay

                Text {
                    text: hasDay ? modelData.day : ""
                    font.bold: true; font.pixelSize: 14; font.family: "Segoe UI"
                    color: isToday ? "#3f51b5" : "#2C3E50"
                }

                Item {
                    width: parent.width
                    height: parent.height - 22
                    clip: true

                    Column {
                        width: parent.width
                        spacing: 1

                        Repeater {
                            model: Math.min(tasks.length, maxVisible)
                            delegate: Rectangle {
                                width: parent.width - 8
                                height: 16
                                color: "transparent"
                                RowLayout {
                                    anchors.fill: parent; spacing: 2
                                    Rectangle { width: 3; height: 12; radius: 2; color: quadrantColor(tasks[index].quadrant) }
                                    Text {
                                        text: tasks[index].title
                                        font.pixelSize: 9; font.family: "Segoe UI"; font.bold: true; color: "#1a237e"
                                        elide: Text.ElideRight; Layout.fillWidth: true
                                    }
                                }
                            }
                        }

                        Rectangle {
                            width: parent.width - 8; height: 14
                            visible: tasks.length > maxVisible
                            color: "transparent"
                            Text {
                                anchors.centerIn: parent
                                text: "+ ещё " + (tasks.length - maxVisible)
                                font.pixelSize: 9; font.family: "Segoe UI"; font.bold: true; color: "#3498DB"
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    selectedDay = new Date(dateStr);
                                    selectedDayTasks = tasks;
                                }
                            }
                        }
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                enabled: hasDay
                onClicked: {
                    selectedDay = new Date(dateStr);
                    selectedDayTasks = tasks;
                }
            }
        }
    }

    // ---------- Неделя ----------
    Component {
        id: weekView
        Item {
            ColumnLayout {
                anchors.fill: parent
                spacing: 4

                // Заголовки дней
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    Repeater {
                        model: ["Пн","Вт","Ср","Чт","Пт","Сб","Вс"]
                        delegate: Rectangle {
                            Layout.fillWidth: true
                            height: 22
                            color: "transparent"
                            Text {
                                anchors.centerIn: parent
                                text: modelData; font.pixelSize: 12; font.bold: true; font.family: "Segoe UI"; color: "#7F8C8D"
                            }
                        }
                    }
                }

                // Ячейки дней (высота 100, не растягиваются)
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    Repeater {
                        model: cellModel
                        delegate: dayDelegate
                    }
                }

                // Заполнитель оставшегося пространства
                Item { Layout.fillHeight: true }
            }
        }
    }

    // ---------- Месяц ----------
    Component {
        id: monthView
        Item {
            Flickable {
                anchors.fill: parent
                contentWidth: width
                contentHeight: monthColumn.height
                clip: true

                Column {
                    id: monthColumn
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 2

                    // Заголовки дней
                    RowLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: 4
                        Repeater {
                            model: ["Пн","Вт","Ср","Чт","Пт","Сб","Вс"]
                            delegate: Rectangle {
                                Layout.fillWidth: true
                                height: 22
                                color: "transparent"
                                Text {
                                    anchors.centerIn: parent
                                    text: modelData; font.pixelSize: 12; font.bold: true; font.family: "Segoe UI"; color: "#7F8C8D"
                                }
                            }
                        }
                    }

                    // Сетка дней (квадратные ячейки)
                    GridLayout {
                        id: monthGrid
                        anchors.left: parent.left
                        anchors.right: parent.right
                        columns: 7
                        columnSpacing: 2
                        rowSpacing: 2

                        Repeater {
                            model: cellModel
                            delegate: dayDelegate   // <-- единый делегат, для месяца будет квадрат
                        }
                    }
                }
            }
        }
    }
}