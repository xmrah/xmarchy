import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

// Xmarchy Sağ Tık Tema Seçici
Item {
    id: root

    property bool opened: false
    property int popupX: 0
    property int popupY: 0
    property var themeList: ["xmarchy-dark", "xmarchy-light", "hackerman", "rose-pine", "vantablack"]
    property int selectedIndex: 0

    function openAt(x: int, y: int) {
        root.popupX = x
        root.popupY = y
        root.opened = true
        root.selectedIndex = root.themeList.indexOf(shell.currentThemeName)
    }

    function applyTheme(name: string) {
        shell.applyTheme(name)
        root.opened = false
    }

    WlrLayershell {
        visible: root.opened
        anchors.fill: parent
        exclusiveZone: -1
        color: "transparent"
        
        WlrLayer.layer: WlrLayer.Overlay
        WlrLayer.keyboardFocus: WlrLayer.Exclusive

        // Kapatmak için arka plan
        MouseArea {
            anchors.fill: parent
            onClicked: root.opened = false
        }

        // Menü Kutusu
        Rectangle {
            x: root.popupX
            y: root.popupY
            width: 200
            height: root.themeList.length * 40
            color: shell.theme.bg
            border.color: shell.theme.fg
            border.width: 1

            Column {
                anchors.fill: parent
                Repeater {
                    model: root.themeList
                    delegate: Rectangle {
                        width: 200
                        height: 40
                        color: index === root.selectedIndex ? shell.theme.fg : "transparent"
                        
                        Text {
                            anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 12 }
                            text: modelData
                            color: index === root.selectedIndex ? shell.theme.bg : shell.theme.fg
                            font.family: shell.fontFamily
                            font.pixelSize: 13
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: root.selectedIndex = index
                            onClicked: root.applyTheme(modelData)
                        }
                    }
                }
            }
        }

        // Klavye ile gezinme
        Item {
            focus: root.opened
            Keys.onEscapePressed: root.opened = false
            Keys.onUpPressed: root.selectedIndex = Math.max(0, root.selectedIndex - 1)
            Keys.onDownPressed: root.selectedIndex = Math.min(root.themeList.length - 1, root.selectedIndex + 1)
            Keys.onReturnPressed: root.applyTheme(root.themeList[root.selectedIndex])
        }
    }

    IpcHandler {
        target: "themeMenu"
        function openAt(x: int, y: int) {
            root.openAt(x, y)
        }
    }
}
