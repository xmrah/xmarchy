import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications

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
        interval: 6000
        onTriggered: notifModel.clear()
    }

    PanelWindow {
        visible: notifModel.count > 0
        anchors { top: true; right: true }
        exclusiveZone: 0
        implicitWidth: 360
        implicitHeight: notifColumn.implicitHeight + 24

        WlrLayershell.layer: WlrLayer.Overlay
        color: "transparent"

        Item {
            anchors.fill: parent

            Column {
                id: notifColumn
                anchors { top: parent.top; right: parent.right; margins: 12 }
                width: 336
                spacing: 10

                Repeater {
                    model: notifModel
                    delegate: Rectangle {
                        required property var notif
                        required property int index
                        width: 336
                        height: notifCardLayout.implicitHeight + 24
                        radius: 14

                        // Catppuccin / Xmarchy Dinamik Buzlu Cam Tasarımı
                        color: Qt.rgba(shell.theme.bg.r, shell.theme.bg.g, shell.theme.bg.b, 0.92)
                        border.color: Qt.rgba(shell.theme.accent.r, shell.theme.accent.g, shell.theme.accent.b, 0.55)
                        border.width: 1.5

                        ColumnLayout {
                            id: notifCardLayout
                            anchors { fill: parent; margins: 12 }
                            spacing: 6

                            // Üst Başlık & Kapatma Butonu
                            RowLayout {
                                Layout.fillWidth: true

                                Row {
                                    spacing: 6
                                    Layout.fillWidth: true

                                    Text {
                                        text: "󰂚"
                                        color: shell.theme.accent
                                        font.family: "JetBrains Mono Nerd Font"
                                        font.pixelSize: 14
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Text {
                                        text: notif.appName !== "" ? notif.appName : "Sistem Bildirimi"
                                        color: shell.theme.accent
                                        font.family: shell.fontFamily
                                        font.pixelSize: 11
                                        font.bold: true
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                // Kapat Butonu
                                Rectangle {
                                    width: 22
                                    height: 22
                                    radius: 11
                                    color: closeMouse.containsMouse 
                                        ? Qt.rgba(shell.theme.fg.r, shell.theme.fg.g, shell.theme.fg.b, 0.15) 
                                        : "transparent"

                                    Text {
                                        anchors.centerIn: parent
                                        text: "󰅖"
                                        color: shell.theme.dim
                                        font.family: "JetBrains Mono Nerd Font"
                                        font.pixelSize: 12
                                    }

                                    MouseArea {
                                        id: closeMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            notif.dismiss()
                                            notifModel.remove(index)
                                        }
                                    }
                                }
                            }

                            // Bildirim Başlığı (Summary)
                            Text {
                                Layout.fillWidth: true
                                text: notif.summary ?? ""
                                color: shell.theme.fg
                                font.family: shell.fontFamily
                                font.pixelSize: 13
                                font.bold: true
                                elide: Text.ElideRight
                                visible: text !== ""
                            }

                            // Bildirim İçeriği (Body)
                            Text {
                                Layout.fillWidth: true
                                text: notif.body ?? ""
                                color: shell.theme.dim
                                font.family: shell.fontFamily
                                font.pixelSize: 12
                                wrapMode: Text.WordWrap
                                maximumLineCount: 4
                                elide: Text.ElideRight
                                visible: text !== ""
                            }
                        }

                        // Kartın üzerine tıklandığında bildirimi kapat
                        MouseArea {
                            anchors.fill: parent
                            z: -1
                            cursorShape: Qt.PointingHandCursor
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
}
