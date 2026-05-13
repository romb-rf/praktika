import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import EisenNotion 1.0

Item {
    id: root
    property var taskData: ({})
    signal taskClicked(var task)
    signal removeTask(string taskId)

    height: 62
    Rectangle {
        anchors.fill: parent
        anchors.margins: 2
        color: "#FFFFFF"
        radius: 6
        border.color: "#F0F0F0"
        // лёгкая тень через дополнительный прямоугольник
        Rectangle {
            anchors.fill: parent
            anchors.margins: -1
            radius: 7
            color: "transparent"
            border.color: "#18000000"
            border.width: 1
            z: -1
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 8

            CheckBox {
                checked: taskData.completed || false
                onToggled: TaskManager.toggleComplete(taskData.id)
                palette { accent: "#3498DB" }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                Text {
                    text: taskData.title || "Без названия"
                    font.pixelSize: 14
                    font.family: "Segoe UI"
                    font.strikeout: taskData.completed
                    color: taskData.completed ? "#95A5A6" : "#2C3E50"
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                Text {
                    text: {
                        var desc = taskData.description || ""
                        desc.length > 60 ? desc.substring(0, 60) + "..." : desc
                    }
                    font.pixelSize: 12
                    font.family: "Segoe UI"
                    color: "#7F8C8D"
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                    visible: text.length > 0
                }

                Row {
                    spacing: 3
                    visible: taskData.tags && taskData.tags.length > 0
                    Repeater {
                        model: taskData.tags
                        delegate: Rectangle {
                            color: "#E8F0FE"
                            radius: 4
                            width: tagText.width + 8
                            height: 16
                            Text {
                                id: tagText
                                text: modelData
                                font.pixelSize: 10
                                font.family: "Segoe UI"
                                color: "#2C3E50"
                                anchors.centerIn: parent
                            }
                        }
                    }
                }
            }

            Button {
                text: "🗑"
                flat: true
                font.pixelSize: 16
                onClicked: removeTask(taskData.id)
                palette { buttonText: "#E74C3C" }
                background: null
            }

            MouseArea {
                anchors.fill: parent
                onClicked: taskClicked(taskData)
                z: -1
            }
        }
    }
}