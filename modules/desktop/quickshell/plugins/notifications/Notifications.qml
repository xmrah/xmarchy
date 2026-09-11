import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications

// Xmarchy Brutalist Notification Server
Item {
    id: root

    NotificationServer {
        id: server
        keepOnReload: true
        onNotification: function(notification) {
            notifModel.insert(0, { notif: notification })
            if (notifModel.count > 5) notifModel.remove(5)
            autoHide.restart()
        }
    }

    ListModel { id: notifModel }

    Timer {
        id: autoHide
        interval: 5000
        onTriggered: notifModel.clear()
    }

    // Bildirim paneli (sağ üst köşe)
    WlrLayershell {
        visible: notifModel.count > 0
        anchors { top: true; right: true }
        exclusiveZone: 0
        width: 320
        height: notifColumn.implicitHeight + 16

        WlrLayer.layer: WlrLayer.Overlay
        color: "transparent"

        Column {
            id: notifColumn
            anchors { top: parent.top; right: parent.right; margins: 8 }
            width: 304
            spacing: 4

            Repeater {
                model: notifModel
                delegate: Rectangle {
                    required property var notif
                    width: 304
                    height: notifContent.implicitHeight + 16
                    color: shell.bg
                    border.color: shell.fg
                    border.width: 1

                    Column {
                        id: notifContent
                        anchors { fill: parent; margins: 8 }
                        spacing: 4

                        Text {
                            text: notif.summary ?? ""
                            color: shell.fg
                            font.family: shell.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                            width: parent.width
                            elide: Text.ElideRight
                        }

                        Text {
                            text: notif.body ?? ""
                            color: shell.dim
                            font.family: shell.fontFamily
                            font.pixelSize: 11
                            width: parent.width
                            wrapMode: Text.WordWrap
                            maximumLineCount: 3
                            elide: Text.ElideRight
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            notif.dismiss()
                            notifModel.remove(index)
                        }
                    }
                }
            }
        }
    }
}
