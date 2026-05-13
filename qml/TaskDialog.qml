import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import EisenNotion 1.0

Dialog {
    id: taskDialog
    title: editingTaskId ? "Редактировать задачу" : "Новая задача"
    standardButtons: Dialog.Ok | Dialog.Cancel
    width: 480
    height: 420
    font.family: "Segoe UI"

    property string editingTaskId: ""

    ColumnLayout {
        spacing: 12
        anchors.fill: parent

        TextField {
            id: titleField
            placeholderText: "Название задачи"
            Layout.fillWidth: true
            font.pixelSize: 14
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
            background: Rectangle {
                radius: 6
                color: "#F7F9FB"
                border.color: "#D5DCE3"
            }
        }

        ComboBox {
            id: quadrantBox
            model: ["Без категории (входящие)", "Срочно-важно", "Срочно-неважно", "Несрочно-важно", "Несрочно-неважно"]
            currentIndex: 0
            font.pixelSize: 13
        }

        RowLayout {
            Text { text: "Срок:"; font.pixelSize: 13; color: "#2C3E50" }
            TextField {
                id: deadlineField
                placeholderText: "2026-05-13T10:00"
                Layout.fillWidth: true
                font.pixelSize: 13
                background: Rectangle {
                    radius: 6
                    color: "#F7F9FB"
                    border.color: "#D5DCE3"
                }
            }
        }

        TextField {
            id: tagsField
            placeholderText: "Теги через запятую"
            Layout.fillWidth: true
            font.pixelSize: 13
            background: Rectangle {
                radius: 6
                color: "#F7F9FB"
                border.color: "#D5DCE3"
            }
        }

        TextField {
            id: projectField
            placeholderText: "Проект"
            Layout.fillWidth: true
            font.pixelSize: 13
            background: Rectangle {
                radius: 6
                color: "#F7F9FB"
                border.color: "#D5DCE3"
            }
        }

        ComboBox {
            id: recurrenceBox
            model: ["Без повтора", "Ежедневно", "Еженедельно", "Ежемесячно", "Ежегодно", "По будням"]
            currentIndex: 0
            font.pixelSize: 13
        }
    }

    onAccepted: {
        var quadIndex = quadrantBox.currentIndex - 1  // -1 для "Без категории"

        let taskObj = {
            title: titleField.text,
            description: descField.text,
            quadrant: quadIndex,
            deadline: deadlineField.text,
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
    }
    onRejected: {
        clearFields();
    }

    function loadTask(task) {
        if (task) {
            editingTaskId = task.id;
            titleField.text = task.title || "";
            descField.text = task.description || "";
            var q = task.quadrant !== undefined ? task.quadrant : -1;
            quadrantBox.currentIndex = q + 1;
            deadlineField.text = task.deadline || "";
            tagsField.text = task.tags ? task.tags.join(", ") : "";
            projectField.text = task.project || "";
            var rules = ["", "daily", "weekly", "monthly", "yearly", "weekdays"];
            var idx = rules.indexOf(task.recurrenceRule || "");
            recurrenceBox.currentIndex = idx >= 0 ? idx : 0;
            open();
        }
    }

    function clearFields() {
        editingTaskId = "";
        titleField.clear();
        descField.clear();
        quadrantBox.currentIndex = 0;
        deadlineField.clear();
        tagsField.clear();
        projectField.clear();
        recurrenceBox.currentIndex = 0;
    }
}