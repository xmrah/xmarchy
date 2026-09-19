import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pam
import Quickshell.Io

Item {
    id: root

    property bool locked: false
    property string password: ""
    property string status: ""
    property bool showPassword: false

    WlSessionLock {
        id: lockSession
        locked: root.locked

        WlSessionLockSurface {
            color: shell.theme.bg

            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(0, 0, 0, 0.45) // Arka plan karartma
            }

            // Merkez Kilit Kartı (Modern Glassmorphism)
            Rectangle {
                id: card
                anchors.centerIn: parent
                width: 380
                height: contentCol.implicitHeight + 48
                radius: 20
                color: Qt.rgba(shell.theme.bg.r, shell.theme.bg.g, shell.theme.bg.b, 0.88)
                border.color: root.status === "Hatalı şifre!" 
                    ? "#f38ba8" 
                    : Qt.rgba(shell.theme.accent.r, shell.theme.accent.g, shell.theme.accent.b, 0.45)
                border.width: 1.5

                Column {
                    id: contentCol
                    anchors.centerIn: parent
                    width: parent.width - 48
                    spacing: 16

                    // Saat
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: shell.theme.accent
                        font.family: shell.fontFamily
                        font.pixelSize: 54
                        font.bold: true
                        text: Qt.formatDateTime(new Date(), "HH:mm")

                        Timer {
                            running: root.locked
                            repeat: true
                            interval: 1000
                            onTriggered: parent.text = Qt.formatDateTime(new Date(), "HH:mm")
                        }
                    }

                    // Tarih
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: shell.theme.dim
                        font.family: shell.fontFamily
                        font.pixelSize: 14
                        text: Qt.formatDateTime(new Date(), "dddd, d MMMM yyyy")
                    }

                    // Kullanıcı Rozeti
                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: userRow.implicitWidth + 24
                        height: 32
                        radius: 16
                        color: Qt.rgba(shell.theme.fg.r, shell.theme.fg.g, shell.theme.fg.b, 0.08)

                        Row {
                            id: userRow
                            anchors.centerIn: parent
                            spacing: 8

                            Text {
                                text: "󰌾"
                                color: shell.theme.accent
                                font.family: "JetBrains Mono Nerd Font"
                                font.pixelSize: 14
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: Quickshell.env("USER") !== "" ? Quickshell.env("USER") : "nixos"
                                color: shell.theme.fg
                                font.family: shell.fontFamily
                                font.pixelSize: 13
                                font.bold: true
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }

                    // Şifre Giriş Kutusu (Şifreyi Göster Butonlu)
                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width
                        height: 46
                        radius: 12
                        color: Qt.rgba(shell.theme.fg.r, shell.theme.fg.g, shell.theme.fg.b, 0.06)
                        border.color: passInput.activeFocus 
                            ? shell.theme.accent 
                            : Qt.rgba(shell.theme.fg.r, shell.theme.fg.g, shell.theme.fg.b, 0.2)
                        border.width: passInput.activeFocus ? 2 : 1

                        RowLayout {
                            anchors { fill: parent; leftMargin: 14; rightMargin: 10 }
                            spacing: 8

                            TextInput {
                                id: passInput
                                Layout.fillWidth: true
                                color: shell.theme.fg
                                font.family: shell.fontFamily
                                font.pixelSize: 15
                                echoMode: root.showPassword ? TextInput.Normal : TextInput.Password
                                passwordCharacter: "●"
                                focus: root.locked

                                Keys.onReturnPressed: {
                                    if (passInput.text.length > 0) {
                                        root.password = passInput.text
                                        root.status = "Doğrulanıyor..."
                                        pam.start()
                                    }
                                }

                                Text {
                                    text: "Şifre..."
                                    color: shell.theme.dim
                                    font.family: shell.fontFamily
                                    font.pixelSize: 14
                                    visible: passInput.text.length === 0 && !passInput.activeFocus
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            // Şifreyi Göster / Gizle Butonu (Göz İkonu)
                            Rectangle {
                                width: 28
                                height: 28
                                radius: 6
                                color: eyeMouse.containsMouse 
                                    ? Qt.rgba(shell.theme.fg.r, shell.theme.fg.g, shell.theme.fg.b, 0.12)
                                    : "transparent"

                                Text {
                                    anchors.centerIn: parent
                                    text: root.showPassword ? "󰈈" : "󰈉"
                                    color: root.showPassword ? shell.theme.accent : shell.theme.dim
                                    font.family: "JetBrains Mono Nerd Font"
                                    font.pixelSize: 16
                                }

                                MouseArea {
                                    id: eyeMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.showPassword = !root.showPassword
                                }
                            }
                        }
                    }

                    // Durum / Hata Mesajı
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: root.status === "Hatalı şifre!" ? "#f38ba8" : shell.theme.dim
                        font.family: shell.fontFamily
                        font.pixelSize: 12
                        font.bold: root.status === "Hatalı şifre!"
                        text: root.status
                        visible: root.status !== ""
                    }
                }
            }
        }
    }

    PamContext {
        id: pam
        configDirectory: "/etc/pam.d"
        config: "quickshell-lock"

        onPamMessage: function(msg) {
            if (msg && msg !== "") {
                root.status = msg
            }
        }

        // KRİTİK GÜVENLİK DÜZELTMESİ:
        // Yalnızca PAM sonucu PamResult.Success olduğunda kilit açılır!
        onCompleted: function(result) {
            if (result === PamResult.Success) {
                root.locked = false
                root.password = ""
                root.status = ""
                passInput.text = ""
                root.showPassword = false
            } else {
                root.status = "Hatalı şifre!"
                passInput.text = ""
                passInput.forceActiveFocus()
            }
        }

        onError: function(err) {
            root.status = "Hatalı şifre!"
            passInput.text = ""
            passInput.forceActiveFocus()
        }

        onResponseRequiredChanged: {
            if (pam.responseRequired) {
                pam.respond(root.password)
            }
        }
    }

    IpcHandler {
        target: "lock"

        function lock() {
            root.locked = true
            root.status = ""
            passInput.forceActiveFocus()
        }

        function toggle() {
            if (!root.locked) {
                root.locked = true
                root.status = ""
                passInput.forceActiveFocus()
            }
        }
    }
}
