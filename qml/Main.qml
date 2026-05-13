import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import EisenNotion 1.0

ApplicationWindow {
    id: root
    visible: true
    visibility: Window.Maximized
    title: "EisenNotion"
    color: "#F0F2F5"

    // Явная светлая палитра, чтобы избежать влияния системной тёмной темы
    palette: Palette {
        window: "#F0F2F5"
        windowText: "#2C3E50"
        base: "#FFFFFF"
        alternateBase: "#F7F9FB"
        text: "#2C3E50"
        button: "#F0F2F5"
        buttonText: "#2C3E50"
        highlight: "#3498DB"
        highlightedText: "#FFFFFF"
        toolTipBase: "#FFFFFF"
        toolTipText: "#2C3E50"
    }

    // Основной контент: матрица слева + панель справа
    RowLayout {
        anchors.fill: parent
        spacing: 0

        // Матрица 2x2
        MatrixView {
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width * 0.58
            Layout.margins: 10
        }

        // Правая панель инструментов и "Входящие"
        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true
            color: "#FFFFFF"
            border.color: "#D0D6DC"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                Button {
                    text: "＋ Новая задача"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    font.pixelSize: 13
                    palette {
                        button: "#3498DB"
                        buttonText: "#FFFFFF"
                    }
                    background: Rectangle {
                        color: parent.palette.button
                        radius: 6
                    }
                    onClicked: {
                        taskDialog.editingTaskId = ""
                        taskDialog.show()
                    }
                }

                Button {
                    text: "📅 Календарь"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    font.pixelSize: 13
                    flat: true
                    enabled: false
                    opacity: 0.6
                }

                TextField {
                    id: searchField
                    placeholderText: "Поиск по задачам..."
                    Layout.fillWidth: true
                    font.pixelSize: 13
                    background: Rectangle {
                        radius: 6
                        color: "#F7F9FB"
                        border.color: "#D5DCE3"
                    }
                    onTextChanged: TaskManager.searchQuery = text
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#E0E4E8"
                }

                Text {
                    text: "📥 Входящие"
                    font.bold: true
                    font.pixelSize: 14
                    color: "#2C3E50"
                }
                Text {
                    text: "Перетащите задачу в нужный квадрант"
                    font.pixelSize: 11
                    color: "#95A5A6"
                }

                ListView {
                    id: inboxList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 4
                    model: []
                    delegate: InboxTaskCard {
                        width: inboxList.width
                        taskData: modelData
                    }
                    add: Transition {
                        NumberAnimation { properties: "opacity"; from: 0; to: 1; duration: 200 }
                    }
                    remove: Transition {
                        NumberAnimation { properties: "opacity"; to: 0; duration: 150 }
                    }
                }
            }
        }
    }

    // Обновление модели входящих при изменении данных
    Connections {
        target: TaskManager
        function onDataChanged() {
            inboxList.model = JSON.parse(JSON.stringify(TaskManager.inboxTasks()))
        }
    }

    Component.onCompleted: {
        inboxList.model = JSON.parse(JSON.stringify(TaskManager.inboxTasks()))
    }

    // Диалог создания/редактирования задачи
    TaskDialog {
        id: taskDialog
    }
}