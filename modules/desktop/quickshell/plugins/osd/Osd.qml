import QtQuick
import Quickshell
import Quickshell.Wayland

Item {
    id: root

    property bool visible_: false
    property string icon: ""
    property int value: 0

    function show(iconName: string, val: int) {
        root.icon = iconName
        root.value = Math.max(0, Math.min(100, val))
        root.visible_ = true
        hideTimer.restart()
    }

    Timer {
        id: hideTimer
        interval: 1500
        onTriggered: root.visible_ = false
    }

    PanelWindow {
        visible: root.visible_
        anchors { bottom: true }
        exclusiveZone: 0
        height: 48
        width: 280

        WlrLayershell.layer: WlrLayer.Overlay
        color: shell.theme.bg

        Item {
            anchors.fill: parent

            Row {
                anchors.centerIn: parent
                spacing: 12

                Text {
                    text: root.icon
                    color: shell.theme.fg
                    font.family: shell.fontFamily
                    font.pixelSize: 20
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    width: 160
                    height: 4
                    color: shell.theme.dim
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle {
                        width: parent.width * (root.value / 100)
                        height: parent.height
                        color: shell.theme.fg
                    }
                }

                Text {
                    text: root.value + "%"
                    color: shell.theme.fg
                    font.family: shell.fontFamily
                    font.pixelSize: 12
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Rectangle {
                anchors.fill: parent
                color: "transparent"
                border.color: shell.theme.fg
                border.width: 1
            }
        }
    }
}
