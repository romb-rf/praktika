import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import EisenNotion 1.0

Item {
    id: root
    property string currentPeriod: "all"   // all, day, week, month, quarter

    // Функция обновления всех списков
    function refreshAllQuadrants() {
        for (var i = 0; i < 4; i++) {
            var list = quadrantRepeater.itemAt(i).children[1].children[1]; // добираемся до ListView
            if (list) {
                list.model = JSON.parse(JSON.stringify(
                    TaskManager.tasksForQuadrantAndPeriod(i, currentPeriod)
                ))
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 6

        // Верхняя панель с выбором периода
        Rectangle {
            Layout.fillWidth: true
            height: 40
            radius: 8
            color: "transparent"

            RowLayout {
                anchors.fill: parent
                spacing: 8

                Text {
                    text: "Показать задачи за:"
                    font.pixelSize: 14
                    font.family: "Segoe UI"
                    color: "#2C3E50"
                }

                // Комбобокс в стиле TaskDialog
                ComboBox {
                    id: periodBox
                    model: ["Все", "День", "Неделя", "Месяц", "Квартал"]
                    currentIndex: 0
                    Layout.preferredWidth: 160
                    Layout.preferredHeight: 36

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
                        text: periodBox.currentText
                        font.pixelSize: 14
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
                        height: Math.min(200, periodBox.count * 40)
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
                            model: periodBox.popup.visible ? periodBox.delegateModel : null
                            currentIndex: periodBox.highlightedIndex
                            ScrollIndicator.vertical: ScrollIndicator {}
                        }
                    }
                    delegate: ItemDelegate {
                        width: parent.width
                        height: 40
                        text: modelData
                        font.pixelSize: 14
                        highlighted: index === periodBox.highlightedIndex
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
                            periodBox.currentIndex = index
                            periodBox.popup.close()
                        }
                    }

                    onCurrentTextChanged: {
                        var periodMap = ["all", "day", "week", "month", "quarter"];
                        currentPeriod = periodMap[currentIndex];
                        refreshAllQuadrants();
                    }
                }
            }
        }

        // Матрица 2x2
        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: 2
            rows: 2
            rowSpacing: 10
            columnSpacing: 10

            Repeater {
                id: quadrantRepeater
                model: [
                    { title: "Срочно и важно", quadrant: 0, color: "#FFE0E0" },
                    { title: "Срочно неважно", quadrant: 1, color: "#FFF1E0" },
                    { title: "Несрочно важно", quadrant: 2, color: "#E0F2E9" },
                    { title: "Несрочно неважно", quadrant: 3, color: "#EEEEEE" }
                ]
                delegate: Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: modelData.color
                    border.color: Qt.darker(modelData.color, 1.15)
                    border.width: 1
                    radius: 10

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

                    // Соединение для автоматического обновления при изменении данных
                    Connections {
                        target: TaskManager
                        function onDataChanged() {
                            taskList.model = JSON.parse(JSON.stringify(
                                TaskManager.tasksForQuadrantAndPeriod(modelData.quadrant, currentPeriod)
                            ))
                        }
                    }
                }
            }
        }
    }

    // Первичная загрузка при старте
    Component.onCompleted: refreshAllQuadrants()
}