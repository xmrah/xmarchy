//@ pragma UseQApplication
import Quickshell
import Quickshell.Io
import "Ui"
import "services"
import "plugins"

// Xmarchy Brutalist Shell Root
ShellRoot {
    id: root

    // Brutalist Renk Paleti (Saf Siyah / Beyaz)
    property string colorBg: "#000000"
    property string colorFg: "#FFFFFF"
    property int borderW: 1

    // Ana Ekranlar için Bar Bileşeni
    Variants {
        model: Quickshell.screens
        delegate: Rectangle {
            required property var modelData
            // Şimdilik test için siyah bir bar (İleride Ui/Bar.qml olacak)
            color: root.colorBg
            border.color: root.colorFg
            border.width: root.borderW
            height: 30
            width: modelData.width
        }
    }

    // İleride eklenecek bileşenler:
    // Dashboard {}
    // Osd {}
}
