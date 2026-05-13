import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects   // на всякий случай, если нужен DropShadow, но мы не используем сложное
import EisenNotion 1.0

ApplicationWindow {
    id: root
    visible: true
    visibility: Window.Maximized
    title: "EisenNotion"
    color: "#F0F2F5"

    RowLayout {
        anchors.fill: parent
        spacing: 0

        MatrixView {
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width * 0.58
            Layout.margins: 10
        }

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
                    font.family: "Segoe UI"
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
                        taskDialog.open()
                    }
                }

                Button {
                    text: "📅 Календарь"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    font.pixelSize: 13
                    font.family: "Segoe UI"
                    flat: true
                    enabled: false
                    opacity: 0.6
                }

                TextField {
                    id: searchField
                    placeholderText: "Поиск по задачам..."
                    Layout.fillWidth: true
                    font.pixelSize: 13
                    font.family: "Segoe UI"
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
                    font.family: "Segoe UI"
                    color: "#2C3E50"
                }
                Text {
                    text: "Перетащите задачу в нужный квадрант"
                    font.pixelSize: 11
                    color: "#95A5A6"
                    font.family: "Segoe UI"
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

    TaskDialog {
        id: taskDialog
    }

    Connections {
        target: TaskManager
        function onDataChanged() {
            inboxList.model = JSON.parse(JSON.stringify(TaskManager.inboxTasks()))
        }
    }

    Component.onCompleted: {
        inboxList.model = JSON.parse(JSON.stringify(TaskManager.inboxTasks()))
    }
}