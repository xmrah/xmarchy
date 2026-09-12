import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

Item {
    id: root

    property bool opened: false
    property int popupX: 100
    property int popupY: 100
    property var themeList: ["xmarchy-dark", "catppuccin", "rose-pine", "nord", "cyberpunk", "xmarchy-light"]
    property int selectedIndex: 0

    function openAt(x: int, y: int) {
        root.popupX = Math.max(10, Math.min(x, 1920 - 240))
        root.popupY = Math.max(34, Math.min(y, 1080 - (root.themeList.length * 44 + 30)))
        root.opened = true
        root.selectedIndex = root.themeList.indexOf(shell.currentThemeName)
    }

    function applyTheme(name: string) {
        shell.applyTheme(name)
        root.opened = false
    }

    PanelWindow {
        visible: root.opened
        anchors { top: true; bottom: true; left: true; right: true }
        exclusiveZone: -1
        color: "transparent"
        
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        Item {
            anchors.fill: parent

            MouseArea {
                anchors.fill: parent
                onClicked: root.opened = false
            }

            Rectangle {
                x: root.popupX
                y: root.popupY
                width: 220
                height: root.themeList.length * 42 + 40
                radius: 10
                color: shell.theme.bg
                border.color: shell.theme.accent
                border.width: 1

                Column {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 4

                    Text {
                        text: "Tema Seçimi"
                        color: shell.theme.dim
                        font.family: shell.fontFamily
                        font.pixelSize: 11
                        font.bold: true
                        anchors.horizontalCenter: parent.horizontalCenter
                        topPadding: 4
                        bottomPadding: 4
                    }

                    Repeater {
                        model: root.themeList
                        delegate: Rectangle {
                            required property var modelData
                            required property int index
                            width: parent.width
                            height: 36
                            radius: 6
                            color: index === root.selectedIndex ? shell.theme.accent : (tMouse.containsMouse ? shell.theme.surface : "transparent")

                            property var themeDef: shell.themes[modelData]

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                spacing: 8

                                // Tema Renk Önizleme Noktaları
                                Rectangle {
                                    width: 12
                                    height: 12
                                    radius: 6
                                    color: parent.parent.themeDef?.bg ?? "#000000"
                                    border.color: parent.parent.themeDef?.accent ?? "#ffffff"
                                    border.width: 2
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    text: modelData
                                    color: index === root.selectedIndex ? shell.theme.bg : shell.theme.fg
                                    font.family: shell.fontFamily
                                    font.pixelSize: 12
                                    font.bold: index === root.selectedIndex
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                id: tMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: root.selectedIndex = index
                                onClicked: root.applyTheme(modelData)
                            }
                        }
                    }
                }
            }

            Item {
                focus: root.opened
                Keys.onEscapePressed: root.opened = false
                Keys.onUpPressed: root.selectedIndex = (root.selectedIndex - 1 + root.themeList.length) % root.themeList.length
                Keys.onDownPressed: root.selectedIndex = (root.selectedIndex + 1) % root.themeList.length
                Keys.onReturnPressed: root.applyTheme(root.themeList[root.selectedIndex])
            }
        }
    }

    IpcHandler {
        target: "themeMenu"
        function openAt(x: int, y: int) {
            root.openAt(x, y)
        }
    }
}
