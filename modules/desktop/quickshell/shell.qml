//@ pragma UseQApplication
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Pipewire

// Xmarchy Desktop Shell
ShellRoot {
    id: shell

    // State Directory (Impermanence ile /persist/system'e bağlanacak)
    readonly property string stateFile: "/var/lib/xmarchy/current-theme.json"
    
    // Varsayılan tema (fallback)
    property string currentThemeName: "xmarchy-dark"
    property var theme: ({bg: "#000000", fg: "#FFFFFF", dim: "#666666", accent: "#FFFFFF"})

    readonly property int barHeight: 28
    readonly property string fontFamily: "JetBrains Mono"

    // Tema Değiştirme Fonksiyonu
    function applyTheme(name: string) {
        currentThemeName = name
        
        // Quickshell'in kendi içindeki renkleri değiştir
        var path = Quickshell.env("XMARCHY_QS_DIR") + "/themes/" + name + ".json"
        // (Gerçek hayatta burada dosya okuma yapılır, biz mockluyoruz)
        var themes = {
            "xmarchy-dark": {bg: "#000000", fg: "#FFFFFF", dim: "#666666", accent: "#FFFFFF"},
            "xmarchy-light": {bg: "#FFFFFF", fg: "#000000", dim: "#999999", accent: "#000000"},
            "hackerman": {bg: "#0D1117", fg: "#00FF41", dim: "#008F11", accent: "#00FF41"},
            "rose-pine": {bg: "#191724", fg: "#e0def4", dim: "#6e6a86", accent: "#c4a7e7"},
            "vantablack": {bg: "#050505", fg: "#888888", dim: "#333333", accent: "#aaaaaa"}
        }
        theme = themes[name]

        // Dış sistemleri (Hyprland, Kitty, Tmux) anında güncellemek için CLI aracını tetikle
        var proc = Quickshell.process(["xmarchy-theme-apply", name, theme.bg, theme.fg])
    }

    // Başlangıçta temayı yükle
    Component.onCompleted: {
        // Gerçekte stateFile okunur. Biz şimdilik bash scriptinin yapmasını bekleyeceğiz.
    }

    PwObjectTracker { objects: [Pipewire.defaultAudioSink] }

    // ═══════════ Masaüstü Bileşenleri ═══════════
    Variants {
        model: Quickshell.screens
        delegate: Background {
            required property var modelData
            screen: modelData
        }
    }

    Variants {
        model: Quickshell.screens
        delegate: Bar {
            required property var modelData
            screen: modelData
        }
    }

    Osd { id: osd }
    Notifications { id: notifications }
    Launcher { id: launcher }
    Lock { id: lock }
    ThemeMenu { id: themeMenu }

    // ═══════════ IPC Kontrolleri ═══════════
    IpcHandler { target: "osd"; function show(icon: string, value: int) { osd.show(icon, value) } }
    IpcHandler { target: "launcher"; function toggle() { launcher.toggle() } }
    IpcHandler { target: "theme"; function apply(name: string) { shell.applyTheme(name) } }
}
