import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import EisenNotion 1.0

Item {
    id: root
    property var taskData: ({})
    signal taskClicked(var task)
    signal removeTask(string taskId)

    height: 70

    // При завершении карточка становится полупрозрачной
    opacity: taskData.completed ? 0.7 : 1.0

    Rectangle {
        anchors.fill: parent
        anchors.margins: 2
        color: "#FFFFFF"
        radius: 6
        border.color: "#F0F0F0"

        // Лёгкая тень
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

            // Чекбокс выполнения
            CheckBox {
                checked: taskData.completed || false
                onToggled: TaskManager.toggleComplete(taskData.id)
                palette { accent: "#3498DB" }
            }

            // Основной контент
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                // Строка с названием и дедлайном
                RowLayout {
                    spacing: 8
                    Layout.fillWidth: true

                    // Название задачи
                    Text {
                        text: taskData.title || "Без названия"
                        font.pixelSize: 14
                        font.family: "Segoe UI"
                        font.strikeout: taskData.completed
                        color: taskData.completed ? "#95A5A6" : "#2C3E50"
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                        maximumLineCount: 2
                        wrapMode: Text.WordWrap
                    }

                    // Дедлайн (при завершении серый)
                    Text {
                        text: {
                                                if (!taskData.deadline) return ""
                                                var d = new Date(taskData.deadline)
                                                if (isNaN(d.getTime())) return ""
                                                // Месяцы для карточки
                                                var months = ["Января", "Февраля", "Марта", "Апреля", "Мая", "Июня",
                                                              "Июля", "Августа", "Сентября", "Октября", "Ноября", "Декабря"];
                                                return "⏰ " + d.getDate() + " " + months[d.getMonth()] + " " + d.getFullYear() + " " +
                                                       d.getHours().toString().padStart(2, '0') + ":" +
                                                       d.getMinutes().toString().padStart(2, '0')
                                            }
                        font.pixelSize: 11
                        font.family: "Segoe UI"
                        font.strikeout: taskData.completed
                        color: taskData.completed ? "#95A5A6" : "#E74C3C"
                        elide: Text.ElideRight
                        Layout.maximumWidth: 200
                        visible: text.length > 0
                    }
                }

                // Строка с тегами и проектом
                Row {
                    spacing: 3
                    visible: (taskData.tags && taskData.tags.length > 0) || (taskData.project && taskData.project.length > 0)
                    Layout.fillWidth: true

                    // Теги
                    Repeater {
                        model: taskData.tags
                        delegate: Rectangle {
                            // При завершении делаем фон тега более бледным
                            color: taskData.completed ? "#D0D8E4" : "#E8F0FE"
                            radius: 4
                            width: tagText.width + 8
                            height: 16
                            Text {
                                id: tagText
                                text: modelData
                                font.pixelSize: 10
                                font.family: "Segoe UI"
                                font.strikeout: taskData.completed
                                color: taskData.completed ? "#95A5A6" : "#2C3E50"
                                anchors.centerIn: parent
                            }
                        }
                    }

                    // Проект (серый/ещё серее)
                    Text {
                        text: taskData.project || ""
                        font.pixelSize: 11
                        font.family: "Segoe UI"
                        font.strikeout: taskData.completed
                        color: taskData.completed ? "#95A5A6" : "#7F8C8D"
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                        visible: text.length > 0
                    }
                }
            }

            // Кнопка удаления
            Button {
                text: "🗑"
                flat: true
                font.pixelSize: 16
                onClicked: removeTask(taskData.id)
                palette { buttonText: "#E74C3C" }
                background: null
            }
        }

        // Клик для редактирования (по всей карточке)
        MouseArea {
            anchors.fill: parent
            onClicked: taskClicked(taskData)
            z: -1
        }
    }
}