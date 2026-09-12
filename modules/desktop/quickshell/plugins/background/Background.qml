import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

PanelWindow {
    id: root
    anchors { top: true; bottom: true; left: true; right: true }
    color: shell.theme.bg

    WlrLayershell.layer: WlrLayer.Background

    Item {
        anchors.fill: parent
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: function(mouse) {
                if (mouse.button === Qt.RightButton) {
                    Quickshell.ipc.call("default", "themeMenu", "openAt", [mouse.x, mouse.y])
                }
            }
        }
    }
}
