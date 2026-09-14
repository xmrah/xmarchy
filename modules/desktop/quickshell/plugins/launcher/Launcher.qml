import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import Quickshell.Io

Item {
    id: root

    property bool opened: false
    property string query: ""
    property var results: []
    property int selectedIndex: 0

    function toggle() {
        if (root.opened) {
            root.opened = false
            root.query = ""
            root.results = []
            root.selectedIndex = 0
        } else {
            root.opened = true
            root.selectedIndex = 0
            searchInput.text = ""
            search("")
            searchInput.forceActiveFocus()
        }
    }

    function search(q) {
        root.query = q
        root.selectedIndex = 0
        var apps = DesktopEntries.applications.values
        if (q.length === 0) {
            // İlk açılışta boş kalmasın; mevcut sistem uygulamalarını listele
            root.results = apps.slice(0, 8)
            return
        }
        root.results = apps.filter(function(app) {
            return (app.name && app.name.toLowerCase().indexOf(q.toLowerCase()) >= 0) ||
                   (app.genericName && app.genericName.toLowerCase().indexOf(q.toLowerCase()) >= 0)
        }).slice(0, 8)
    }

    function launch(entry) {
        if (entry) {
            entry.execute()
        }
        root.toggle()
    }

    PanelWindow {
        visible: root.opened
        anchors { top: true; left: true; right: true; bottom: true }
        exclusiveZone: -1
        color: Qt.rgba(0, 0, 0, 0.65)

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        Item {
            anchors.fill: parent

            MouseArea {
                anchors.fill: parent
                onClicked: root.toggle()
            }

            Rectangle {
                anchors.centerIn: parent
                width: 500
                height: Math.min(540, searchBox.height + (root.results.length > 0 ? (root.results.length * 52 + 24) : 16))
                radius: 12
                color: shell.theme.bg
                border.color: shell.theme.accent
                border.width: 1

                Behavior on height { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

                Column {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    // Arama Kutusu
                    Rectangle {
                        id: searchBox
                        width: parent.width
                        height: 44
                        radius: 8
                        color: shell.theme.surface
                        border.color: searchInput.activeFocus ? shell.theme.accent : shell.theme.dim
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 8

                            Text {
                                text: "󰍉"
                                color: shell.theme.accent
                                font.pixelSize: 16
                                font.family: shell.fontFamily
                                Layout.alignment: Qt.AlignVCenter
                            }

                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                TextInput {
                                    id: searchInput
                                    anchors.fill: parent
                                    verticalAlignment: TextInput.AlignVCenter
                                    color: shell.theme.fg
                                    font.family: shell.fontFamily
                                    font.pixelSize: 14
                                    clip: true
                                    onTextChanged: root.search(text)

                                    Keys.onEscapePressed: root.toggle()
                                    Keys.onDownPressed: {
                                        if (root.results.length > 0) {
                                            root.selectedIndex = (root.selectedIndex + 1) % root.results.length
                                        }
                                    }
                                    Keys.onUpPressed: {
                                        if (root.results.length > 0) {
                                            root.selectedIndex = (root.selectedIndex - 1 + root.results.length) % root.results.length
                                        }
                                    }
                                    Keys.onReturnPressed: {
                                        if (root.results.length > 0) {
                                            root.launch(root.results[root.selectedIndex])
                                        }
                                    }
                                }

                                Text {
                                    visible: searchInput.text.length === 0
                                    anchors.fill: parent
                                    verticalAlignment: Text.AlignVCenter
                                    text: "Uygulama ara veya seç..."
                                    color: shell.theme.dim
                                    font.family: shell.fontFamily
                                    font.pixelSize: 14
                                }
                            }
                        }
                    }

                    // Sonuçlar Listesi
                    Column {
                        width: parent.width
                        spacing: 4
                        visible: root.results.length > 0

                        Repeater {
                            model: root.results
                            delegate: Rectangle {
                                required property var modelData
                                required property int index
                                width: parent.width
                                height: 48
                                radius: 8
                                color: index === root.selectedIndex ? shell.theme.accent : (mouseArea.containsMouse ? shell.theme.surface : "transparent")

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 12
                                    spacing: 12

                                    IconImage {
                                        id: appIcon
                                        width: 24
                                        height: 24
                                        source: modelData.icon ? Quickshell.iconPath(modelData.icon) : ""
                                        visible: status === Image.Ready
                                        Layout.alignment: Qt.AlignVCenter
                                    }

                                    Text {
                                        visible: !appIcon.visible
                                        text: "󰣆"
                                        color: index === root.selectedIndex ? shell.theme.bg : shell.theme.accent
                                        font.family: shell.fontFamily
                                        font.pixelSize: 16
                                        Layout.alignment: Qt.AlignVCenter
                                    }

                                    Column {
                                        Layout.fillWidth: true
                                        Layout.alignment: Qt.AlignVCenter
                                        spacing: 2

                                        Text {
                                            text: modelData.name ?? "Bilinmeyen"
                                            color: index === root.selectedIndex ? shell.theme.bg : shell.theme.fg
                                            font.family: shell.fontFamily
                                            font.pixelSize: 13
                                            font.bold: true
                                            elide: Text.ElideRight
                                            width: parent.width
                                        }

                                        Text {
                                            visible: modelData.genericName ? true : false
                                            text: modelData.genericName ?? ""
                                            color: index === root.selectedIndex ? "#2a2b36" : shell.theme.dim
                                            font.family: shell.fontFamily
                                            font.pixelSize: 10
                                            elide: Text.ElideRight
                                            width: parent.width
                                        }
                                    }
                                }

                                MouseArea {
                                    id: mouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onEntered: root.selectedIndex = index
                                    onClicked: root.launch(modelData)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
