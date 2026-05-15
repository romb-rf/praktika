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

                // Название задачи
                TextField {
                    id: titleField
                    placeholderText: "Название задачи"
                    Layout.fillWidth: true
                    font.pixelSize: 16
                    font.bold: true
                    color: "#1a237e"
                    placeholderTextColor: "#95A5A6"
                    background: Rectangle {
                        radius: 8
                        color: "white"
                        border.color: "#3f51b5"
                        border.width: 1
                    }
                }

                // Описание
                TextArea {
                    id: descField
                    placeholderText: "Описание (можно Markdown)"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80
                    font.pixelSize: 16
                    font.bold: true
                    color: "#1a237e"
                    placeholderTextColor: "#95A5A6"
                    background: Rectangle {
                        radius: 8
                        color: "white"
                        border.color: "#3f51b5"
                        border.width: 1
                    }
                }

                // Комбобокс важности
                ComboBox {
                    id: quadrantBox
                    model: ["Без категории (входящие)", "Срочно-важно", "Срочно-неважно", "Несрочно-важно", "Несрочно-неважно"]
                    currentIndex: 0
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40

                    background: Rectangle {
                        radius: 8
                        color: "white"
                        border.color: "#3f51b5"
                        border.width: 1
                    }
                    contentItem: Text {
                        leftPadding: 12
                        rightPadding: 12
                        verticalAlignment: Text.AlignVCenter
                        text: quadrantBox.currentText
                        font.pixelSize: 16
                        font.bold: true
                        color: "#1a237e"
                    }
                    indicator: Canvas {
                        width: 12
                        height: 8
                        contextType: "2d"
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        onPaint: {
                            context.reset();
                            context.moveTo(0, 0);
                            context.lineTo(width, 0);
                            context.lineTo(width / 2, height);
                            context.closePath();
                            context.fillStyle = "#3f51b5";
                            context.fill();
                        }
                    }

                    popup: Popup {
                        y: parent.height + 4
                        width: parent.width
                        height: Math.min(250, quadrantBox.count * 40)
                        padding: 4
                        background: Rectangle {
                            radius: 8
                            color: "#ffffff"
                            border.color: "#3f51b5"
                            border.width: 1
                        }

                        contentItem: ListView {
                            clip: true
                            implicitHeight: height
                            model: quadrantBox.popup.visible ? quadrantBox.delegateModel : null
                            currentIndex: quadrantBox.highlightedIndex
                            ScrollIndicator.vertical: ScrollIndicator {}
                        }
                    }

                    delegate: ItemDelegate {
                        width: parent.width
                        height: 40
                        text: modelData
                        font.pixelSize: 14
                        highlighted: index === quadrantBox.highlightedIndex
                        background: Rectangle {
                            radius: 6
                            color: highlighted ? "#3f51b5" : "transparent"
                        }
                        contentItem: Text {
                            text: modelData
                            font: parent.font
                            color: highlighted ? "white" : "#1a237e"
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 12
                        }
                        onClicked: {
                            quadrantBox.currentIndex = index
                            quadrantBox.popup.close()
                        }
                    }
                }

                // Дата и время
                RowLayout {
                    Text {
                        text: "Дата и время:"
                        font.pixelSize: 16
                        font.bold: true
                        color: "#1a237e"
                    }

                    Button {
                        id: dateButton
                        text: selectedDate.toLocaleDateString(Qt.locale(), "dd.MM.yyyy")
                        font.pixelSize: 16
                        font.bold: true
                        palette { buttonText: "#1a237e" }
                        background: Rectangle {
                            radius: 8
                            color: "white"
                            border.color: "#3f51b5"
                            border.width: 1
                        }
                        onClicked: calendarPopup.open()
                    }

                    TextField {
                        id: timeField
                        placeholderText: "12:00"
                        inputMask: "00:00"
                        font.pixelSize: 16
                        font.bold: true
                        color: "#1a237e"
                        placeholderTextColor: "#95A5A6"
                        Layout.preferredWidth: 70
                        text: "12:00"
                        validator: RegularExpressionValidator { regularExpression: /^(0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]$/ }
                        background: Rectangle {
                            radius: 8
                            color: "white"
                            border.color: "#3f51b5"
                            border.width: 1
                        }
                    }
                }

                // Календарь
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
                        border.color: "#E0E4E8"
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 4
                        RowLayout {
                            Layout.fillWidth: true
                            Button { text: "<"; onClicked: { if (currentMonth === 0) { currentMonth = 11; currentYear-- } else { currentMonth-- } } }
                            Label {
                                text: new Date(currentYear, currentMonth).toLocaleDateString(Qt.locale(), "MMMM yyyy")
                                font.pixelSize: 14
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignHCenter
                                color: "#2C3E50"
                            }
                            Button { text: ">"; onClicked: { if (currentMonth === 11) { currentMonth = 0; currentYear++ } else { currentMonth++ } } }
                        }

                        GridLayout {
                            columns: 7
                            Layout.fillWidth: true
                            columnSpacing: 0
                            rowSpacing: 0
                            Repeater {
                                model: ["Пн","Вт","Ср","Чт","Пт","Сб","Вс"]
                                delegate: Rectangle {
                                    width: 30
                                    height: 20
                                    color: "transparent"
                                    Label {
                                        anchors.centerIn: parent
                                        text: modelData
                                        font.pixelSize: 11
                                        color: "#7F8C8D"
                                        horizontalAlignment: Text.AlignHCenter
                                    }
                                }
                            }
                        }

                        GridLayout {
                            id: daysGrid
                            columns: 7
                            Layout.fillWidth: true
                            columnSpacing: 0
                            rowSpacing: 0
                            Repeater {
                                model: {
                                    var days = []
                                    var firstDay = firstDayOfWeek(currentYear, currentMonth)
                                    var startOffset = (firstDay + 6) % 7
                                    for (var i = 0; i < startOffset; i++) days.push(0)
                                    var total = daysInMonth(currentYear, currentMonth)
                                    for (var d = 1; d <= total; d++) days.push(d)
                                    while (days.length % 7 !== 0) days.push(0)
                                    return days
                                }
                                delegate: Rectangle {
                                    width: 30
                                    height: 30
                                    color: modelData === 0 ? "transparent" :
                                           (new Date(currentYear, currentMonth, modelData).toDateString() === selectedDate.toDateString() ? "#3498DB" : "transparent")
                                    radius: 4
                                    Label {
                                        anchors.centerIn: parent
                                        text: modelData !== 0 ? modelData : ""
                                        font.pixelSize: 12
                                        color: modelData !== 0 && new Date(currentYear, currentMonth, modelData).toDateString() === selectedDate.toDateString() ? "white" : "#2C3E50"
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        enabled: modelData !== 0
                                        onClicked: {
                                            selectedDate = new Date(currentYear, currentMonth, modelData)
                                            calendarPopup.close()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // Теги
                TextField {
                    id: tagsField
                    placeholderText: "Теги через запятую"
                    Layout.fillWidth: true
                    font.pixelSize: 16
                    font.bold: true
                    color: "#1a237e"
                    placeholderTextColor: "#95A5A6"
                    background: Rectangle {
                        radius: 8
                        color: "white"
                        border.color: "#3f51b5"
                        border.width: 1
                    }
                }

                // Проект
                TextField {
                    id: projectField
                    placeholderText: "Проект"
                    Layout.fillWidth: true
                    font.pixelSize: 16
                    font.bold: true
                    color: "#1a237e"
                    placeholderTextColor: "#95A5A6"
                    background: Rectangle {
                        radius: 8
                        color: "white"
                        border.color: "#3f51b5"
                        border.width: 1
                    }
                }

                // Комбобокс повтора
                ComboBox {
                    id: recurrenceBox
                    model: ["Без повтора", "Ежедневно", "Еженедельно", "Ежемесячно", "Ежегодно", "По будням"]
                    currentIndex: 0
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40

                    background: Rectangle {
                        radius: 8
                        color: "white"
                        border.color: "#3f51b5"
                        border.width: 1
                    }
                    contentItem: Text {
                        leftPadding: 12
                        rightPadding: 12
                        verticalAlignment: Text.AlignVCenter
                        text: recurrenceBox.currentText
                        font.pixelSize: 16
                        font.bold: true
                        color: "#1a237e"
                    }
                    indicator: Canvas {
                        width: 12
                        height: 8
                        contextType: "2d"
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        onPaint: {
                            context.reset();
                            context.moveTo(0, 0);
                            context.lineTo(width, 0);
                            context.lineTo(width / 2, height);
                            context.closePath();
                            context.fillStyle = "#3f51b5";
                            context.fill();
                        }
                    }

                    popup: Popup {
                        y: parent.height + 4
                        width: parent.width
                        height: Math.min(250, recurrenceBox.count * 40)
                        padding: 4
                        background: Rectangle {
                            radius: 8
                            color: "#ffffff"
                            border.color: "#3f51b5"
                            border.width: 1
                        }

                        contentItem: ListView {
                            clip: true
                            implicitHeight: height
                            model: recurrenceBox.popup.visible ? recurrenceBox.delegateModel : null
                            currentIndex: recurrenceBox.highlightedIndex
                            ScrollIndicator.vertical: ScrollIndicator {}
                        }
                    }

                    delegate: ItemDelegate {
                        width: parent.width
                        height: 40
                        text: modelData
                        font.pixelSize: 14
                        highlighted: index === recurrenceBox.highlightedIndex
                        background: Rectangle {
                            radius: 6
                            color: highlighted ? "#3f51b5" : "transparent"
                        }
                        contentItem: Text {
                            text: modelData
                            font: parent.font
                            color: highlighted ? "white" : "#1a237e"
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 12
                        }
                        onClicked: {
                            recurrenceBox.currentIndex = index
                            recurrenceBox.popup.close()
                        }
                    }
                }

                // Кнопки Отмена и Сохранить
                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 6
                    spacing: 12
                    Item { Layout.fillWidth: true }

                    // Кнопка "Отмена" – красная, отличается от остальных
                    Button {
                        text: "Отмена"
                        Layout.preferredWidth: 130
                        Layout.preferredHeight: 40
                        font.pixelSize: 16
                        font.bold: true
                        palette {
                            button: "transparent"
                            buttonText: "#e74c3c"   // красный текст
                        }
                        background: Rectangle {
                            radius: 8
                            color: "transparent"
                            border.color: "#e74c3c"
                            border.width: 1
                        }
                        onClicked: {
                            clearFields()
                            taskDialog.close()
                        }
                    }

                    // Кнопка "Сохранить" – синяя заливка
                    Button {
                        text: "Сохранить"
                        Layout.preferredWidth: 130
                        Layout.preferredHeight: 40
                        font.pixelSize: 16
                        font.bold: true
                        palette {
                            button: "#3498DB"
                            buttonText: "#FFFFFF"
                        }
                        background: Rectangle {
                            radius: 8
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

        // Формируем локальную дату, избегая сдвига UTC
        var year = selectedDate.getFullYear();
        var month = ("0" + (selectedDate.getMonth() + 1)).slice(-2);
        var day = ("0" + selectedDate.getDate()).slice(-2);
        var dateStr = year + "-" + month + "-" + day;
        var timeStr = timeField.text + ":00";
        var deadlineStr = dateStr + "T" + timeStr;   // "yyyy-MM-ddTHH:mm:ss"

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