import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import EisenNotion 1.0

Item {
    id: root
    property var taskData: ({})

    width: parent.width
    height: 50

    // Фон и текст
    Rectangle {
        anchors.fill: parent
        anchors.margins: 2
        color: "#FFFFFF"
        radius: 6
        border.color: "#F0F0F0"
        z: 0

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
            Text {
                text: taskData.title || "Без названия"
                font.pixelSize: 14
                font.family: "Segoe UI"
                color: "#2C3E50"
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
            // Кнопка удаления убрана отсюда, теперь снаружи
        }
    }

    // Кнопка удаления – поверх всего
    Button {
        text: "🗑"
        flat: true
        font.pixelSize: 16
        z: 10                         // выше MouseArea
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        palette { buttonText: "#E74C3C" }
        background: null
        onClicked: TaskManager.removeTask(taskData.id)
    }

    // Drag только по оставшейся области (не перекрывает кнопку, так как кнопка выше)
    MouseArea {
        id: dragArea
        anchors.fill: parent
        z: 0
        property real pressX: 0
        property real pressY: 0
        onPressed: {
            pressX = mouseX
            pressY = mouseY
        }
        // Активация Drag только при значительном движении, чтобы не мешать клику по кнопке
        Drag.active: pressed && Math.abs(mouseX - pressX) > 10
        Drag.keys: ["application/x-task-id"]
        Drag.mimeData: { "application/x-task-id": taskData.id }
        Drag.dragType: Drag.Automatic
        drag.target: null
    }
}