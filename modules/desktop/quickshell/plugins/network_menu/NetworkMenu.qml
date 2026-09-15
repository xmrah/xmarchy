import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Hyprland

Item {
    id: root

    property bool opened: false
    property int popupX: 100
    property int popupY: 40
    readonly property int popupWidth: 460
    readonly property int popupHeight: wifiNetworks.length > 0 ? 490 : 360

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

    property var wifiNetworks: []

    function formatBytes(bytes) {
        var b = Number(bytes);
        if (b >= 1073741824) return (b / 1073741824).toFixed(1) + " GB";
        if (b >= 1048576) return (b / 1048576).toFixed(1) + " MB";
        if (b >= 1024) return (b / 1024).toFixed(1) + " KB";
        return Math.round(b) + " B";
    }

    function wifiIcon(sig) {
        if (sig >= 75) return "󰤨";
        if (sig >= 50) return "󰤥";
        if (sig >= 25) return "󰤢";
        return "󰤟";
    }

    function openAt(x: int, y: int) {
        shell.closeAllMenus();
        root.popupX = Math.max(10, Math.min(x, 1920 - root.popupWidth - 10));
        root.popupY = shell.barHeight + 6;
        root.opened = true;
        fetchStatus();
        scanWifi();
    }

    function toggle(x: int, y: int) {
        if (root.opened) {
            root.opened = false;
        } else {
            root.openAt(x, y);
        }
    }

    Process {
        id: statusProc
        command: ["xmarchy-network-status"]
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                try {
                    var data = JSON.parse(text);
                    root.netType = data.type || "ethernet";
                    root.netName = data.name || "Ethernet";
                    root.netPhrase = data.phrase || "HAULING BYTES";
                    root.pingMs = data.ping || "-- ms";
                    root.packetLoss = data.packet_loss || "0%";
                    root.ipAddress = data.ip || "--";
                    root.gateway = data.gateway || "--";
                    if (data.dns) root.dnsProvider = data.dns;

                    var now = Date.now();
                    if (root.lastTime > 0 && now > root.lastTime) {
                        var dt = (now - root.lastTime) / 1000;
                        var rxDiff = Math.max(0, data.rx_bytes - root.lastRxBytes);
                        var txDiff = Math.max(0, data.tx_bytes - root.lastTxBytes);
                        root.rxRate = root.formatBytes(rxDiff / dt) + "/s";
                        root.txRate = root.formatBytes(txDiff / dt) + "/s";
                    }
                    root.lastRxBytes = data.rx_bytes;
                    root.lastTxBytes = data.tx_bytes;
                    root.lastTime = now;
                    root.rxTotal = root.formatBytes(data.rx_bytes);
                    root.txTotal = root.formatBytes(data.tx_bytes);
                } catch (e) {}
            }
        }
    }

    Process {
        id: wifiProc
        command: ["nmcli", "-t", "-f", "IN-USE,SSID,SIGNAL,SECURITY", "dev", "wifi", "list", "--rescan", "no"]
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                var lines = text.trim().split("
");
                var list = [];
                var seen = {};
                for (var i = 0; i < lines.length; i++) {
                    var l = lines[i].trim();
                    if (!l) continue;
                    var parts = l.split(":");
                    if (parts.length >= 3) {
                        var inUse = parts[0].trim() === "*";
                        var ssid = parts[1].trim();
                        if (!ssid || seen[ssid]) continue;
                        seen[ssid] = true;
                        var sig = parseInt(parts[2]) || 0;
                        var sec = parts.length >= 4 ? parts[3].trim() : "";
                        list.push({ inUse: inUse, ssid: ssid, signal: sig, security: sec });
                    }
                }
                root.wifiNetworks = list.slice(0, 4);
            }
        }
    }

    Process {
        id: wifiRescanProc
        command: ["nmcli", "dev", "wifi", "rescan"]
        onExited: {
            root.scanWifi();
        }
    }

    Process {
        id: dnsProc
    }

    function setDns(provider) {
        root.dnsProvider = provider;
        dnsProc.command = ["xmarchy", "dns", provider];
        dnsProc.running = true;
    }

    function fetchStatus() {
        if (!statusProc.running) {
            statusProc.running = true;
        }
    }

    function scanWifi() {
        if (!wifiProc.running) {
            wifiProc.running = true;
        }
    }

    Timer {
        interval: 2000
        running: root.opened
        repeat: true
        onTriggered: {
            root.fetchStatus();
            root.scanWifi();
        }
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
                    anchors.margins: 18
                    spacing: 12

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

                        Text {
                            text: "󰓅"
                            color: shell.theme.dim
                            font.family: shell.fontFamily
                            font.pixelSize: 18
                            Layout.alignment: Qt.AlignVCenter
                        }
                    }

                    // ═══════════════ 2. Canlı Metrikler Tablosu ═══════════════
                    Column {
                        width: parent.width
                        spacing: 6

                        // Satır 1: Ping & Packet Loss
                        RowLayout {
                            width: parent.width

                            Row {
                                spacing: 10
                                Text { text: "Ping"; color: shell.theme.dim; font.pixelSize: 11; font.family: shell.fontFamily; width: 85 }
                                Text { text: root.pingMs; color: shell.theme.fg; font.pixelSize: 11; font.bold: true; font.family: shell.fontFamily }
                            }

                            Item { Layout.fillWidth: true }

                            Row {
                                spacing: 10
                                Text { text: "Packet Loss"; color: shell.theme.dim; font.pixelSize: 11; font.family: shell.fontFamily; width: 85 }
                                Text { text: root.packetLoss; color: shell.theme.fg; font.pixelSize: 11; font.bold: true; font.family: shell.fontFamily }
                            }
                        }

                        // Satır 2: Receiving & Sending
                        RowLayout {
                            width: parent.width

                            Row {
                                spacing: 10
                                Text { text: "Receiving"; color: shell.theme.dim; font.pixelSize: 11; font.family: shell.fontFamily; width: 85 }
                                Text { text: root.rxRate; color: shell.theme.fg; font.pixelSize: 11; font.bold: true; font.family: shell.fontFamily }
                            }

                            Item { Layout.fillWidth: true }

                            Row {
                                spacing: 10
                                Text { text: "Sending"; color: shell.theme.dim; font.pixelSize: 11; font.family: shell.fontFamily; width: 85 }
                                Text { text: root.txRate; color: shell.theme.fg; font.pixelSize: 11; font.bold: true; font.family: shell.fontFamily }
                            }
                        }

                        // Satır 3: Downloaded & Uploaded
                        RowLayout {
                            width: parent.width

                            Row {
                                spacing: 10
                                Text { text: "Downloaded"; color: shell.theme.dim; font.pixelSize: 11; font.family: shell.fontFamily; width: 85 }
                                Text { text: root.rxTotal; color: shell.theme.fg; font.pixelSize: 11; font.bold: true; font.family: shell.fontFamily }
                            }

                            Item { Layout.fillWidth: true }

                            Row {
                                spacing: 10
                                Text { text: "Uploaded"; color: shell.theme.dim; font.pixelSize: 11; font.family: shell.fontFamily; width: 85 }
                                Text { text: root.txTotal; color: shell.theme.fg; font.pixelSize: 11; font.bold: true; font.family: shell.fontFamily }
                            }
                        }

                        // Satır 4: IP Address & Gateway
                        RowLayout {
                            width: parent.width

                            Row {
                                spacing: 10
                                Text { text: "IP Address"; color: shell.theme.dim; font.pixelSize: 11; font.family: shell.fontFamily; width: 85 }
                                Text { text: root.ipAddress; color: shell.theme.fg; font.pixelSize: 11; font.bold: true; font.family: shell.fontFamily }
                            }

                            Item { Layout.fillWidth: true }

                            Row {
                                spacing: 10
                                Text { text: "Gateway"; color: shell.theme.dim; font.pixelSize: 11; font.family: shell.fontFamily; width: 85 }
                                Text { text: root.gateway; color: shell.theme.fg; font.pixelSize: 11; font.bold: true; font.family: shell.fontFamily }
                            }
                        }
                    }

                    // ═══════════════ 3. DNS PROVIDER Bölümü ═══════════════
                    Column {
                        width: parent.width
                        spacing: 6

                        Text {
                            text: "DNS PROVIDER"
                            color: shell.theme.dim
                            font.family: shell.fontFamily
                            font.pixelSize: 10
                            font.bold: true
                            font.letterSpacing: 1
                        }

                        Row {
                            width: parent.width
                            spacing: 8

                            Repeater {
                                model: ["DHCP", "Cloudflare", "Google", "Custom"]
                                delegate: Rectangle {
                                    required property var modelData
                                    required property int index
                                    width: (parent.width - 24) / 4
                                    height: 28
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

                    // ═══════════════ 4. YAKINDAKİ WI-FI AĞLARI ═══════════════
                    Column {
                        width: parent.width
                        spacing: 6
                        visible: root.wifiNetworks.length > 0

                        RowLayout {
                            width: parent.width

                            Text {
                                text: "YAKINDAKİ AĞLAR (WI-FI)"
                                color: shell.theme.dim
                                font.family: shell.fontFamily
                                font.pixelSize: 10
                                font.bold: true
                                font.letterSpacing: 1
                            }

                            Item { Layout.fillWidth: true }

                            Rectangle {
                                width: 22
                                height: 22
                                radius: 4
                                color: refreshMouse.containsMouse ? shell.theme.surface : "transparent"

                                Text {
                                    anchors.centerIn: parent
                                    text: "󰑐"
                                    color: shell.theme.accent
                                    font.family: shell.fontFamily
                                    font.pixelSize: 13
                                }

                                MouseArea {
                                    id: refreshMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (!wifiRescanProc.running) {
                                            wifiRescanProc.running = true;
                                        }
                                    }
                                }
                            }
                        }

                        Repeater {
                            model: root.wifiNetworks
                            delegate: Rectangle {
                                required property var modelData
                                required property int index
                                width: parent.width
                                height: 26
                                radius: 6
                                color: netItemMouse.containsMouse ? shell.theme.surface : "transparent"
                                border.color: modelData.inUse ? shell.theme.accent : "transparent"
                                border.width: 1

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 8
                                    anchors.rightMargin: 8
                                    spacing: 8

                                    Text {
                                        text: root.wifiIcon(modelData.signal)
                                        color: modelData.inUse ? shell.theme.accent : shell.theme.fg
                                        font.family: shell.fontFamily
                                        font.pixelSize: 13
                                    }

                                    Text {
                                        text: modelData.ssid
                                        color: modelData.inUse ? shell.theme.accent : shell.theme.fg
                                        font.family: shell.fontFamily
                                        font.pixelSize: 11
                                        font.bold: modelData.inUse
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        text: modelData.security ? "󰌾" : ""
                                        color: shell.theme.dim
                                        font.family: shell.fontFamily
                                        font.pixelSize: 10
                                        visible: !!modelData.security
                                    }

                                    Text {
                                        text: modelData.signal + "%"
                                        color: shell.theme.dim
                                        font.family: shell.fontFamily
                                        font.pixelSize: 10
                                    }

                                    Rectangle {
                                        visible: modelData.inUse
                                        width: 44
                                        height: 18
                                        radius: 4
                                        color: shell.theme.accent

                                        Text {
                                            anchors.centerIn: parent
                                            text: "Bağlı"
                                            color: shell.theme.bg
                                            font.family: shell.fontFamily
                                            font.pixelSize: 9
                                            font.bold: true
                                        }
                                    }
                                }

                                MouseArea {
                                    id: netItemMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (!modelData.inUse) {
                                            root.opened = false;
                                            Hyprland.dispatch("exec kitty -e nmcli --ask dev wifi connect '" + modelData.ssid + "'");
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // ═══════════════ 5. Ağları Yönet (NMTUI) ═══════════════
                    Rectangle {
                        width: parent.width
                        height: 32
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
                                font.pixelSize: 13
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
                                root.opened = false;
                                Hyprland.dispatch("exec kitty -e nmtui");
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
