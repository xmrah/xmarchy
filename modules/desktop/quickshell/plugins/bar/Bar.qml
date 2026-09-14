import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import Quickshell.Services.SystemTray
import Quickshell.Services.UPower
import Quickshell.Services.Mpris
import Quickshell.Bluetooth
import Quickshell.Networking

PanelWindow {
    id: bar

    anchors { top: true; left: true; right: true }
    exclusiveZone: shell.barHeight
    implicitHeight: shell.barHeight
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Top

    Rectangle {
        anchors.fill: parent
        color: shell.theme.bg
        opacity: 0.95

        // Alt kenar çizgisi (Aksan renginde ince 1px şerit)
        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: 1
            color: shell.theme.surface
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 8

            // ═══════════════ SOL: Başlat Menüsü, Hızlı Erişim ve Workspaces ═══════════════
            Row {
                spacing: 6
                Layout.alignment: Qt.AlignVCenter

                // Xmarchy Başlat Butonu
                Rectangle {
                    width: startLabel.implicitWidth + 20
                    height: 24
                    radius: 12
                    color: startMouse.containsMouse ? shell.theme.accent2 : shell.theme.accent
                    anchors.verticalCenter: parent.verticalCenter

                    Row {
                        anchors.centerIn: parent
                        spacing: 6
                        Text {
                            text: "󰣇"
                            color: shell.theme.bg
                            font.family: shell.fontFamily
                            font.pixelSize: 13
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            id: startLabel
                            text: "XMARCHY"
                            color: shell.theme.bg
                            font.family: shell.fontFamily
                            font.pixelSize: 11
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: startMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: shell.launcher.toggle()
                    }
                }

                // Hızlı Terminal İkonu
                Rectangle {
                    width: 24
                    height: 24
                    radius: 12
                    color: termIconMouse.containsMouse ? shell.theme.accent : shell.theme.surface
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        anchors.centerIn: parent
                        text: "󰞷"
                        color: termIconMouse.containsMouse ? shell.theme.bg : shell.theme.fg
                        font.family: shell.fontFamily
                        font.pixelSize: 12
                    }

                    MouseArea {
                        id: termIconMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Hyprland.dispatch("exec kitty")
                    }
                }

                // Hızlı Tarayıcı İkonu
                Rectangle {
                    width: 24
                    height: 24
                    radius: 12
                    color: browIconMouse.containsMouse ? shell.theme.accent : shell.theme.surface
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        anchors.centerIn: parent
                        text: "󰈹"
                        color: browIconMouse.containsMouse ? shell.theme.bg : shell.theme.fg
                        font.family: shell.fontFamily
                        font.pixelSize: 12
                    }

                    MouseArea {
                        id: browIconMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Hyprland.dispatch("exec brave || chromium || firefox")
                    }
                }

                Rectangle {
                    width: 1
                    height: 14
                    color: shell.theme.dim
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Workspaces
                Row {
                    spacing: 4
                    anchors.verticalCenter: parent.verticalCenter

                    Repeater {
                        model: 9
                        delegate: Rectangle {
                            required property int index
                            property int wsId: index + 1
                            property bool active: Hyprland.workspaces.values.some(
                                function(ws) { return ws.id === wsId }
                            )
                            property bool focused: Hyprland.focusedMonitor?.activeWorkspace?.id === wsId

                            width: focused ? 28 : (active ? 20 : 16)
                            height: 18
                            radius: 9
                            color: focused ? shell.theme.accent : (active ? shell.theme.surface : "transparent")
                            border.color: focused ? shell.theme.accent : (active ? shell.theme.dim : shell.theme.surface)
                            border.width: 1

                            Behavior on width { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                            Behavior on color { ColorAnimation { duration: 150 } }

                            Text {
                                anchors.centerIn: parent
                                text: parent.wsId
                                color: parent.focused ? shell.theme.bg : shell.theme.fg
                                font.family: shell.fontFamily
                                font.pixelSize: 10
                                font.bold: parent.focused
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Hyprland.dispatch("workspace " + parent.wsId)
                            }
                        }
                    }
                }

                // ═══════════════ Medya (MPRIS) Oynatıcı Pill ═══════════════
                Rectangle {
                    id: mprisPill
                    property var player: Mpris.players.values.length > 0 ? Mpris.players.values[0] : null
                    property bool hasMedia: player !== null && player.trackTitle && player.trackTitle.length > 0
                    visible: hasMedia
                    height: 22
                    width: Math.min(220, mprisRow.implicitWidth + 16)
                    radius: 11
                    color: mprisMouse.containsMouse ? shell.theme.surface : "transparent"
                    border.color: shell.theme.accent
                    border.width: 1
                    anchors.verticalCenter: parent.verticalCenter

                    Row {
                        id: mprisRow
                        anchors.centerIn: parent
                        spacing: 6

                        Text {
                            text: mprisPill.player?.isPlaying ? "󰏤" : "󰐊"
                            color: shell.theme.accent
                            font.family: shell.fontFamily
                            font.pixelSize: 11
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: (mprisPill.player?.trackArtist ? (mprisPill.player.trackArtist + " - ") : "") + (mprisPill.player?.trackTitle ?? "")
                            color: shell.theme.fg
                            font.family: shell.fontFamily
                            font.pixelSize: 11
                            elide: Text.ElideRight
                            width: Math.min(160, implicitWidth)
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: mprisMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        onClicked: function(mouse) {
                            if (mouse.button === Qt.RightButton) {
                                mprisPill.player?.next()
                            } else {
                                mprisPill.player?.togglePlaying()
                            }
                        }
                    }
                }
            }

            // Boşluk
            Item { Layout.fillWidth: true }

            // ═══════════════ ORTA: Saat, Tarih & Canlı Hava Durumu ═══════════════
            Row {
                Layout.alignment: Qt.AlignCenter
                spacing: 8

                // 1. Saat ve Tarih Alanı (Tıklanınca CalendarMenu açılır)
                Item {
                    width: clockRow.implicitWidth
                    height: 26
                    anchors.verticalCenter: parent.verticalCenter

                    Row {
                        id: clockRow
                        anchors.centerIn: parent
                        spacing: 6

                        Text {
                            id: clock
                            color: shell.calendarMenu?.opened ? shell.theme.accent : shell.theme.fg
                            font.family: shell.fontFamily
                            font.pixelSize: 13
                            font.bold: true

                            property var now: new Date()
                            text: Qt.formatDateTime(now, "HH:mm")

                            Timer {
                                running: true
                                repeat: true
                                interval: 1000
                                onTriggered: clock.now = new Date()
                            }
                        }

                        Text {
                            color: shell.calendarMenu?.opened ? shell.theme.fg : shell.theme.dim
                            font.family: shell.fontFamily
                            font.pixelSize: 12
                            text: "•  " + Qt.formatDateTime(clock.now, "dddd, d MMMM")
                        }
                    }

                    // Aktiflik Çizgisi
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: clockRow.implicitWidth
                        height: 2
                        radius: 1
                        color: shell.theme.accent
                        visible: shell.calendarMenu?.opened ?? false
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: shell.calendarMenu.toggle()
                    }
                }

                Text {
                    color: shell.theme.dim
                    font.family: shell.fontFamily
                    font.pixelSize: 12
                    text: "•"
                    anchors.verticalCenter: parent.verticalCenter
                }

                // 2. Canlı Hava Durumu Alanı (Tıklanınca WeatherMenu açılır)
                Item {
                    id: weatherPill
                    width: weatherWidget.implicitWidth + 8
                    height: 26
                    anchors.verticalCenter: parent.verticalCenter

                    Row {
                        id: weatherWidget
                        anchors.centerIn: parent
                        spacing: 5

                        Text {
                            text: shell.weatherMenu?.currentIcon ?? "󰖙"
                            color: shell.weatherMenu?.opened ? shell.theme.accent : shell.theme.accent
                            font.family: shell.fontFamily
                            font.pixelSize: 14
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: shell.weatherMenu?.currentTemp ?? "--°C"
                            color: shell.weatherMenu?.opened ? shell.theme.accent : shell.theme.fg
                            font.family: shell.fontFamily
                            font.pixelSize: 11
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    // Aktiflik Çizgisi
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: weatherWidget.implicitWidth
                        height: 2
                        radius: 1
                        color: shell.theme.accent
                        visible: shell.weatherMenu?.opened ?? false
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: shell.weatherMenu.toggle(bar.width / 2 - 40, shell.barHeight + 6)
                    }
                }
            }

            // Boşluk
            Item { Layout.fillWidth: true }

            // ═══════════════ SAĞ: Sistem Tepsisi, Kaynaklar, Ağ, Ekran, BT, Pil, Ses, Tema ve Güç ═══════════════
            Row {
                Layout.alignment: Qt.AlignVCenter
                spacing: 8

                // Sistem Tepsisi (SNI)
                Row {
                    spacing: 6
                    anchors.verticalCenter: parent.verticalCenter

                    Repeater {
                        model: SystemTray.items
                        delegate: Item {
                            required property var modelData
                            width: 18
                            height: 18
                            anchors.verticalCenter: parent.verticalCenter

                            Image {
                                anchors.fill: parent
                                source: modelData.icon ?? ""
                                fillMode: Image.PreserveAspectFit
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: function(mouse) {
                                    modelData.activate(mouse.x, mouse.y)
                                }
                            }
                        }
                    }
                }

                // Sistem Kaynak Monitörü (btop kısayolu)
                Rectangle {
                    height: 22
                    width: resText.implicitWidth + 16
                    radius: 11
                    color: resMouse.containsMouse ? shell.theme.accent : shell.theme.surface
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        id: resText
                        anchors.centerIn: parent
                        color: resMouse.containsMouse ? shell.theme.bg : shell.theme.fg
                        font.family: shell.fontFamily
                        font.pixelSize: 11
                        text: "󰍛 SYS"
                    }

                    MouseArea {
                        id: resMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Hyprland.dispatch("exec kitty -e btop")
                    }
                }

                // 1. Ağ Göstergesi (Tıklanınca NetworkMenu açılır)
                Item {
                    width: netText.implicitWidth + 16
                    height: 24
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle {
                        anchors.fill: parent
                        radius: 11
                        color: netMouse.containsMouse ? shell.theme.accent : shell.theme.surface

                        Text {
                            id: netText
                            anchors.centerIn: parent
                            color: netMouse.containsMouse ? shell.theme.bg : (Networking.connectivity >= 3 ? shell.theme.fg : shell.theme.dim)
                            font.family: shell.fontFamily
                            font.pixelSize: 11
                            text: Networking.connectivity >= 3 ? "󰤨 NET" : "󰤭 OFFLINE"
                        }
                    }

                    // Aktiflik Çizgisi
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width - 4
                        height: 2
                        radius: 1
                        color: shell.theme.accent
                        visible: shell.networkMenu?.opened ?? false
                    }

                    MouseArea {
                        id: netMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: shell.networkMenu.toggle(bar.width - 480, shell.barHeight + 6)
                    }
                }

                // 2. Ekran & Ölçekleme Göstergesi (Tıklanınca DisplayMenu açılır)
                Item {
                    width: 24
                    height: 24
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle {
                        anchors.fill: parent
                        radius: 12
                        color: dispMouse.containsMouse ? shell.theme.accent : shell.theme.surface

                        Text {
                            anchors.centerIn: parent
                            text: "󰍹"
                            color: dispMouse.containsMouse ? shell.theme.bg : shell.theme.fg
                            font.family: shell.fontFamily
                            font.pixelSize: 12
                        }
                    }

                    // Aktiflik Çizgisi
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width - 4
                        height: 2
                        radius: 1
                        color: shell.theme.accent
                        visible: shell.displayMenu?.opened ?? false
                    }

                    MouseArea {
                        id: dispMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: shell.displayMenu.toggle(bar.width - 400, shell.barHeight + 6)
                    }
                }

                // 3. Bluetooth Göstergesi
                Rectangle {
                    height: 22
                    width: btText.implicitWidth + 16
                    radius: 11
                    color: btMouse.containsMouse ? shell.theme.accent : shell.theme.surface
                    anchors.verticalCenter: parent.verticalCenter
                    visible: Bluetooth.defaultAdapter !== null

                    Text {
                        id: btText
                        anchors.centerIn: parent
                        color: btMouse.containsMouse ? shell.theme.bg : ((Bluetooth.defaultAdapter?.enabled ?? false) ? shell.theme.fg : shell.theme.dim)
                        font.family: shell.fontFamily
                        font.pixelSize: 11
                        text: (Bluetooth.defaultAdapter?.enabled ?? false) ? "󰂯 BT" : "󰂲 OFF"
                    }

                    MouseArea {
                        id: btMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: shell.bluetoothMenu.openAt(bar.width - 330, shell.barHeight + 6)
                    }
                }

                // 4. Pil Durumu (Sadece donanımda pil varsa)
                Rectangle {
                    height: 22
                    width: batText.implicitWidth + 16
                    radius: 11
                    color: shell.theme.surface
                    anchors.verticalCenter: parent.verticalCenter
                    visible: UPower.displayDevice?.isPresent ?? false

                    Text {
                        id: batText
                        anchors.centerIn: parent
                        color: shell.theme.fg
                        font.family: shell.fontFamily
                        font.pixelSize: 11
                        property int pct: Math.round((UPower.displayDevice?.percentage ?? 0) * 100)
                        text: (!UPower.onBattery ? "󰂄 " : "󰁹 ") + pct + "%"
                    }
                }

                // 5. Ses Seviyesi (Tıklanınca AudioMenu açılır)
                Item {
                    width: volText.implicitWidth + 16
                    height: 24
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle {
                        anchors.fill: parent
                        radius: 11
                        color: volMouse.containsMouse ? shell.theme.accent : shell.theme.surface

                        Text {
                            id: volText
                            anchors.centerIn: parent
                            color: volMouse.containsMouse ? shell.theme.bg : shell.theme.fg
                            font.family: shell.fontFamily
                            font.pixelSize: 11

                            property var sink: Pipewire.defaultAudioSink
                            property int vol: sink?.audio?.volume ? Math.round(sink.audio.volume * 100) : 0
                            property bool muted: sink?.audio?.muted ?? false
                            text: muted ? "󰖁 MUTE" : "󰕾 " + vol + "%"
                        }
                    }

                    // Aktiflik Çizgisi
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width - 4
                        height: 2
                        radius: 1
                        color: shell.theme.accent
                        visible: shell.audioMenu?.opened ?? false
                    }

                    MouseArea {
                        id: volMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        onClicked: function(mouse) {
                            if (mouse.button === Qt.RightButton) {
                                var sink = Pipewire.defaultAudioSink;
                                if (sink && sink.audio) {
                                    sink.audio.muted = !sink.audio.muted;
                                }
                            } else {
                                shell.audioMenu.toggle(bar.width - 380, shell.barHeight + 6)
                            }
                        }
                    }
                }

                // 6. Tema Değiştirici Butonu
                Rectangle {
                    width: themeLabel.implicitWidth + 16
                    height: 22
                    radius: 11
                    color: themeMouse.containsMouse ? shell.theme.accent : shell.theme.surface
                    border.color: shell.theme.dim
                    border.width: 1
                    anchors.verticalCenter: parent.verticalCenter

                    Row {
                        anchors.centerIn: parent
                        spacing: 6

                        Rectangle {
                            width: 8
                            height: 8
                            radius: 4
                            color: themeMouse.containsMouse ? shell.theme.bg : shell.theme.accent
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            id: themeLabel
                            text: shell.currentThemeName
                            color: themeMouse.containsMouse ? shell.theme.bg : shell.theme.fg
                            font.family: shell.fontFamily
                            font.pixelSize: 11
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: themeMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: shell.themeMenu.openAt(bar.width - 220, shell.barHeight + 6)
                    }
                }

                // 7. Kilit & Güç Butonu
                Rectangle {
                    width: 24
                    height: 24
                    radius: 12
                    color: pwrMouse.containsMouse ? "#f38ba8" : shell.theme.surface
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        anchors.centerIn: parent
                        text: "󰐥"
                        color: pwrMouse.containsMouse ? "#11111b" : shell.theme.fg
                        font.family: shell.fontFamily
                        font.pixelSize: 12
                    }

                    MouseArea {
                        id: pwrMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        onClicked: function(mouse) {
                            if (mouse.button === Qt.RightButton) {
                                shell.lock.toggle()
                            } else {
                                shell.powerMenu.open()
                            }
                        }
                    }
                }
            }
        }
    }
}
