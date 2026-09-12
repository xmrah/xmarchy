import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

PanelWindow {
    id: root
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Background

    Item {
        anchors.fill: parent

        // 1. Zengin Arka Plan Gradyanı
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { position: 0.0; color: shell.theme.bg }
                GradientStop { position: 0.6; color: shell.theme.surface }
                GradientStop { position: 1.0; color: shell.theme.bg }
            }
        }

        // 2. Ortada Zarif Radyal Işıltı (Accent Glow)
        Rectangle {
            width: Math.min(parent.width, parent.height) * 0.8
            height: width
            radius: width / 2
            anchors.centerIn: parent
            color: shell.theme.accent
            opacity: 0.05
        }

        // 3. Zarif Xmarchy Tipografi / Marka Vurgusu
        Column {
            anchors.centerIn: parent
            spacing: 8
            opacity: 0.35

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "X M A R C H Y"
                color: shell.theme.fg
                font.family: shell.fontFamily
                font.pixelSize: 28
                font.letterSpacing: 8
                font.bold: true
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Declarative Sovereign Desktop"
                color: shell.theme.accent
                font.family: shell.fontFamily
                font.pixelSize: 12
                font.letterSpacing: 2
            }
        }

        // 4. Sağ Tık Etkileşimi -> Doğrudan Tema Menüsünü Açar
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.RightButton
            onClicked: function(mouse) {
                shell.themeMenu.openAt(mouse.x, mouse.y)
            }
        }
    }
}
