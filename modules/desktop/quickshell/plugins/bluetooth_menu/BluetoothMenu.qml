import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Bluetooth

Item {
    id: root

    property bool opened: false
    property int popupX: 100
    property int popupY: 40
    readonly property int popupWidth: 320
    readonly property int popupHeight: 380

    function openAt(x: int, y: int) {
        shell.closeAllMenus()
        root.popupX = Math.max(10, Math.min(x, 1920 - root.popupWidth - 10))
        root.popupY = Math.max(34, Math.min(y, 1080 - root.popupHeight - 10))
        root.opened = true
    }

    function toggle(x: int, y: int) {
        if (root.opened) {
            root.opened = false
        } else {
            root.openAt(x, y)
        }
    }

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property var devices: Bluetooth.devices ? Bluetooth.devices.values : []

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
                width: root.popupWidth
                height: root.popupHeight
                radius: 12
                color: shell.theme.bg
                border.color: shell.theme.accent
                border.width: 1

                Column {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 12

                    // ── Başlık ve Kontroller ──
                    Item {
                        width: parent.width
                        height: 24

                        Row {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 8

                            Text {
                                text: "󰂯"
                                color: shell.theme.accent
                                font.family: shell.fontFamily
                                font.pixelSize: 16
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: "Bluetooth"
                                color: shell.theme.fg
                                font.family: shell.fontFamily
                                font.pixelSize: 13
                                font.bold: true
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Row {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 8

                            // Tarama (Discover) Butonu
                            Rectangle {
                                width: 26
                                height: 22
                                radius: 4
                                color: (root.adapter?.discovering ?? false) ? shell.theme.accent : shell.theme.surface
                                anchors.verticalCenter: parent.verticalCenter
                                visible: root.adapter?.enabled ?? false

                                Text {
                                    anchors.centerIn: parent
                                    text: "󰑐"
                                    color: (root.adapter?.discovering ?? false) ? shell.theme.bg : shell.theme.fg
                                    font.family: shell.fontFamily
                                    font.pixelSize: 12
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (root.adapter) {
                                            root.adapter.discovering = !root.adapter.discovering
                                        }
                                    }
                                }
                            }

                            // Aç/Kapat Toggle Anahtarı
                            Rectangle {
                                width: 44
                                height: 22
                                radius: 11
                                color: (root.adapter?.enabled ?? false) ? shell.theme.accent : shell.theme.surface
                                anchors.verticalCenter: parent.verticalCenter

                                Rectangle {
                                    width: 16
                                    height: 16
                                    radius: 8
                                    color: (root.adapter?.enabled ?? false) ? shell.theme.bg : shell.theme.dim
                                    y: 3
                                    x: (root.adapter?.enabled ?? false) ? parent.width - 19 : 3
                                    Behavior on x { NumberAnimation { duration: 150 } }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (root.adapter) {
                                            root.adapter.enabled = !root.adapter.enabled
                                        }
                                    }
                                }
                            }

                            // Kapat (X) Butonu
                            Rectangle {
                                width: 22
                                height: 22
                                radius: 11
                                color: closeBtMouse.containsMouse ? shell.theme.surface : "transparent"
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    anchors.centerIn: parent
                                    text: "✕"
                                    color: shell.theme.dim
                                    font.pixelSize: 10
                                }

                                MouseArea {
                                    id: closeBtMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.opened = false
                                }
                            }
                        }
                    }

                    // ── Durum ve Tarama Bilgisi ──
                    Rectangle {
                        width: parent.width
                        height: 32
                        radius: 6
                        color: shell.theme.surface

                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 8

                            Rectangle {
                                width: 8
                                height: 8
                                radius: 4
                                color: (root.adapter?.enabled ?? false) ? "#50FA7B" : shell.theme.dim
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: {
                                    if (!root.adapter) return "Bluetooth Donanımı Yok"
                                    if (!root.adapter.enabled) return "Bluetooth Kapalı"
                                    if (root.adapter.discovering) return "Cihazlar Aranıyor..."
                                    return "Hazır (" + root.devices.length + " aygıt)"
                                }
                                color: shell.theme.fg
                                font.family: shell.fontFamily
                                font.pixelSize: 11
                                font.bold: true
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }

                    // ── Cihazlar Listesi ──
                    Rectangle {
                        width: parent.width
                        height: root.popupHeight - 120
                        color: "transparent"
                        clip: true

                        Text {
                            anchors.centerIn: parent
                            visible: !root.adapter || !root.adapter.enabled
                            text: "Bluetooth kapalı."
                            color: shell.theme.dim
                            font.family: shell.fontFamily
                            font.pixelSize: 12
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: root.adapter && root.adapter.enabled && root.devices.length === 0
                            text: "Kayıtlı veya yakında aygıt bulunamadı."
                            color: shell.theme.dim
                            font.family: shell.fontFamily
                            font.pixelSize: 11
                        }

                        Flickable {
                            anchors.fill: parent
                            contentHeight: btColumn.height
                            boundsBehavior: Flickable.StopAtBounds
                            visible: root.adapter && root.adapter.enabled && root.devices.length > 0

                            Column {
                                id: btColumn
                                width: parent.width
                                spacing: 4

                                Repeater {
                                    model: root.devices
                                    delegate: Rectangle {
                                        required property var modelData
                                        width: parent.width
                                        height: 40
                                        radius: 6
                                        color: modelData.connected ? shell.theme.surface : (btRowMouse.containsMouse ? shell.theme.surface : "transparent")
                                        border.color: modelData.connected ? shell.theme.accent : "transparent"
                                        border.width: 1

                                        Item {
                                            anchors.fill: parent
                                            anchors.leftMargin: 8
                                            anchors.rightMargin: 8

                                            Row {
                                                anchors.left: parent.left
                                                anchors.right: btRightControls.left
                                                anchors.rightMargin: 8
                                                anchors.verticalCenter: parent.verticalCenter
                                                spacing: 8

                                                Text {
                                                    text: {
                                                        var iconName = String(modelData.icon || "").toLowerCase()
                                                        if (iconName.indexOf("head") !== -1 || iconName.indexOf("audio") !== -1) return "󰋋"
                                                        if (iconName.indexOf("mouse") !== -1) return "󰍽"
                                                        if (iconName.indexOf("keyboard") !== -1) return "󰌌"
                                                        if (iconName.indexOf("phone") !== -1) return "󰏲"
                                                        return "󰂯"
                                                    }
                                                    color: modelData.connected ? shell.theme.accent : shell.theme.fg
                                                    font.family: shell.fontFamily
                                                    font.pixelSize: 14
                                                    anchors.verticalCenter: parent.verticalCenter
                                                }

                                                Column {
                                                    width: parent.width - 24
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    spacing: 2

                                                    Text {
                                                        text: modelData.name || modelData.deviceName || modelData.address || "Bilinmeyen Aygıt"
                                                        color: shell.theme.fg
                                                        font.family: shell.fontFamily
                                                        font.pixelSize: 11
                                                        font.bold: modelData.connected
                                                        elide: Text.ElideRight
                                                        width: parent.width
                                                    }

                                                    Text {
                                                        text: modelData.connected ? "Bağlı" : (modelData.paired ? "Eşleşmiş" : "Eşleşmemiş")
                                                        color: modelData.connected ? shell.theme.accent : shell.theme.dim
                                                        font.family: shell.fontFamily
                                                        font.pixelSize: 9
                                                    }
                                                }
                                            }

                                            Row {
                                                id: btRightControls
                                                anchors.right: parent.right
                                                anchors.verticalCenter: parent.verticalCenter
                                                spacing: 6

                                                // Pil bilgisi (varsa)
                                                Text {
                                                    visible: modelData.batteryAvailable
                                                    text: "󰁹 " + modelData.battery + "%"
                                                    color: shell.theme.dim
                                                    font.family: shell.fontFamily
                                                    font.pixelSize: 9
                                                    anchors.verticalCenter: parent.verticalCenter
                                                }

                                                // Bağlan / Ayır Butonu
                                                Rectangle {
                                                    width: modelData.connected ? 42 : 50
                                                    height: 22
                                                    radius: 4
                                                    color: modelData.connected ? "#FF5555" : shell.theme.accent
                                                    anchors.verticalCenter: parent.verticalCenter

                                                    Text {
                                                        anchors.centerIn: parent
                                                        text: modelData.connected ? "Ayır" : (modelData.paired ? "Bağlan" : "Eşleş")
                                                        color: modelData.connected ? "#FFFFFF" : shell.theme.bg
                                                        font.family: shell.fontFamily
                                                        font.pixelSize: 9
                                                        font.bold: true
                                                    }

                                                    MouseArea {
                                                        anchors.fill: parent
                                                        cursorShape: Qt.PointingHandCursor
                                                        onClicked: {
                                                            if (modelData.connected) {
                                                                modelData.disconnect()
                                                            } else if (modelData.paired) {
                                                                modelData.connect()
                                                            } else {
                                                                modelData.pair()
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }

                                        MouseArea {
                                            id: btRowMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            z: -1
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Item {
                focus: root.opened
                Keys.onEscapePressed: root.opened = false
            }
        }
    }
}
