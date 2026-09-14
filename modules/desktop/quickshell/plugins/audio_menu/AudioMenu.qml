import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pipewire

Item {
    id: root

    property bool opened: false
    property int popupX: 100
    property int popupY: 40
    readonly property int popupWidth: 320
    readonly property int popupHeight: 330

    function openAt(x: int, y: int) {
        shell.closeAllMenus()
        root.popupX = Math.max(10, Math.min(x, 1920 - root.popupWidth - 10))
        root.popupY = Math.max(34, Math.min(y, 1080 - root.popupHeight - 10))
        root.opened = true
    }

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource

    readonly property var candidateSinks: {
        var list = []
        var nodes = Pipewire.nodes ? Pipewire.nodes.values : []
        for (var i = 0; i < nodes.length; i++) {
            var n = nodes[i]
            if (n && n.isSink && !n.isStream) {
                list.push(n)
            }
        }
        return list
    }

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource]
    }
    PwObjectTracker {
        objects: root.candidateSinks
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
                    anchors.margins: 14
                    spacing: 12

                    // Başlık
                    Item {
                        width: parent.width
                        height: 24

                        Row {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 8

                            Text {
                                text: "󰕾"
                                color: shell.theme.accent
                                font.family: shell.fontFamily
                                font.pixelSize: 16
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: "Ses Denetimi"
                                color: shell.theme.fg
                                font.family: shell.fontFamily
                                font.pixelSize: 13
                                font.bold: true
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Rectangle {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            width: 22
                            height: 22
                            radius: 11
                            color: closeMouse.containsMouse ? shell.theme.surface : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: "✕"
                                color: shell.theme.dim
                                font.pixelSize: 10
                            }

                            MouseArea {
                                id: closeMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.opened = false
                            }
                        }
                    }

                    // Çıkış Sesi (Hoparlör / Kulaklık)
                    Column {
                        width: parent.width
                        spacing: 6

                        Item {
                            width: parent.width
                            height: 16

                            Text {
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                text: "Hoparlör / Çıkış"
                                color: shell.theme.dim
                                font.family: shell.fontFamily
                                font.pixelSize: 11
                            }
                            Text {
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                property int volPct: root.sink?.audio?.volume ? Math.round(root.sink.audio.volume * 100) : 0
                                property bool isMuted: root.sink?.audio?.muted ?? false
                                text: isMuted ? "Sessiz" : (volPct + "%")
                                color: isMuted ? "#FF5555" : shell.theme.accent
                                font.family: shell.fontFamily
                                font.pixelSize: 11
                                font.bold: true
                            }
                        }

                        Row {
                            width: parent.width
                            spacing: 8

                            Rectangle {
                                width: 28
                                height: 28
                                radius: 6
                                color: (root.sink?.audio?.muted ?? false) ? "#FF5555" : shell.theme.surface
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    anchors.centerIn: parent
                                    text: (root.sink?.audio?.muted ?? false) ? "󰖁" : "󰕾"
                                    color: (root.sink?.audio?.muted ?? false) ? "#FFFFFF" : shell.theme.fg
                                    font.family: shell.fontFamily
                                    font.pixelSize: 13
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

                            Rectangle {
                                id: outSlider
                                width: parent.width - 36
                                height: 14
                                radius: 7
                                color: shell.theme.surface
                                anchors.verticalCenter: parent.verticalCenter

                                property real currentVol: root.sink?.audio?.volume ?? 0.0

                                Rectangle {
                                    width: Math.max(0, Math.min(outSlider.width, outSlider.width * outSlider.currentVol))
                                    height: parent.height
                                    radius: 7
                                    color: (root.sink?.audio?.muted ?? false) ? shell.theme.dim : shell.theme.accent
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    preventStealing: true
                                    function updateVolume(mouse) {
                                        var ratio = Math.max(0.0, Math.min(1.0, mouse.x / outSlider.width))
                                        if (root.sink && root.sink.audio) {
                                            root.sink.audio.volume = ratio
                                            if (root.sink.audio.muted && ratio > 0) {
                                                root.sink.audio.muted = false
                                            }
                                        }
                                    }
                                    onPressed: updateVolume(mouse)
                                    onPositionChanged: if (pressed) updateVolume(mouse)
                                }
                            }
                        }
                    }

                    // Mikrofon / Giriş
                    Column {
                        width: parent.width
                        spacing: 6
                        visible: root.source !== null

                        Item {
                            width: parent.width
                            height: 16

                            Text {
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                text: "Mikrofon"
                                color: shell.theme.dim
                                font.family: shell.fontFamily
                                font.pixelSize: 11
                            }
                            Text {
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                property int micPct: root.source?.audio?.volume ? Math.round(root.source.audio.volume * 100) : 0
                                property bool isMicMuted: root.source?.audio?.muted ?? false
                                text: isMicMuted ? "Sessiz" : (micPct + "%")
                                color: isMicMuted ? "#FF5555" : shell.theme.accent
                                font.family: shell.fontFamily
                                font.pixelSize: 11
                                font.bold: true
                            }
                        }

                        Row {
                            width: parent.width
                            spacing: 8

                            Rectangle {
                                width: 28
                                height: 28
                                radius: 6
                                color: (root.source?.audio?.muted ?? false) ? "#FF5555" : shell.theme.surface
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    anchors.centerIn: parent
                                    text: (root.source?.audio?.muted ?? false) ? "󰍭" : "󰍬"
                                    color: (root.source?.audio?.muted ?? false) ? "#FFFFFF" : shell.theme.fg
                                    font.family: shell.fontFamily
                                    font.pixelSize: 13
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (root.source && root.source.audio) {
                                            root.source.audio.muted = !root.source.audio.muted
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                id: inSlider
                                width: parent.width - 36
                                height: 14
                                radius: 7
                                color: shell.theme.surface
                                anchors.verticalCenter: parent.verticalCenter

                                property real currentMicVol: root.source?.audio?.volume ?? 0.0

                                Rectangle {
                                    width: Math.max(0, Math.min(inSlider.width, inSlider.width * inSlider.currentMicVol))
                                    height: parent.height
                                    radius: 7
                                    color: (root.source?.audio?.muted ?? false) ? shell.theme.dim : shell.theme.accent
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    preventStealing: true
                                    function updateMic(mouse) {
                                        var ratio = Math.max(0.0, Math.min(1.0, mouse.x / inSlider.width))
                                        if (root.source && root.source.audio) {
                                            root.source.audio.volume = ratio
                                            if (root.source.audio.muted && ratio > 0) {
                                                root.source.audio.muted = false
                                            }
                                        }
                                    }
                                    onPressed: updateMic(mouse)
                                    onPositionChanged: if (pressed) updateMic(mouse)
                                }
                            }
                        }
                    }

                    // Çıkış Aygıtları
                    Column {
                        width: parent.width
                        spacing: 4

                        Text {
                            text: "Aktif Çıkış Aygıtı"
                            color: shell.theme.dim
                            font.family: shell.fontFamily
                            font.pixelSize: 11
                            font.bold: true
                            topPadding: 4
                        }

                        Repeater {
                            model: root.candidateSinks
                            delegate: Rectangle {
                                required property var modelData
                                width: parent.width
                                height: 32
                                radius: 6
                                property bool isDefault: root.sink !== null && modelData.id === root.sink.id
                                color: isDefault ? shell.theme.surface : (devMouse.containsMouse ? shell.theme.surface : "transparent")
                                border.color: isDefault ? shell.theme.accent : "transparent"
                                border.width: 1

                                Row {
                                    anchors.fill: parent
                                    anchors.leftMargin: 8
                                    anchors.rightMargin: 8
                                    spacing: 8

                                    Text {
                                        text: parent.parent.isDefault ? "󰓃" : "󰓄"
                                        color: parent.parent.isDefault ? shell.theme.accent : shell.theme.dim
                                        font.family: shell.fontFamily
                                        font.pixelSize: 12
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Text {
                                        text: modelData.description || modelData.name || "Ses Aygıtı"
                                        color: parent.parent.isDefault ? shell.theme.fg : shell.theme.dim
                                        font.family: shell.fontFamily
                                        font.pixelSize: 11
                                        font.bold: parent.parent.isDefault
                                        elide: Text.ElideRight
                                        width: parent.width - 32
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                MouseArea {
                                    id: devMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        Pipewire.preferredDefaultAudioSink = modelData
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
