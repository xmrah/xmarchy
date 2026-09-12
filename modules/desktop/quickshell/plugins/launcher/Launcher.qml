import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io

// Xmarchy App Launcher
Item {
    id: root

    property bool opened: false
    property string query: ""
    property var results: []

    function toggle() {
        if (root.opened) {
            root.opened = false
            root.query = ""
            root.results = []
        } else {
            root.opened = true
            searchInput.forceActiveFocus()
        }
    }

    function search(q) {
        root.query = q
        if (q.length === 0) { root.results = []; return }
        var apps = Quickshell.desktopEntries.applications
        root.results = apps.filter(function(app) {
            return app.name.toLowerCase().indexOf(q.toLowerCase()) >= 0
        }).slice(0, 8)
    }

    function launch(entry) {
        entry.launch()
        root.toggle()
    }

    WlrLayershell {
        visible: root.opened
        anchors { top: true; left: true; right: true; bottom: true }
        exclusiveZone: -1
        color: Qt.rgba(0, 0, 0, 0.85)

        WlrLayer.layer: WlrLayer.Overlay
        WlrLayer.keyboardFocus: WlrLayer.Exclusive

        // Arka plana tıklayınca kapat
        MouseArea {
            anchors.fill: parent
            onClicked: root.toggle()
        }

        // Merkez arama kutusu
        Column {
            anchors.centerIn: parent
            width: 400
            spacing: 0

            // Arama alanı
            Rectangle {
                width: parent.width
                height: 48
                color: shell.theme.bg
                border.color: shell.theme.fg
                border.width: 1

                TextInput {
                    id: searchInput
                    anchors { fill: parent; margins: 12 }
                    color: shell.theme.fg
                    font.family: shell.fontFamily
                    font.pixelSize: 16
                    clip: true
                    onTextChanged: root.search(text)

                    Keys.onEscapePressed: root.toggle()
                    Keys.onReturnPressed: {
                        if (root.results.length > 0) root.launch(root.results[0])
                    }
                }

                // Placeholder
                Text {
                    visible: searchInput.text.length === 0
                    anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 12 }
                    text: "Search..."
                    color: shell.theme.dim
                    font.family: shell.fontFamily
                    font.pixelSize: 16
                }
            }

            // Sonuçlar
            Repeater {
                model: root.results
                delegate: Rectangle {
                    required property var modelData
                    required property int index
                    width: 400
                    height: 40
                    color: index === 0 ? shell.theme.fg : shell.theme.bg
                    border.color: shell.theme.fg
                    border.width: 1

                    Text {
                        anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 12 }
                        text: modelData.name
                        color: index === 0 ? shell.theme.bg : shell.theme.fg
                        font.family: shell.fontFamily
                        font.pixelSize: 13
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.launch(modelData)
                    }
                }
            }
        }
    }
}
