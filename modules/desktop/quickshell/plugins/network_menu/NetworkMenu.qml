import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

Item {
    id: root

    property bool opened: false
    property int popupX: 100
    property int popupY: 40
    readonly property int popupWidth: 460
    readonly property int popupHeight: 330

    // Ağ Durum Verileri
    property string netType: "ethernet"
    property string netName: "Ethernet"
    property string netPhrase: "HAULING BYTES"
    property string pingMs: "32 ms"
    property string packetLoss: "0%"
    property string rxRate: "132 B/s"
    property string txRate: "132 B/s"
    property string rxTotal: "9.2 MB"
    property string txTotal: "137.0 KB"
    property string ipAddress: "192.168.122.30"
    property string gateway: "192.168.122.1"
    property string dnsProvider: "DHCP"

    property real lastRxBytes: 0
    property real lastTxBytes: 0
    property real lastTime: 0

    function formatBytes(bytes) {
        var b = Number(bytes)
        if (b >= 1073741824) return (b / 1073741824).toFixed(1) + " GB"
        if (b >= 1048576) return (b / 1048576).toFixed(1) + " MB"
        if (b >= 1024) return (b / 1024).toFixed(1) + " KB"
        return Math.round(b) + " B"
    }

    function openAt(x: int, y: int) {
        shell.closeAllMenus()
        root.popupX = Math.max(10, Math.min(x, 1920 - root.popupWidth - 10))
        root.popupY = shell.barHeight + 6
        root.opened = true
        fetchStatus()
    }

    function toggle(x: int, y: int) {
        if (root.opened) {
            root.opened = false
        } else {
            root.openAt(x, y)
        }
    }

    Process {
        id: statusProc
        command: ["xmarchy-network-status"]
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                try {
                    var data = JSON.parse(text)
                    root.netType = data.type || "ethernet"
                    root.netName = data.name || "Ethernet"
                    root.netPhrase = data.phrase || "HAULING BYTES"
                    root.pingMs = data.ping || "-- ms"
                    root.packetLoss = data.packet_loss || "0%"
                    root.ipAddress = data.ip || "--"
                    root.gateway = data.gateway || "--"
                    if (data.dns) root.dnsProvider = data.dns

                    var now = Date.now()
                    if (root.lastTime > 0 && now > root.lastTime) {
                        var dt = (now - root.lastTime) / 1000
                        var rxDiff = Math.max(0, data.rx_bytes - root.lastRxBytes)
                        var txDiff = Math.max(0, data.tx_bytes - root.lastTxBytes)
                        root.rxRate = root.formatBytes(rxDiff / dt) + "/s"
                        root.txRate = root.formatBytes(txDiff / dt) + "/s"
                    }
                    root.lastRxBytes = data.rx_bytes
                    root.lastTxBytes = data.tx_bytes
                    root.lastTime = now
                    root.rxTotal = root.formatBytes(data.rx_bytes)
                    root.txTotal = root.formatBytes(data.tx_bytes)
                } catch (e) {}
            }
        }
    }

    Process {
        id: dnsProc
    }

    function setDns(provider) {
        root.dnsProvider = provider
        dnsProc.command = ["xmarchy", "dns", provider]
        dnsProc.running = true
    }

    function fetchStatus() {
        if (!statusProc.running) {
            statusProc.running = true
        }
    }

    Timer {
        interval: 1500
        running: root.opened
        repeat: true
        onTriggered: root.fetchStatus()
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
                width: root.popupWidth
                height: root.popupHeight
                radius: 12
                color: shell.theme.bg
                border.color: shell.theme.accent
                border.width: 1

                Column {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 14

                    // ═══════════════ 1. Üst Başlık (Ethernet / HAULING BYTES) ═══════════════
                    RowLayout {
                        width: parent.width

                        Row {
                            spacing: 12
                            Layout.alignment: Qt.AlignVCenter

                            Text {
                                text: root.netType === "wifi" ? "󰤨" : "󰈀"
                                color: shell.theme.accent
                                font.family: shell.fontFamily
                                font.pixelSize: 24
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Column {
                                spacing: 2
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    text: root.netName
                                    color: shell.theme.fg
                                    font.family: shell.fontFamily
                                    font.pixelSize: 15
                                    font.bold: true
                                }

                                Text {
                                    text: root.netPhrase
                                    color: shell.theme.dim
                                    font.family: shell.fontFamily
                                    font.pixelSize: 10
                                    font.bold: true
                                    font.letterSpacing: 1
                                }
                            }
                        }

                        Item { Layout.fillWidth: true }

                        // Speedometer İkonu (Ekran görüntüsündeki gibi)
                        Text {
                            text: "󰓅"
                            color: shell.theme.dim
                            font.family: shell.fontFamily
                            font.pixelSize: 18
                            Layout.alignment: Qt.AlignVCenter
                        }
                    }

                    // ═══════════════ 2. 2-Sütunlu Canlı Metrikler Tablosu ═══════════════
                    Column {
                        width: parent.width
                        spacing: 8

                        // Satır 1: Ping & Packet Loss
                        RowLayout {
                            width: parent.width

                            Row {
                                spacing: 10
                                Text { text: "Ping"; color: shell.theme.dim; font.pixelSize: 11; font.family: shell.fontFamily; width: 90 }
                                Text { text: root.pingMs; color: shell.theme.fg; font.pixelSize: 11; font.bold: true; font.family: shell.fontFamily }
                            }

                            Item { Layout.fillWidth: true }

                            Row {
                                spacing: 10
                                Text { text: "Packet Loss"; color: shell.theme.dim; font.pixelSize: 11; font.family: shell.fontFamily; width: 90 }
                                Text { text: root.packetLoss; color: shell.theme.fg; font.pixelSize: 11; font.bold: true; font.family: shell.fontFamily }
                            }
                        }

                        // Satır 2: Receiving & Sending
                        RowLayout {
                            width: parent.width

                            Row {
                                spacing: 10
                                Text { text: "Receiving"; color: shell.theme.dim; font.pixelSize: 11; font.family: shell.fontFamily; width: 90 }
                                Text { text: root.rxRate; color: shell.theme.fg; font.pixelSize: 11; font.bold: true; font.family: shell.fontFamily }
                            }

                            Item { Layout.fillWidth: true }

                            Row {
                                spacing: 10
                                Text { text: "Sending"; color: shell.theme.dim; font.pixelSize: 11; font.family: shell.fontFamily; width: 90 }
                                Text { text: root.txRate; color: shell.theme.fg; font.pixelSize: 11; font.bold: true; font.family: shell.fontFamily }
                            }
                        }

                        // Satır 3: Downloaded & Uploaded
                        RowLayout {
                            width: parent.width

                            Row {
                                spacing: 10
                                Text { text: "Downloaded"; color: shell.theme.dim; font.pixelSize: 11; font.family: shell.fontFamily; width: 90 }
                                Text { text: root.rxTotal; color: shell.theme.fg; font.pixelSize: 11; font.bold: true; font.family: shell.fontFamily }
                            }

                            Item { Layout.fillWidth: true }

                            Row {
                                spacing: 10
                                Text { text: "Uploaded"; color: shell.theme.dim; font.pixelSize: 11; font.family: shell.fontFamily; width: 90 }
                                Text { text: root.txTotal; color: shell.theme.fg; font.pixelSize: 11; font.bold: true; font.family: shell.fontFamily }
                            }
                        }

                        // Satır 4: IP Address & Gateway
                        RowLayout {
                            width: parent.width

                            Row {
                                spacing: 10
                                Text { text: "IP Address"; color: shell.theme.dim; font.pixelSize: 11; font.family: shell.fontFamily; width: 90 }
                                Text { text: root.ipAddress; color: shell.theme.fg; font.pixelSize: 11; font.bold: true; font.family: shell.fontFamily }
                            }

                            Item { Layout.fillWidth: true }

                            Row {
                                spacing: 10
                                Text { text: "Gateway"; color: shell.theme.dim; font.pixelSize: 11; font.family: shell.fontFamily; width: 90 }
                                Text { text: root.gateway; color: shell.theme.fg; font.pixelSize: 11; font.bold: true; font.family: shell.fontFamily }
                            }
                        }
                    }

                    // ═══════════════ 3. DNS PROVIDER Bölümü ═══════════════
                    Column {
                        width: parent.width
                        spacing: 8

                        Text {
                            text: "DNS PROVIDER"
                            color: shell.theme.dim
                            font.family: shell.fontFamily
                            font.pixelSize: 10
                            font.bold: true
                            font.letterSpacing: 1
                        }

                        // 4 Buton Yan Yana: [DHCP] [Cloudflare] [Google] [Custom]
                        Row {
                            width: parent.width
                            spacing: 8

                            Repeater {
                                model: ["DHCP", "Cloudflare", "Google", "Custom"]
                                delegate: Rectangle {
                                    required property var modelData
                                    required property int index
                                    width: (parent.width - 24) / 4
                                    height: 32
                                    radius: 6
                                    property bool isActive: root.dnsProvider.toLowerCase() === modelData.toLowerCase()
                                    color: isActive ? shell.theme.surface : (dnsMouse.containsMouse ? shell.theme.surface : "transparent")
                                    border.color: isActive ? shell.theme.accent : shell.theme.dim
                                    border.width: 1

                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData
                                        color: parent.isActive ? shell.theme.accent : (dnsMouse.containsMouse ? shell.theme.fg : shell.theme.dim)
                                        font.family: shell.fontFamily
                                        font.pixelSize: 11
                                        font.bold: parent.isActive
                                    }

                                    MouseArea {
                                        id: dnsMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: root.setDns(modelData)
                                    }
                                }
                            }
                        }
                    }

                    // ═══════════════ 4. Wi-Fi & Ağ Bağlantı Yönetimi ═══════════════
                    Rectangle {
                        width: parent.width
                        height: 34
                        radius: 8
                        color: shell.theme.surface
                        border.color: shell.theme.accent
                        border.width: 1

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 8

                            Text {
                                text: "󰤨"
                                color: shell.theme.accent
                                font.family: shell.fontFamily
                                font.pixelSize: 14
                            }

                            Text {
                                text: "Ağları Yönet / Wi-Fi Bağlan (NMTUI)"
                                color: shell.theme.fg
                                font.family: shell.fontFamily
                                font.pixelSize: 11
                                font.bold: true
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.opened = false
                                Hyprland.dispatch("exec kitty -e nmtui")
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
