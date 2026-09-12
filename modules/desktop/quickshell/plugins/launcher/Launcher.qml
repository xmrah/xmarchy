import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
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
            searchInput.forceActiveFocus()
        }
    }

    function search(q) {
        root.query = q
        root.selectedIndex = 0
        if (q.length === 0) {
            root.results = []
            return
        }
        var apps = Quickshell.desktopEntries.applications
        root.results = apps.filter(function(app) {
            return (app.name && app.name.toLowerCase().indexOf(q.toLowerCase()) >= 0) ||
                   (app.genericName && app.genericName.toLowerCase().indexOf(q.toLowerCase()) >= 0)
        }).slice(0, 8)
    }

    function launch(entry) {
        if (entry) {
            entry.launch()
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
                width: 480
                height: Math.min(520, searchBox.height + (root.results.length > 0 ? (root.results.length * 48 + 24) : 16))
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
                                    text: "Uygulama ara..."
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
                                height: 42
                                radius: 6
                                color: index === root.selectedIndex ? shell.theme.accent : (mouseArea.containsMouse ? shell.theme.surface : "transparent")

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 12
                                    spacing: 10

                                    Text {
                                        text: "󰣆"
                                        color: index === root.selectedIndex ? shell.theme.bg : shell.theme.accent
                                        font.family: shell.fontFamily
                                        font.pixelSize: 14
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
                                            font.bold: index === root.selectedIndex
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
