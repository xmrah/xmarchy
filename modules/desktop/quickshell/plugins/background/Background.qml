import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

// Xmarchy Masaüstü Zemini
WlrLayershell {
    id: root
    anchors.fill: parent
    exclusiveZone: -1
    color: shell.theme.bg

    WlrLayer.layer: WlrLayer.Background
    WlrLayer.keyboardFocus: WlrLayer.None

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        
        onClicked: function(mouse) {
            if (mouse.button === Qt.RightButton) {
                Quickshell.ipc.call("default", "themeMenu", "openAt", [mouse.x, mouse.y])
            } else if (mouse.button === Qt.LeftButton) {
                // TODO: Wallpaper menüsü
            }
        }
    }
}
