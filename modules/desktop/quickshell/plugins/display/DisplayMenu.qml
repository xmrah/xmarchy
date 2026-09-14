import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

Item {
    id: root

    property bool opened: false
    property int popupX: 100
    property int popupY: 40
    readonly property int popupWidth: 380
    readonly property int popupHeight: 220

    property string currentScale: "1"
    readonly property var scalePresets: ["1", "1.25", "1.6", "2", "3.2", "4"]
    readonly property var textSizes: [9, 10, 11, 12, 14, 16]
    property int selectedTextIndex: 2 // 11px

    function openAt(x: int, y: int) {
        shell.closeAllMenus()
        root.popupX = Math.max(10, Math.min(x, 1920 - root.popupWidth - 10))
        root.popupY = shell.barHeight + 6
        root.opened = true
    }

    function toggle(x: int, y: int) {
        if (root.opened) {
            root.opened = false
        } else {
            root.openAt(x, y)
        }
    }

    function applyScale(scaleVal: string) {
        root.currentScale = scaleVal
        Hyprland.dispatch("keyword monitor ,preferred,auto," + scaleVal)
    }

    PanelWindow {
        visible: root.opened
        anchors { top: true; bottom: true; left: true; right: true }
        exclusiveZone: -1
        color: "transparent"

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        Item {
            anchors.fill: parent

            MouseArea {
                anchors.fill: parent
                onClicked: root.opened = false
            }

            Rectangle {
                x: root.popupX
                y: root.popupY
                width: root.popupWidth
                height: root.popupHeight
                radius: 12
                color: shell.theme.bg
                border.color: shell.theme.accent
                border.width: 1

                Column {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 16

                    // ═══════════════ 1. Üst Başlık (Display / FIXED BRIGHTNESS) ═══════════════
                    Row {
                        spacing: 12
                        anchors.left: parent.left

                        Text {
                            text: "󰍹"
                            color: shell.theme.accent
                            font.family: shell.fontFamily
                            font.pixelSize: 22
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            spacing: 2
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                text: "Display"
                                color: shell.theme.fg
                                font.family: shell.fontFamily
                                font.pixelSize: 15
                                font.bold: true
                            }

                            Text {
                                text: "FIXED BRIGHTNESS"
                                color: shell.theme.dim
                                font.family: shell.fontFamily
                                font.pixelSize: 10
                                font.bold: true
                                font.letterSpacing: 1
                            }
                        }
                    }

                    // ═══════════════ 2. TEXT SIZE (Metin Boyutu Kademesi) ═══════════════
                    Column {
                        width: parent.width
                        spacing: 8

                        Item {
                            width: parent.width
                            height: 14

                            Text {
                                text: "TEXT SIZE"
                                color: shell.theme.dim
                                font.family: shell.fontFamily
                                font.pixelSize: 10
                                font.bold: true
                                font.letterSpacing: 1
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: root.textSizes[root.selectedTextIndex] + "px"
                                color: shell.theme.dim
                                font.family: shell.fontFamily
                                font.pixelSize: 10
                                font.bold: true
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        // Kademeli Slider Çubuğu
                        Item {
                            id: textSlider
                            width: parent.width
                            height: 16

                            Rectangle {
                                width: parent.width
                                height: 4
                                radius: 2
                                color: shell.theme.surface
                                anchors.verticalCenter: parent.verticalCenter

                                // Fill
                                Rectangle {
                                    height: parent.height
                                    width: (parent.width / (root.textSizes.length - 1)) * root.selectedTextIndex
                                    radius: 2
                                    color: shell.theme.accent
                                }
                            }

                            // Kademeli Çentikler (Notches)
                            Row {
                                anchors.fill: parent
                                Repeater {
                                    model: root.textSizes.length
                                    delegate: Item {
                                        required property int index
                                        width: textSlider.width / (root.textSizes.length - 1)
                                        height: parent.height

                                        Rectangle {
                                            width: 2
                                            height: 6
                                            radius: 1
                                            color: index <= root.selectedTextIndex ? shell.theme.accent : shell.theme.dim
                                            anchors.verticalCenter: parent.verticalCenter
                                            anchors.left: parent.left
                                            visible: index > 0 && index < root.textSizes.length - 1
                                        }
                                    }
                                }
                            }

                            // Knob
                            Rectangle {
                                width: 12
                                height: 12
                                radius: 6
                                color: shell.theme.fg
                                anchors.verticalCenter: parent.verticalCenter
                                x: Math.max(0, Math.min(parent.width - 12, (parent.width / (root.textSizes.length - 1)) * root.selectedTextIndex - 6))
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: function(mouse) {
                                    var stepWidth = width / root.textSizes.length
                                    var idx = Math.max(0, Math.min(root.textSizes.length - 1, Math.floor(mouse.x / stepWidth)))
                                    root.selectedTextIndex = idx
                                }
                            }
                        }
                    }

                    // ═══════════════ 3. SCALE (Canlı Monitör Ölçekleme Butonları) ═══════════════
                    Column {
                        width: parent.width
                        spacing: 8

                        Text {
                            text: "SCALE"
                            color: shell.theme.dim
                            font.family: shell.fontFamily
                            font.pixelSize: 10
                            font.bold: true
                            font.letterSpacing: 1
                        }

                        // 6 Buton Dizisi (Ekran görüntüsündeki gibi: 1x, 1.25x, 1.6x, 2x, 3.2x, 4x)
                        Row {
                            width: parent.width
                            spacing: 4

                            Repeater {
                                model: root.scalePresets
                                delegate: Rectangle {
                                    required property var modelData
                                    required property int index
                                    width: (parent.width - (root.scalePresets.length - 1) * 4) / root.scalePresets.length
                                    height: 32
                                    radius: 6
                                    property bool isActive: root.currentScale === modelData
                                    color: isActive ? shell.theme.surface : (sMouse.containsMouse ? shell.theme.surface : "transparent")
                                    border.color: isActive ? shell.theme.accent : shell.theme.dim
                                    border.width: isActive ? 1 : 1

                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData + "x"
                                        color: parent.isActive ? shell.theme.accent : (sMouse.containsMouse ? shell.theme.fg : shell.theme.dim)
                                        font.family: shell.fontFamily
                                        font.pixelSize: 11
                                        font.bold: parent.isActive
                                    }

                                    MouseArea {
                                        id: sMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: root.applyScale(modelData)
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Item {
                focus: root.opened
                Keys.onEscapePressed: root.opened = false
            }
        }
    }
}
