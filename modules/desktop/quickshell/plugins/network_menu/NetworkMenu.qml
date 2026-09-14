import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Networking

Item {
    id: root

    property bool opened: false
    property int popupX: 100
    property int popupY: 40
    readonly property int popupWidth: 340
    readonly property int popupHeight: 420

    property string selectedSsid: ""
    property string passphrase: ""

    function openAt(x: int, y: int) {
        shell.closeAllMenus()
        root.popupX = Math.max(10, Math.min(x, 1920 - root.popupWidth - 10))
        root.popupY = Math.max(34, Math.min(y, 1080 - root.popupHeight - 10))
        root.selectedSsid = ""
        root.passphrase = ""
        root.opened = true
    }

    readonly property var wifiDevice: {
        var devs = Networking.devices ? Networking.devices.values : []
        for (var i = 0; i < devs.length; i++) {
            if (devs[i] && ((typeof DeviceType !== "undefined" && devs[i].type === DeviceType.Wifi) || devs[i].type === 2 || (devs[i].name && devs[i].name.startsWith("wl")))) return devs[i]
        }
        return null
    }

    readonly property var wifiNetworks: (wifiDevice && wifiDevice.networks) ? wifiDevice.networks.values : []

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

                    // ── Başlık ve Wi-Fi Toggle ──
                    Item {
                        width: parent.width
                        height: 24

                        Row {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 8

                            Text {
                                text: "󰤨"
                                color: shell.theme.accent
                                font.family: shell.fontFamily
                                font.pixelSize: 16
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: "Ağ & Wi-Fi"
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

                            // Wi-Fi Aç/Kapa Anahtarı
                            Rectangle {
                                width: 44
                                height: 22
                                radius: 11
                                color: Networking.wifiEnabled ? shell.theme.accent : shell.theme.surface
                                anchors.verticalCenter: parent.verticalCenter

                                Rectangle {
                                    width: 16
                                    height: 16
                                    radius: 8
                                    color: Networking.wifiEnabled ? shell.theme.bg : shell.theme.dim
                                    y: 3
                                    x: Networking.wifiEnabled ? parent.width - 19 : 3
                                    Behavior on x { NumberAnimation { duration: 150 } }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: Networking.wifiEnabled = !Networking.wifiEnabled
                                }
                            }

                            // Kapat (X) Butonu
                            Rectangle {
                                width: 22
                                height: 22
                                radius: 11
                                color: closeNetMouse.containsMouse ? shell.theme.surface : "transparent"
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    anchors.centerIn: parent
                                    text: "✕"
                                    color: shell.theme.dim
                                    font.pixelSize: 10
                                }

                                MouseArea {
                                    id: closeNetMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.opened = false
                                }
                            }
                        }
                    }

                    // ── Durum Kartı ──
                    Rectangle {
                        width: parent.width
                        height: 36
                        radius: 8
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
                                color: Networking.connectivity >= 3 ? "#50FA7B" : "#FF5555"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: Networking.connectivity >= 3 ? "İnternet Bağlantısı Aktif" : "İnternet Bağlantısı Yok"
                                color: shell.theme.fg
                                font.family: shell.fontFamily
                                font.pixelSize: 11
                                font.bold: true
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }

                    // ── Çevredeki Ağlar Başlığı ──
                    Row {
                        width: parent.width
                        Text {
                            text: "Kullanılabilir Kablosuz Ağlar"
                            color: shell.theme.dim
                            font.family: shell.fontFamily
                            font.pixelSize: 11
                            font.bold: true
                        }
                    }

                    // ── Ağlar Listesi ──
                    Rectangle {
                        width: parent.width
                        height: root.popupHeight - 160
                        color: "transparent"
                        clip: true

                        Text {
                            anchors.centerIn: parent
                            visible: !Networking.wifiEnabled
                            text: "Wi-Fi Donanımı Kapalı"
                            color: shell.theme.dim
                            font.family: shell.fontFamily
                            font.pixelSize: 12
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: Networking.wifiEnabled && root.wifiNetworks.length === 0
                            text: "Ağlar taranıyor..."
                            color: shell.theme.dim
                            font.family: shell.fontFamily
                            font.pixelSize: 12
                        }

                        Flickable {
                            anchors.fill: parent
                            contentHeight: netColumn.height
                            boundsBehavior: Flickable.StopAtBounds
                            visible: Networking.wifiEnabled && root.wifiNetworks.length > 0

                            Column {
                                id: netColumn
                                width: parent.width
                                spacing: 4

                                Repeater {
                                    model: root.wifiNetworks
                                    delegate: Rectangle {
                                        required property var modelData
                                        width: parent.width
                                        height: (root.selectedSsid === modelData.name && !modelData.connected) ? 84 : 36
                                        radius: 6
                                        color: modelData.connected ? shell.theme.surface : (rowMouse.containsMouse ? shell.theme.surface : "transparent")
                                        border.color: modelData.connected ? shell.theme.accent : (root.selectedSsid === modelData.name ? shell.theme.accent : "transparent")
                                        border.width: 1

                                        Behavior on height { NumberAnimation { duration: 150 } }

                                        Column {
                                            anchors.fill: parent
                                            anchors.margins: 6
                                            spacing: 6

                                            // Üst Sıra: Sinyal, İsim, Durum
                                            Item {
                                                width: parent.width
                                                height: 24

                                                Row {
                                                    anchors.left: parent.left
                                                    anchors.right: netActionBtn.left
                                                    anchors.rightMargin: 8
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    spacing: 8

                                                    Text {
                                                        text: {
                                                            var s = modelData.signalStrength || 0
                                                            if (s >= 75) return "󰤨"
                                                            if (s >= 50) return "󰤥"
                                                            if (s >= 25) return "󰤢"
                                                            return "󰤟"
                                                        }
                                                        color: modelData.connected ? shell.theme.accent : shell.theme.fg
                                                        font.family: shell.fontFamily
                                                        font.pixelSize: 13
                                                        anchors.verticalCenter: parent.verticalCenter
                                                    }

                                                    Text {
                                                        text: modelData.name || "Gizli Ağ"
                                                        color: modelData.connected ? shell.theme.fg : shell.theme.fg
                                                        font.family: shell.fontFamily
                                                        font.pixelSize: 11
                                                        font.bold: modelData.connected
                                                        elide: Text.ElideRight
                                                        width: parent.width - 24
                                                        anchors.verticalCenter: parent.verticalCenter
                                                    }
                                                }

                                                // Bağlı Rozeti veya Bağlan Butonu
                                                Rectangle {
                                                    id: netActionBtn
                                                    anchors.right: parent.right
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    width: modelData.connected ? 48 : 54
                                                    height: 22
                                                    radius: 4
                                                    color: modelData.connected ? shell.theme.accent : shell.theme.surface

                                                    Text {
                                                        anchors.centerIn: parent
                                                        text: modelData.connected ? "Bağlı" : "Seç"
                                                        color: modelData.connected ? shell.theme.bg : shell.theme.fg
                                                        font.family: shell.fontFamily
                                                        font.pixelSize: 10
                                                        font.bold: true
                                                    }

                                                    MouseArea {
                                                        anchors.fill: parent
                                                        cursorShape: Qt.PointingHandCursor
                                                        onClicked: {
                                                            if (modelData.connected) {
                                                                if (modelData.disconnect) modelData.disconnect()
                                                            } else {
                                                                if (root.selectedSsid === modelData.name) {
                                                                    root.selectedSsid = ""
                                                                } else {
                                                                    root.selectedSsid = modelData.name || ""
                                                                    root.passphrase = ""
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }

                                            // Genişleyen Şifre Giriş Alanı
                                            Row {
                                                width: parent.width
                                                spacing: 6
                                                visible: root.selectedSsid === modelData.name && !modelData.connected

                                                Rectangle {
                                                    width: parent.width - 66
                                                    height: 28
                                                    radius: 4
                                                    color: shell.theme.bg
                                                    border.color: shell.theme.dim
                                                    border.width: 1

                                                    TextInput {
                                                        id: passInput
                                                        anchors.fill: parent
                                                        anchors.margins: 4
                                                        echoMode: TextInput.Password
                                                        color: shell.theme.fg
                                                        font.family: shell.fontFamily
                                                        font.pixelSize: 11
                                                        verticalAlignment: TextInput.AlignVCenter
                                                        onTextChanged: root.passphrase = text
                                                        onAccepted: {
                                                            if (root.passphrase.length > 0) {
                                                                modelData.connectWithPsk(root.passphrase)
                                                                root.selectedSsid = ""
                                                            } else {
                                                                modelData.connect()
                                                                root.selectedSsid = ""
                                                            }
                                                        }
                                                    }
                                                }

                                                Rectangle {
                                                    width: 60
                                                    height: 28
                                                    radius: 4
                                                    color: shell.theme.accent

                                                    Text {
                                                        anchors.centerIn: parent
                                                        text: "Bağlan"
                                                        color: shell.theme.bg
                                                        font.family: shell.fontFamily
                                                        font.pixelSize: 10
                                                        font.bold: true
                                                    }

                                                    MouseArea {
                                                        anchors.fill: parent
                                                        cursorShape: Qt.PointingHandCursor
                                                        onClicked: {
                                                            if (root.passphrase.length > 0) {
                                                                modelData.connectWithPsk(root.passphrase)
                                                            } else {
                                                                modelData.connect()
                                                            }
                                                            root.selectedSsid = ""
                                                        }
                                                    }
                                                }
                                            }
                                        }

                                        MouseArea {
                                            id: rowMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            z: -1
                                            onClicked: {
                                                if (!modelData.connected) {
                                                    root.selectedSsid = (root.selectedSsid === modelData.name) ? "" : (modelData.name || "")
                                                    root.passphrase = ""
                                                }
                                            }
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
