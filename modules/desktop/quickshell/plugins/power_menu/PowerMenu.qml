import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

Item {
    id: root

    property bool opened: false
    property int selectedIndex: 0

    function open() {
        shell.closeAllMenus()
        root.selectedIndex = 0
        root.opened = true
    }

    Process {
        id: powerProcess
    }

    function executeAction(index: int) {
        root.opened = false
        if (index === 0) {
            // Kilitle
            shell.lock.open()
        } else if (index === 1) {
            // Askıya Al / Uyut
            powerProcess.command = ["systemctl", "suspend"]
            powerProcess.running = true
        } else if (index === 2) {
            // Yeniden Başlat
            powerProcess.command = ["systemctl", "reboot"]
            powerProcess.running = true
        } else if (index === 3) {
            // Kapat
            powerProcess.command = ["systemctl", "poweroff"]
            powerProcess.running = true
        } else if (index === 4) {
            // Hyprland Oturumunu Kapat
            powerProcess.command = ["hyprctl", "dispatch", "exit"]
            powerProcess.running = true
        }
    }

    readonly property var actions: [
        { name: "Kilitle", icon: "󰌾", color: "#8BE9FD" },
        { name: "Uyut", icon: "󰤄", color: "#BD93F9" },
        { name: "Yeniden Başlat", icon: "󰜉", color: "#FFB86C" },
        { name: "Kapat", icon: "󰐥", color: "#FF5555" },
        { name: "Çıkış", icon: "󰗽", color: "#50FA7B" }
    ]

    PanelWindow {
        visible: root.opened
        anchors { top: true; bottom: true; left: true; right: true }
        exclusiveZone: -1
        color: "#CC05070D"

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        Item {
            anchors.fill: parent

            MouseArea {
                anchors.fill: parent
                onClicked: root.opened = false
            }

            Rectangle {
                anchors.centerIn: parent
                width: 520
                height: 190
                radius: 16
                color: shell.theme.bg
                border.color: shell.theme.accent
                border.width: 1

                Column {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 16

                    // Başlık
                    Column {
                        width: parent.width
                        spacing: 4

                        Text {
                            text: "Güç & Oturum Denetimi"
                            color: shell.theme.fg
                            font.family: shell.fontFamily
                            font.pixelSize: 15
                            font.bold: true
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Text {
                            text: "Ok tuşlarıyla gezinip Enter'a veya ESC ile iptale basın"
                            color: shell.theme.dim
                            font.family: shell.fontFamily
                            font.pixelSize: 11
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }

                    // Eylem Kartları (5 Tuş)
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 12

                        Repeater {
                            model: root.actions
                            delegate: Rectangle {
                                required property var modelData
                                required property int index
                                width: 84
                                height: 84
                                radius: 10
                                property bool isSelected: root.selectedIndex === index
                                color: isSelected ? shell.theme.surface : "transparent"
                                border.color: isSelected ? modelData.color : shell.theme.surface
                                border.width: isSelected ? 2 : 1

                                scale: isSelected ? 1.05 : 1.0
                                Behavior on scale { NumberAnimation { duration: 120 } }
                                Behavior on color { ColorAnimation { duration: 120 } }

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 6

                                    Text {
                                        text: modelData.icon
                                        color: modelData.color
                                        font.family: shell.fontFamily
                                        font.pixelSize: 26
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }

                                    Text {
                                        text: modelData.name
                                        color: parent.parent.isSelected ? shell.theme.fg : shell.theme.dim
                                        font.family: shell.fontFamily
                                        font.pixelSize: 10
                                        font.bold: parent.parent.isSelected
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onEntered: root.selectedIndex = index
                                    onClicked: root.executeAction(index)
                                }
                            }
                        }
                    }
                }
            }

            Item {
                focus: root.opened
                Keys.onEscapePressed: root.opened = false
                Keys.onLeftPressed: root.selectedIndex = (root.selectedIndex - 1 + root.actions.length) % root.actions.length
                Keys.onRightPressed: root.selectedIndex = (root.selectedIndex + 1) % root.actions.length
                Keys.onReturnPressed: root.executeAction(root.selectedIndex)
            }
        }
    }
}
