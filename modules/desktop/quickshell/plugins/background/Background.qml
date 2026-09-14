import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

PanelWindow {
    id: root
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Background

    Item {
        anchors.fill: parent

        // ═══════════════ 1. Zengin Arka Plan ve Atmosfer ═══════════════
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { position: 0.0; color: shell.theme.bg }
                GradientStop { position: 0.5; color: shell.theme.surface }
                GradientStop { position: 1.0; color: shell.theme.bg }
            }
        }

        // Tematik Sanatsal Duvar Kağıdı
        Image {
            id: wallpaperImg
            anchors.fill: parent
            source: shell.theme.wallpaper ? Qt.resolvedUrl("../../wallpapers/" + shell.theme.wallpaper) : ""
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            opacity: status === Image.Ready ? 0.65 : 0.0
            Behavior on opacity { NumberAnimation { duration: 400 } }
        }

        // Fütüristik Geometrik Izgara Çizgileri (Subtle Cyber Grid)
        Canvas {
            id: cyberGrid
            anchors.fill: parent
            opacity: 0.05
            onPaint: {
                var ctx = getContext("2d");
                ctx.strokeStyle = shell.theme.accent;
                ctx.lineWidth = 1;
                var step = 48;
                for (var x = 0; x < width; x += step) {
                    ctx.beginPath();
                    ctx.moveTo(x, 0);
                    ctx.lineTo(x, height);
                    ctx.stroke();
                }
                for (var y = 0; y < height; y += step) {
                    ctx.beginPath();
                    ctx.moveTo(0, y);
                    ctx.lineTo(width, y);
                    ctx.stroke();
                }
            }
        }

        Connections {
            target: shell
            function onCurrentThemeNameChanged() {
                cyberGrid.requestPaint()
            }
        }

        // Merkezde Geniş ve Yumuşak Radyal Parıltı (Accent Glow)
        Rectangle {
            width: Math.min(parent.width, parent.height) * 0.85
            height: width
            radius: width / 2
            anchors.centerIn: parent
            color: shell.theme.accent
            opacity: 0.04
        }

        // ═══════════════ 2. Merkez Masaüstü Paneli & Karşılama ═══════════════
        Column {
            anchors.centerIn: parent
            spacing: 24
            width: Math.min(680, parent.width - 48)

            // Saat & Tarih Başlığı
            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 4

                Text {
                    id: bigClock
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: shell.theme.fg
                    font.family: shell.fontFamily
                    font.pixelSize: 64
                    font.bold: true
                    property var now: new Date()
                    text: Qt.formatDateTime(now, "HH:mm")

                    Timer {
                        running: true
                        repeat: true
                        interval: 1000
                        onTriggered: bigClock.now = new Date()
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: shell.theme.dim
                    font.family: shell.fontFamily
                    font.pixelSize: 14
                    font.bold: true
                    text: Qt.formatDateTime(bigClock.now, "dddd, d MMMM yyyy")
                }
            }

            // Xmarchy Amblemi & Marka Vurgusu
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 12

                Text {
                    text: "󰣇"
                    color: shell.theme.accent
                    font.family: shell.fontFamily
                    font.pixelSize: 32
                    anchors.verticalCenter: parent.verticalCenter
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2

                    Text {
                        text: "X M A R C H Y   O S"
                        color: shell.theme.fg
                        font.family: shell.fontFamily
                        font.pixelSize: 22
                        font.letterSpacing: 6
                        font.bold: true
                    }

                    Text {
                        text: "Declarative Sovereign Desktop • NixOS Powered"
                        color: shell.theme.accent
                        font.family: shell.fontFamily
                        font.pixelSize: 11
                        font.letterSpacing: 2
                    }
                }
            }

            // ═══════════════ 3. İnteraktif Hızlı Erişim Butonları ═══════════════
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 12

                // Buton: Terminal
                Rectangle {
                    width: 130
                    height: 40
                    radius: 8
                    color: termMouse.containsMouse ? shell.theme.accent : shell.theme.surface
                    border.color: shell.theme.accent
                    border.width: 1

                    Row {
                        anchors.centerIn: parent
                        spacing: 8
                        Text {
                            text: "󰞷"
                            color: termMouse.containsMouse ? shell.theme.bg : shell.theme.accent
                            font.family: shell.fontFamily
                            font.pixelSize: 16
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: "Terminal"
                            color: termMouse.containsMouse ? shell.theme.bg : shell.theme.fg
                            font.family: shell.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: termMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Hyprland.dispatch("exec kitty")
                    }
                }

                // Buton: Uygulama Başlatıcı
                Rectangle {
                    width: 140
                    height: 40
                    radius: 8
                    color: appMouse.containsMouse ? shell.theme.accent : shell.theme.surface
                    border.color: shell.theme.accent
                    border.width: 1

                    Row {
                        anchors.centerIn: parent
                        spacing: 8
                        Text {
                            text: "󰍉"
                            color: appMouse.containsMouse ? shell.theme.bg : shell.theme.accent
                            font.family: shell.fontFamily
                            font.pixelSize: 16
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: "Başlatıcı"
                            color: appMouse.containsMouse ? shell.theme.bg : shell.theme.fg
                            font.family: shell.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: appMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: shell.launcher.toggle()
                    }
                }

                // Buton: Tarayıcı
                Rectangle {
                    width: 130
                    height: 40
                    radius: 8
                    color: browMouse.containsMouse ? shell.theme.accent : shell.theme.surface
                    border.color: shell.theme.accent
                    border.width: 1

                    Row {
                        anchors.centerIn: parent
                        spacing: 8
                        Text {
                            text: "󰈹"
                            color: browMouse.containsMouse ? shell.theme.bg : shell.theme.accent
                            font.family: shell.fontFamily
                            font.pixelSize: 16
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: "Tarayıcı"
                            color: browMouse.containsMouse ? shell.theme.bg : shell.theme.fg
                            font.family: shell.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: browMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Hyprland.dispatch("exec brave || chromium || firefox")
                    }
                }

                // Buton: Temalar
                Rectangle {
                    width: 130
                    height: 40
                    radius: 8
                    color: themeBtnMouse.containsMouse ? shell.theme.accent : shell.theme.surface
                    border.color: shell.theme.accent
                    border.width: 1

                    Row {
                        anchors.centerIn: parent
                        spacing: 8
                        Text {
                            text: "󰔎"
                            color: themeBtnMouse.containsMouse ? shell.theme.bg : shell.theme.accent
                            font.family: shell.fontFamily
                            font.pixelSize: 16
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: "Temalar"
                            color: themeBtnMouse.containsMouse ? shell.theme.bg : shell.theme.fg
                            font.family: shell.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: themeBtnMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: shell.themeMenu.openAt(root.width / 2 - 110, root.height / 2 - 120)
                    }
                }
            }

            // ═══════════════ 4. Klavye Kısayolları Bilgi Şeridi ═══════════════
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                height: 48
                radius: 8
                color: shell.theme.surface
                opacity: 0.85
                border.color: shell.theme.dim
                border.width: 1

                Row {
                    anchors.centerIn: parent
                    spacing: 20

                    Row {
                        spacing: 6
                        Text { text: "Alt + Boşluk"; color: shell.theme.accent; font.family: shell.fontFamily; font.pixelSize: 11; font.bold: true }
                        Text { text: "Menü"; color: shell.theme.dim; font.family: shell.fontFamily; font.pixelSize: 11 }
                    }
                    Text { text: "•"; color: shell.theme.dim; font.pixelSize: 10 }
                    Row {
                        spacing: 6
                        Text { text: "Alt + Enter"; color: shell.theme.accent; font.family: shell.fontFamily; font.pixelSize: 11; font.bold: true }
                        Text { text: "Terminal"; color: shell.theme.dim; font.family: shell.fontFamily; font.pixelSize: 11 }
                    }
                    Text { text: "•"; color: shell.theme.dim; font.pixelSize: 10 }
                    Row {
                        spacing: 6
                        Text { text: "Alt + Q"; color: shell.theme.accent; font.family: shell.fontFamily; font.pixelSize: 11; font.bold: true }
                        Text { text: "Kapat"; color: shell.theme.dim; font.family: shell.fontFamily; font.pixelSize: 11 }
                    }
                    Text { text: "•"; color: shell.theme.dim; font.pixelSize: 10 }
                    Row {
                        spacing: 6
                        Text { text: "Sağ Tık"; color: shell.theme.accent; font.family: shell.fontFamily; font.pixelSize: 11; font.bold: true }
                        Text { text: "Canlı Tema"; color: shell.theme.dim; font.family: shell.fontFamily; font.pixelSize: 11 }
                    }
                }
            }
        }

        // ═══════════════ 5. Masaüstü Tıklama Etkileşimleri ═══════════════
        MouseArea {
            anchors.fill: parent
            z: -1
            acceptedButtons: Qt.RightButton | Qt.LeftButton
            onClicked: function(mouse) {
                if (mouse.button === Qt.RightButton) {
                    shell.themeMenu.openAt(mouse.x, mouse.y)
                }
            }
            onDoubleClicked: function(mouse) {
                if (mouse.button === Qt.LeftButton) {
                    Hyprland.dispatch("exec kitty")
                }
            }
        }
    }
}
