import QtQuick
import QtQuick.Controls

Window {
    id: notification
    width: 280
    height: 80
    color: "transparent"
    flags: Qt.ToolTip | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    property string message: ""
    property var parentWindow: null

    Rectangle {
        anchors.fill: parent
        radius: 8
        color: "#2C3E50"
        opacity: 0.9
        Text {
            anchors.centerIn: parent
            text: message
            color: "white"
            font.pixelSize: 14
            font.bold: true
            font.family: "Segoe UI"
        }
    }

    Timer {
        interval: 4000
        running: true
        onTriggered: notification.close()
    }

    Component.onCompleted: {
        if (parentWindow) {
            x = parentWindow.x + parentWindow.width / 2 - width / 2
            y = parentWindow.y + parentWindow.height + 10
        } else {
            x = Screen.desktopAvailableWidth - width - 20
            y = Screen.desktopAvailableHeight - height - 40
        }
        show()
    }
}