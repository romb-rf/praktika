import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import EisenNotion 1.0

Item {
    id: root
    GridLayout {
        anchors.fill: parent
        columns: 2
        rows: 2
        rowSpacing: 10
        columnSpacing: 10

        Repeater {
            model: [
                { title: "Срочно и важно", quadrant: 0, color: "#FFE0E0" },
                { title: "Срочно неважно", quadrant: 1, color: "#FFF1E0" },
                { title: "Несрочно важно", quadrant: 2, color: "#E0F2E9" },
                { title: "Несрочно неважно", quadrant: 3, color: "#EEEEEE" }
            ]
            delegate: Rectangle {
                id: quadrantRect
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: modelData.color
                border.color: Qt.darker(modelData.color, 1.15)
                border.width: 1
                radius: 10

                // Эффект глубины за счёт градиента
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 1
                    radius: 9
                    color: "transparent"
                    border.color: "#20FFFFFF"
                    border.width: 1
                }

                DropArea {
                    anchors.fill: parent
                    keys: ["application/x-task-id"]
                    onDropped: (drop) => {
                        var taskId = drop.getDataAsString("application/x-task-id")
                        if (taskId) {
                            TaskManager.moveTaskToQuadrant(taskId, modelData.quadrant)
                        }
                    }
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 4

                    Text {
                        text: modelData.title
                        font.bold: true
                        font.pixelSize: 14
                        font.family: "Segoe UI"
                        color: "#34495E"
                        Layout.bottomMargin: 4
                    }

                    ListView {
                        id: taskList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        spacing: 4
                        model: []
                        delegate: TaskCard {
                            width: taskList.width
                            taskData: modelData
                            onTaskClicked: (task) => taskDialog.loadTask(task)
                            onRemoveTask: (taskId) => TaskManager.removeTask(taskId)
                        }
                        add: Transition {
                            NumberAnimation { properties: "opacity"; from: 0; to: 1; duration: 200 }
                        }
                        remove: Transition {
                            NumberAnimation { properties: "opacity"; to: 0; duration: 150 }
                        }
                    }
                }

                Connections {
                    target: TaskManager
                    function onDataChanged() {
                        taskList.model = JSON.parse(JSON.stringify(
                            TaskManager.tasksForQuadrant(modelData.quadrant)
                        ))
                    }
                }
                Component.onCompleted: {
                    taskList.model = JSON.parse(JSON.stringify(
                        TaskManager.tasksForQuadrant(modelData.quadrant)
                    ))
                }
            }
        }
    }
}