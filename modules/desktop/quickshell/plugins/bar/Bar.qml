import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Pipewire

// Xmarchy Brutalist Bar
WlrLayershell {
    id: bar

    anchors { top: true; left: true; right: true }
    exclusiveZone: shell.barHeight
    height: shell.barHeight
    color: shell.bg

    WlrLayer.layer: WlrLayer.Top

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        spacing: 0

        // ═══════════════ SOL: Workspace Göstergeleri ═══════════════
        Repeater {
            model: 9
            delegate: Rectangle {
                required property int index
                property int wsId: index + 1
                property bool active: Hyprland.workspaces.values.some(
                    function(ws) { return ws.id === wsId }
                )
                property bool focused: Hyprland.focusedMonitor?.activeWorkspace?.id === wsId

                Layout.preferredWidth: shell.barHeight - 8
                Layout.preferredHeight: shell.barHeight - 8
                Layout.alignment: Qt.AlignVCenter

                color: focused ? shell.fg : (active ? shell.dim : "transparent")
                border.color: active ? shell.fg : shell.dim
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: parent.wsId
                    color: parent.focused ? shell.bg : shell.fg
                    font.family: shell.fontFamily
                    font.pixelSize: 10
                    font.bold: parent.focused
                }
            }
        }

        // ═══════════════ ORTA: Saat ═══════════════
        Item { Layout.fillWidth: true }

        Text {
            id: clock
            Layout.alignment: Qt.AlignCenter
            color: shell.fg
            font.family: shell.fontFamily
            font.pixelSize: 13
            font.bold: true

            // SystemClock ile her dakika güncelle
            property var now: new Date()
            text: Qt.formatDateTime(now, "dddd HH:mm")

            Timer {
                running: true
                repeat: true
                interval: 10000
                onTriggered: clock.now = new Date()
            }
        }

        Item { Layout.fillWidth: true }

        // ═══════════════ SAĞ: Ses Seviyesi ═══════════════
        Text {
            Layout.alignment: Qt.AlignVCenter
            color: shell.fg
            font.family: shell.fontFamily
            font.pixelSize: 11

            property var sink: Pipewire.defaultAudioSink
            property int vol: sink?.audio?.volume ? Math.round(sink.audio.volume * 100) : 0
            property bool muted: sink?.audio?.muted ?? false
            text: muted ? "MUTE" : "VOL " + vol + "%"
        }
    }

    // Alt kenar çizgisi (1px beyaz)
    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: shell.fg
    }
}
