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

    readonly property string stateFile: "/var/lib/xmarchy/current-theme.json"
    
    // Varsayılan tema (Premium Modern Koyu Tema)
    property string currentThemeName: "xmarchy-dark"
    property var themes: ({
        "xmarchy-dark": {
            bg: "#0f111a",
            surface: "#1a1c2b",
            fg: "#c0caf5",
            dim: "#565f89",
            accent: "#7aa2f7",
            accent2: "#bb9af7"
        },
        "catppuccin": {
            bg: "#1e1e2e",
            surface: "#25273a",
            fg: "#cdd6f4",
            dim: "#6c7086",
            accent: "#cba6f7",
            accent2: "#89b4fa"
        },
        "rose-pine": {
            bg: "#191724",
            surface: "#21202e",
            fg: "#e0def4",
            dim: "#6e6a86",
            accent: "#ebbcba",
            accent2: "#c4a7e7"
        },
        "nord": {
            bg: "#242933",
            surface: "#2e3440",
            fg: "#eceff4",
            dim: "#768299",
            accent: "#88c0d0",
            accent2: "#81a1c1"
        },
        "cyberpunk": {
            bg: "#0b0e14",
            surface: "#151924",
            fg: "#e6e6e6",
            dim: "#4d5b70",
            accent: "#00f0ff",
            accent2: "#ff0055"
        },
        "xmarchy-light": {
            bg: "#f2f4f8",
            surface: "#ffffff",
            fg: "#1e2030",
            dim: "#8990a2",
            accent: "#3b82f6",
            accent2: "#8b5cf6"
        }
    })

    property var theme: themes[currentThemeName]

    readonly property int barHeight: 34
    readonly property string fontFamily: "JetBrainsMono Nerd Font"

    // Tema CLI aracını çalıştırmak için Process{} bileşeni (Quickshell.Io)
    Process {
        id: themeProcess
        running: false
    }

    // Tema Değiştirme Fonksiyonu
    function applyTheme(name: string) {
        if (!themes[name]) return;
        currentThemeName = name;
        theme = themes[name];

        // Hyprland ve sistem renklerini CLI üzerinden güncelle
        themeProcess.command = ["xmarchy-theme-apply", name, theme.bg, theme.accent];
        themeProcess.running = true;
    }

    // Tüm açılır panelleri kapatma fonksiyonu
    function closeAllMenus() {
        if (themeMenu) themeMenu.opened = false;
        if (audioMenu) audioMenu.opened = false;
        if (networkMenu) networkMenu.opened = false;
        if (bluetoothMenu) bluetoothMenu.opened = false;
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
    AudioMenu { id: audioMenu }
    NetworkMenu { id: networkMenu }
    BluetoothMenu { id: bluetoothMenu }
    PowerMenu { id: powerMenu }

    property alias themeMenu: themeMenu
    property alias launcher: launcher
    property alias lock: lock
    property alias osd: osd
    property alias audioMenu: audioMenu
    property alias networkMenu: networkMenu
    property alias bluetoothMenu: bluetoothMenu
    property alias powerMenu: powerMenu

    // ═══════════ IPC Kontrolleri ═══════════
    IpcHandler { target: "osd"; function show(icon: string, value: int) { osd.show(icon, value) } }
    IpcHandler { target: "launcher"; function toggle() { launcher.toggle() } }
    IpcHandler { target: "theme"; function apply(name: string) { shell.applyTheme(name) } }
    IpcHandler { target: "power"; function open() { powerMenu.open() } }
    // Not: "themeMenu" IPC handler ThemeMenu.qml icerisinde tanimli
    // Not: "lock" IPC handler Lock.qml icerisinde tanimli
}
