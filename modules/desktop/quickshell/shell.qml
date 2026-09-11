//@ pragma UseQApplication
import Quickshell
import Quickshell.Wayland

// Xmarchy Brutalist Shell
ShellRoot {
    id: root

    // Brutalist Renk Paleti (Saf Siyah / Beyaz)
    readonly property string colorBg: "#000000"
    readonly property string colorFg: "#FFFFFF"

    // Her ekran için Bar paneli
    Variants {
        model: Quickshell.screens
        delegate: WlrLayershell {
            required property var modelData
            screen: modelData
            anchors { top: true; left: true; right: true }
            exclusiveZone: 24
            height: 24
            color: root.colorBg
        }
    }
}
