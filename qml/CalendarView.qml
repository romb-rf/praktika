import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import EisenNotion 1.0

Item {
    id: root
    property string viewMode: "week"   // week, month, quarter
    property date currentDate: new Date()

    // Функция для форматирования даты в ISO локально
    function dateToISO(d) {
        var year = d.getFullYear();
        var month = ("0" + (d.getMonth() + 1)).slice(-2);
        var day = ("0" + d.getDate()).slice(-2);
        return year + "-" + month + "-" + day;
    }

    // Вычисляем первый и последний день видимого диапазона
    property date rangeStart: {
        if (viewMode === "week") {
            var day = currentDate.getDay();
            var diff = currentDate.getDate() - day + (day === 0 ? -6 : 1); // понедельник
            return new Date(currentDate.getFullYear(), currentDate.getMonth(), diff);
        } else if (viewMode === "month") {
            return new Date(currentDate.getFullYear(), currentDate.getMonth(), 1);
        } else { // quarter
            var q = Math.floor(currentDate.getMonth() / 3);
            return new Date(currentDate.getFullYear(), q * 3, 1);
        }
    }
    property date rangeEnd: {
        if (viewMode === "week") {
            var start = rangeStart;
            return new Date(start.getFullYear(), start.getMonth(), start.getDate() + 6);
        } else if (viewMode === "month") {
            return new Date(currentDate.getFullYear(), currentDate.getMonth() + 1, 0);
        } else { // quarter
            var q = Math.floor(currentDate.getMonth() / 3);
            return new Date(currentDate.getFullYear(), (q + 1) * 3, 0);
        }
    }

    // Загружаем задачи для видимого диапазона
    property var tasksInRange: {
        var from = dateToISO(rangeStart);
        var to = dateToISO(rangeEnd);
        return JSON.parse(JSON.stringify(TaskManager.tasksForRange(from, to)));
    }

    // Группируем задачи по дате (строка "yyyy-MM-dd")
    function tasksForDate(date) {
        var key = dateToISO(date);
        var filtered = [];
        for (var i = 0; i < tasksInRange.length; i++) {
            var task = tasksInRange[i];
            var taskDate = dateToISO(new Date(task.deadline));
            if (taskDate === key) filtered.push(task);
        }
        return filtered;
    }

    // Цвет квадранта
    function quadrantColor(q) {
        switch (q) {
            case 0: return "#E74C3C";
            case 1: return "#F39C12";
            case 2: return "#2ECC71";
            default: return "#95A5A6";
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 8

        // Верхняя навигация
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
                    onClicked: {
                        if (viewMode === "week") currentDate = new Date(currentDate.getFullYear(), currentDate.getMonth(), currentDate.getDate() - 7);
                        else if (viewMode === "month") currentDate = new Date(currentDate.getFullYear(), currentDate.getMonth() - 1, 1);
                        else currentDate = new Date(currentDate.getFullYear(), currentDate.getMonth() - 3, 1);
                    }
                }

                Text {
                    text: {
                        if (viewMode === "week") {
                            var end = rangeEnd;
                            return rangeStart.toLocaleDateString(Qt.locale("ru_RU"), "dd MMMM") + " – " + end.toLocaleDateString(Qt.locale("ru_RU"), "dd MMMM yyyy");
                        } else if (viewMode === "month") {
                            return currentDate.toLocaleDateString(Qt.locale("ru_RU"), "MMMM yyyy");
                        } else {
                            var q = Math.floor(currentDate.getMonth() / 3);
                            var start = new Date(currentDate.getFullYear(), q * 3, 1);
                            var end = new Date(currentDate.getFullYear(), (q + 1) * 3, 0);
                            return "Q" + (q+1) + " " + currentDate.getFullYear();
                        }
                    }
                    font.bold: true
                    font.pixelSize: 14
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    color: "#2C3E50"
                }

                Button {
                    text: ">"
                    flat: true
                    onClicked: {
                        if (viewMode === "week") currentDate = new Date(currentDate.getFullYear(), currentDate.getMonth(), currentDate.getDate() + 7);
                        else if (viewMode === "month") currentDate = new Date(currentDate.getFullYear(), currentDate.getMonth() + 1, 1);
                        else currentDate = new Date(currentDate.getFullYear(), currentDate.getMonth() + 3, 1);
                    }
                }
            }
        }

        // Переключатели режима
        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            Button {
                text: "Неделя"
                highlighted: viewMode === "week"
                flat: true

                background: Rectangle {
                    radius: 6
                    color: parent.highlighted ? "#3f51b5" : "transparent"
                    border.color: "#3f51b5"
                    border.width: 1
                }

                contentItem: Text {
                    text: parent.text
                    font: parent.font
                    color: parent.highlighted ? "#FFFFFF" : "#1a237e"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: viewMode = "week"
            }

            Button {
                text: "Месяц"
                highlighted: viewMode === "month"
                flat: true

                background: Rectangle {
                    radius: 6
                    color: parent.highlighted ? "#3f51b5" : "transparent"
                    border.color: "#3f51b5"
                    border.width: 1
                }

                contentItem: Text {
                    text: parent.text
                    font: parent.font
                    color: parent.highlighted ? "#FFFFFF" : "#1a237e"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: viewMode = "month"
            }

            Button {
                text: "Квартал"
                highlighted: viewMode === "quarter"
                flat: true

                background: Rectangle {
                    radius: 6
                    color: parent.highlighted ? "#3f51b5" : "transparent"
                    border.color: "#3f51b5"
                    border.width: 1
                }

                contentItem: Text {
                    text: parent.text
                    font: parent.font
                    color: parent.highlighted ? "#FFFFFF" : "#1a237e"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: viewMode = "quarter"
            }
        }

        // Сетка дней
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            // Недельный вид
            Loader {
                anchors.fill: parent
                active: viewMode === "week"
                sourceComponent: weekView
            }
            // Месячный вид
            Loader {
                anchors.fill: parent
                active: viewMode === "month"
                sourceComponent: monthView
            }
            // Квартальный вид
            Loader {
                anchors.fill: parent
                active: viewMode === "quarter"
                sourceComponent: quarterView
            }
        }
    }

    // Компонент: неделя
    Component {
        id: weekView
        GridLayout {
            columns: 7
            columnSpacing: 2
            rowSpacing: 2

            Repeater {
                model: ["Пн","Вт","Ср","Чт","Пт","Сб","Вс"]
                delegate: Rectangle {
                    width: 60
                    height: 22
                    color: "transparent"
                    Text {
                        anchors.centerIn: parent
                        text: modelData
                        font.pixelSize: 12
                        font.bold: true
                        color: "#7F8C8D"
                    }
                }
            }

            Repeater {
                model: {
                    var days = [];
                    var start = rangeStart;
                    for (var i = 0; i < 7; i++) {
                        days.push(new Date(start.getFullYear(), start.getMonth(), start.getDate() + i));
                    }
                    return days;
                }
                delegate: Rectangle {
                    width: 60
                    height: 100
                    color: "white"
                    border.color: "#E0E4E8"
                    radius: 6
                    border.width: 1

                    // Фон сегодняшнего дня
                    Rectangle {
                        anchors.fill: parent
                        radius: 6
                        color: modelData.toDateString() === new Date().toDateString() ? "#EBF5FF" : "transparent"
                        z: -1
                    }

                    Column {
                        anchors.fill: parent
                        anchors.margins: 4
                        spacing: 2

                        Text {
                            text: modelData.getDate()
                            font.bold: true
                            font.pixelSize: 14
                            color: modelData.toDateString() === new Date().toDateString() ? "#3f51b5" : "#2C3E50"
                        }

                        ListView {
                            width: parent.width
                            height: parent.height - 22
                            clip: true
                            spacing: 1
                            model: tasksForDate(modelData)
                            delegate: Text {
                                width: parent.width
                                text: modelData.title
                                font.pixelSize: 10
                                color: quadrantColor(modelData.quadrant)
                                elide: Text.ElideRight
                            }
                        }
                    }

                    // Клик – открыть диалог на эту дату
                    MouseArea {
                        anchors.fill: parent
                        onClicked: taskDialog.showForDate(modelData)
                    }
                }
            }
        }
    }

    // Компонент: месяц
    Component {
        id: monthView
        GridLayout {
            columns: 7
            columnSpacing: 2
            rowSpacing: 2

            Repeater {
                model: ["Пн","Вт","Ср","Чт","Пт","Сб","Вс"]
                delegate: Rectangle {
                    width: 60
                    height: 22
                    color: "transparent"
                    Text {
                        anchors.centerIn: parent
                        text: modelData
                        font.pixelSize: 12
                        font.bold: true
                        color: "#7F8C8D"
                    }
                }
            }

            Repeater {
                model: {
                    var days = [];
                    var firstDay = rangeStart.getDay();
                    var startOffset = firstDay === 0 ? 6 : firstDay - 1; // пн=0
                    var totalDays = new Date(rangeStart.getFullYear(), rangeStart.getMonth() + 1, 0).getDate();
                    for (var i = 0; i < startOffset; i++) days.push(null);
                    for (var d = 1; d <= totalDays; d++) {
                        days.push(new Date(rangeStart.getFullYear(), rangeStart.getMonth(), d));
                    }
                    return days;
                }
                delegate: Rectangle {
                    width: 60
                    height: 80
                    color: modelData ? "white" : "transparent"
                    border.color: modelData ? "#E0E4E8" : "transparent"
                    radius: 6
                    visible: modelData !== null

                    // Фон сегодня
                    Rectangle {
                        anchors.fill: parent
                        radius: 6
                        color: modelData && modelData.toDateString() === new Date().toDateString() ? "#EBF5FF" : "transparent"
                        z: -1
                    }

                    Column {
                        anchors.fill: parent
                        anchors.margins: 4
                        spacing: 2
                        visible: modelData !== null

                        Text {
                            text: modelData ? modelData.getDate() : ""
                            font.bold: true
                            font.pixelSize: 14
                            color: modelData && modelData.toDateString() === new Date().toDateString() ? "#3f51b5" : "#2C3E50"
                        }
                        ListView {
                            width: parent.width
                            height: parent.height - 22
                            clip: true
                            spacing: 1
                            model: modelData ? tasksForDate(modelData) : []
                            delegate: Text {
                                width: parent.width
                                text: modelData.title
                                font.pixelSize: 10
                                color: quadrantColor(modelData.quadrant)
                                elide: Text.ElideRight
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        enabled: modelData !== null
                        onClicked: taskDialog.showForDate(modelData)
                    }
                }
            }
        }
    }

    // Компонент: квартал
    Component {
        id: quarterView
        GridLayout {
            columns: 3
            columnSpacing: 4
            rowSpacing: 4

            Repeater {
                model: {
                    var months = [];
                    var q = Math.floor(rangeStart.getMonth() / 3);
                    for (var m = 0; m < 3; m++) {
                        months.push(new Date(rangeStart.getFullYear(), q * 3 + m, 1));
                    }
                    return months;
                }
                delegate: Rectangle {
                    width: 120
                    height: 100
                    color: "white"
                    border.color: "#E0E4E8"
                    radius: 6

                    Column {
                        anchors.fill: parent
                        anchors.margins: 4
                        Text {
                            text: modelData.toLocaleDateString(Qt.locale("ru_RU"), "MMMM")
                            font.bold: true
                            font.pixelSize: 14
                            color: "#2C3E50"
                        }

                        ListView {
                            width: parent.width
                            height: parent.height - 20
                            clip: true
                            spacing: 1
                            model: {
                                var from = new Date(modelData.getFullYear(), modelData.getMonth(), 1);
                                var to = new Date(modelData.getFullYear(), modelData.getMonth() + 1, 0);
                                var filtered = [];
                                for (var i = 0; i < tasksInRange.length; i++) {
                                    var t = tasksInRange[i];
                                    var d = new Date(t.deadline);
                                    if (d >= from && d <= to) filtered.push(t);
                                }
                                return filtered;
                            }
                            delegate: Text {
                                width: parent.width
                                text: modelData.title
                                font.pixelSize: 10
                                color: quadrantColor(modelData.quadrant)
                                elide: Text.ElideRight
                            }
                        }
                    }

                    // Клик на месяц – переключиться в месячный режим на этот месяц
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            currentDate = new Date(modelData.getFullYear(), modelData.getMonth(), 1);
                            viewMode = "month";
                        }
                    }
                }
            }
        }
    }
}