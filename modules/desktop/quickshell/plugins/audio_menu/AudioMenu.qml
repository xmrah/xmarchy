import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pipewire

Item {
    id: root

    property bool opened: false
    property int popupX: 100
    property int popupY: 40
    readonly property int popupWidth: 360
    readonly property int popupHeight: 300

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

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource]
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

                    // ═══════════════ 1. Üst Başlık & Master Mute Switch ═══════════════
                    RowLayout {
                        width: parent.width

                        Row {
                            spacing: 12
                            Layout.alignment: Qt.AlignVCenter

                            Text {
                                text: (root.sink?.audio?.muted ?? false) ? "󰖁" : "󰕾"
                                color: (root.sink?.audio?.muted ?? false) ? "#f38ba8" : shell.theme.accent
                                font.family: shell.fontFamily
                                font.pixelSize: 22
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Column {
                                spacing: 2
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    text: "Audio"
                                    color: shell.theme.fg
                                    font.family: shell.fontFamily
                                    font.pixelSize: 15
                                    font.bold: true
                                }

                                Text {
                                    text: (root.sink?.audio?.muted ?? false) ? "MUTED" : "ACTIVE"
                                    color: (root.sink?.audio?.muted ?? false) ? "#f38ba8" : shell.theme.dim
                                    font.family: shell.fontFamily
                                    font.pixelSize: 10
                                    font.bold: true
                                    font.letterSpacing: 1
                                }
                            }
                        }

                        Item { Layout.fillWidth: true }

                        // Master Toggle Switch (Ekran görüntüsündeki sağ üst düğme)
                        Rectangle {
                            Layout.alignment: Qt.AlignVCenter
                            width: 44
                            height: 24
                            radius: 12
                            color: !(root.sink?.audio?.muted ?? false) ? shell.theme.accent : shell.theme.surface
                            border.color: !(root.sink?.audio?.muted ?? false) ? shell.theme.accent : shell.theme.dim
                            border.width: 1

                            Behavior on color { ColorAnimation { duration: 150 } }

                            // Switch Thumb
                            Rectangle {
                                width: 18
                                height: 18
                                radius: 9
                                color: !(root.sink?.audio?.muted ?? false) ? shell.theme.bg : shell.theme.dim
                                anchors.verticalCenter: parent.verticalCenter
                                x: !(root.sink?.audio?.muted ?? false) ? 22 : 4

                                Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (root.sink && root.sink.audio) {
                                        root.sink.audio.muted = !root.sink.audio.muted
                                    }
                                }
                            }
                        }
                    }

                    // ═══════════════ 2. OUTPUT (Çıkış / Hoparlör) ═══════════════
                    Column {
                        width: parent.width
                        spacing: 8

                        // Başlık ve Yüzde
                        Item {
                            width: parent.width
                            height: 14

                            Text {
                                text: "OUTPUT"
                                color: shell.theme.dim
                                font.family: shell.fontFamily
                                font.pixelSize: 10
                                font.bold: true
                                font.letterSpacing: 1
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                property int volPct: root.sink?.audio?.volume ? Math.round(root.sink.audio.volume * 100) : 0
                                text: volPct + "%"
                                color: shell.theme.dim
                                font.family: shell.fontFamily
                                font.pixelSize: 10
                                font.bold: true
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        // Slider (Track + Knob)
                        Item {
                            id: outSliderTrack
                            width: parent.width
                            height: 18

                            property real ratio: root.sink?.audio?.volume ?? 0.0

                            // Track Bar
                            Rectangle {
                                width: parent.width
                                height: 4
                                radius: 2
                                color: shell.theme.surface
                                anchors.verticalCenter: parent.verticalCenter

                                // Fill
                                Rectangle {
                                    height: parent.height
                                    width: Math.max(0, Math.min(parent.width, parent.width * outSliderTrack.ratio))
                                    radius: 2
                                    color: (root.sink?.audio?.muted ?? false) ? shell.theme.dim : shell.theme.accent
                                }
                            }

                            // Knob
                            Rectangle {
                                width: 12
                                height: 12
                                radius: 6
                                color: shell.theme.fg
                                anchors.verticalCenter: parent.verticalCenter
                                x: Math.max(0, Math.min(parent.width - 12, (parent.width - 12) * outSliderTrack.ratio))
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                preventStealing: true
                                function setVol(m) {
                                    var r = Math.max(0.0, Math.min(1.0, m.x / parent.width))
                                    if (root.sink && root.sink.audio) {
                                        root.sink.audio.volume = r
                                        if (root.sink.audio.muted && r > 0) {
                                            root.sink.audio.muted = false
                                        }
                                    }
                                }
                                onPressed: setVol(mouse)
                                onPositionChanged: if (pressed) setVol(mouse)
                            }
                        }

                        // Çıkış Aygıtı Hapı (Pill)
                        Rectangle {
                            width: parent.width
                            height: 32
                            radius: 6
                            color: shell.theme.surface
                            border.color: shell.theme.dim
                            border.width: 1

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                spacing: 8

                                Text {
                                    text: "󰓃"
                                    color: shell.theme.accent
                                    font.family: shell.fontFamily
                                    font.pixelSize: 13
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    text: root.sink?.description || root.sink?.name || "Generic Analog"
                                    color: shell.theme.fg
                                    font.family: shell.fontFamily
                                    font.pixelSize: 11
                                    font.bold: true
                                    elide: Text.ElideRight
                                    width: parent.width - 32
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }
                    }

                    // ═══════════════ 3. INPUT (Giriş / Mikrofon) ═══════════════
                    Column {
                        width: parent.width
                        spacing: 8

                        // Başlık ve Yüzde
                        Item {
                            width: parent.width
                            height: 14

                            Text {
                                text: "INPUT"
                                color: shell.theme.dim
                                font.family: shell.fontFamily
                                font.pixelSize: 10
                                font.bold: true
                                font.letterSpacing: 1
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                property int micPct: root.source?.audio?.volume ? Math.round(root.source.audio.volume * 100) : 0
                                text: micPct + "%"
                                color: shell.theme.dim
                                font.family: shell.fontFamily
                                font.pixelSize: 10
                                font.bold: true
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        // Slider (Track + Knob)
                        Item {
                            id: inSliderTrack
                            width: parent.width
                            height: 18

                            property real micRatio: root.source?.audio?.volume ?? 0.0

                            // Track Bar
                            Rectangle {
                                width: parent.width
                                height: 4
                                radius: 2
                                color: shell.theme.surface
                                anchors.verticalCenter: parent.verticalCenter

                                // Fill
                                Rectangle {
                                    height: parent.height
                                    width: Math.max(0, Math.min(parent.width, parent.width * inSliderTrack.micRatio))
                                    radius: 2
                                    color: (root.source?.audio?.muted ?? false) ? shell.theme.dim : shell.theme.accent
                                }
                            }

                            // Knob
                            Rectangle {
                                width: 12
                                height: 12
                                radius: 6
                                color: shell.theme.fg
                                anchors.verticalCenter: parent.verticalCenter
                                x: Math.max(0, Math.min(parent.width - 12, (parent.width - 12) * inSliderTrack.micRatio))
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                preventStealing: true
                                function setMic(m) {
                                    var r = Math.max(0.0, Math.min(1.0, m.x / parent.width))
                                    if (root.source && root.source.audio) {
                                        root.source.audio.volume = r
                                        if (root.source.audio.muted && r > 0) {
                                            root.source.audio.muted = false
                                        }
                                    }
                                }
                                onPressed: setMic(mouse)
                                onPositionChanged: if (pressed) setMic(mouse)
                            }
                        }

                        // Giriş Aygıtı Hapı (Pill)
                        Rectangle {
                            width: parent.width
                            height: 32
                            radius: 6
                            color: shell.theme.surface
                            border.color: shell.theme.dim
                            border.width: 1

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                spacing: 8

                                Text {
                                    text: "󰍬"
                                    color: shell.theme.accent
                                    font.family: shell.fontFamily
                                    font.pixelSize: 13
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    text: root.source?.description || root.source?.name || "Generic Analog"
                                    color: shell.theme.fg
                                    font.family: shell.fontFamily
                                    font.pixelSize: 11
                                    font.bold: true
                                    elide: Text.ElideRight
                                    width: parent.width - 32
                                    anchors.verticalCenter: parent.verticalCenter
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
