//@ pragma UseQApplication
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Pipewire

// Xmarchy Brutalist Desktop Shell
ShellRoot {
    id: shell

    // Brutalist Renk Sistemi
    readonly property string bg: "#000000"
    readonly property string fg: "#FFFFFF"
    readonly property string dim: "#666666"
    readonly property string accent: "#FFFFFF"
    readonly property int barHeight: 28
    readonly property string fontFamily: "JetBrains Mono"

    // Pipewire Ses Servisi
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    // Her ekran için Bar paneli
    Variants {
        model: Quickshell.screens
        delegate: Bar {
            required property var modelData
            screen: modelData
        }
    }

    // OSD (Ses/Parlaklık göstergesi)
    Osd { id: osd }

    // IPC: Dışarıdan komutlarla shell'i kontrol etme
    IpcHandler {
        target: "osd"
        function show(icon: string, value: int) {
            osd.show(icon, value)
        }
    }
}
