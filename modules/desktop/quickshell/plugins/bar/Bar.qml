import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import Quickshell.Services.SystemTray
import Quickshell.Services.UPower
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
            }

            // Boşluk
            Item { Layout.fillWidth: true }

            // ═══════════════ ORTA: Saat & Tarih ═══════════════
            Row {
                Layout.alignment: Qt.AlignCenter
                spacing: 6

                Text {
                    id: clock
                    color: shell.theme.fg
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
                    color: shell.theme.dim
                    font.family: shell.fontFamily
                    font.pixelSize: 12
                    text: "•  " + Qt.formatDateTime(clock.now, "dddd, d MMMM")
                }
            }

            // Boşluk
            Item { Layout.fillWidth: true }

            // ═══════════════ SAĞ: Sistem Tepsisi, Ağ, BT, Pil, Ses, Tema ve Güç ═══════════════
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

                // Ağ Göstergesi
                Rectangle {
                    height: 22
                    width: netText.implicitWidth + 16
                    radius: 11
                    color: shell.theme.surface
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        id: netText
                        anchors.centerIn: parent
                        color: Networking.connectivity >= 3 ? shell.theme.fg : shell.theme.dim
                        font.family: shell.fontFamily
                        font.pixelSize: 11
                        text: Networking.connectivity >= 3 ? "󰤨 NET" : "󰤭 OFFLINE"
                    }
                }

                // Bluetooth Göstergesi
                Rectangle {
                    height: 22
                    width: btText.implicitWidth + 16
                    radius: 11
                    color: shell.theme.surface
                    anchors.verticalCenter: parent.verticalCenter
                    visible: Bluetooth.defaultAdapter !== null

                    Text {
                        id: btText
                        anchors.centerIn: parent
                        color: (Bluetooth.defaultAdapter?.enabled ?? false) ? shell.theme.fg : shell.theme.dim
                        font.family: shell.fontFamily
                        font.pixelSize: 11
                        text: (Bluetooth.defaultAdapter?.enabled ?? false) ? "󰂯 BT" : "󰂲 OFF"
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (Bluetooth.defaultAdapter) {
                                Bluetooth.defaultAdapter.enabled = !Bluetooth.defaultAdapter.enabled
                            }
                        }
                    }
                }

                // Pil Durumu (Sadece donanımda pil varsa)
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

                // Ses Seviyesi
                Rectangle {
                    height: 22
                    width: volText.implicitWidth + 16
                    radius: 11
                    color: shell.theme.surface
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        id: volText
                        anchors.centerIn: parent
                        color: shell.theme.fg
                        font.family: shell.fontFamily
                        font.pixelSize: 11

                        property var sink: Pipewire.defaultAudioSink
                        property int vol: sink?.audio?.volume ? Math.round(sink.audio.volume * 100) : 0
                        property bool muted: sink?.audio?.muted ?? false
                        text: muted ? "󰖁 MUTE" : "󰕾 " + vol + "%"
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            var sink = Pipewire.defaultAudioSink;
                            if (sink && sink.audio) {
                                sink.audio.muted = !sink.audio.muted;
                            }
                        }
                    }
                }

                // Tema Değiştirici Butonu
                Rectangle {
                    width: themeLabel.implicitWidth + 16
                    height: 22
                    radius: 11
                    color: shell.theme.surface
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
                            color: shell.theme.accent
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            id: themeLabel
                            text: shell.currentThemeName
                            color: shell.theme.fg
                            font.family: shell.fontFamily
                            font.pixelSize: 11
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: shell.themeMenu.openAt(bar.width - 220, shell.barHeight + 6)
                    }
                }

                // Kilit & Güç Butonu
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
                        onClicked: shell.lock.toggle()
                    }
                }
            }
        }
    }
}
