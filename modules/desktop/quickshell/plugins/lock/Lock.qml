import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pam

// Xmarchy Brutalist Lock Screen
Item {
    id: root

    property bool locked: false
    property string password: ""
    property string status: ""

    WlSessionLock {
        id: lockSession
        locked: root.locked

        WlSessionLockSurface {
            color: shell.bg

            Column {
                anchors.centerIn: parent
                spacing: 16

                // Saat
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: shell.fg
                    font.family: shell.fontFamily
                    font.pixelSize: 64
                    font.bold: true
                    text: Qt.formatDateTime(new Date(), "HH:mm")

                    Timer {
                        running: root.locked
                        repeat: true
                        interval: 10000
                        onTriggered: parent.text = Qt.formatDateTime(new Date(), "HH:mm")
                    }
                }

                // Tarih
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: shell.dim
                    font.family: shell.fontFamily
                    font.pixelSize: 16
                    text: Qt.formatDateTime(new Date(), "dddd, d MMMM yyyy")
                }

                // Şifre alanı
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 300
                    height: 44
                    color: "transparent"
                    border.color: shell.fg
                    border.width: 1

                    TextInput {
                        id: passInput
                        anchors { fill: parent; margins: 12 }
                        color: shell.fg
                        font.family: shell.fontFamily
                        font.pixelSize: 16
                        echoMode: TextInput.Password
                        passwordCharacter: "●"
                        focus: root.locked

                        Keys.onReturnPressed: {
                            root.password = passInput.text
                            pam.start()
                        }
                    }
                }

                // Durum mesajı
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: root.status === "Incorrect" ? "#FF4444" : shell.dim
                    font.family: shell.fontFamily
                    font.pixelSize: 12
                    text: root.status
                }
            }
        }
    }

    PamContext {
        id: pam
        configDir: "/etc/pam.d"
        config: "login"

        onPamMessage: function(msg) {
            root.status = msg
        }

        onAuthSucceeded: {
            root.locked = false
            root.password = ""
            root.status = ""
            passInput.text = ""
        }

        onAuthFailed: {
            root.status = "Incorrect"
            passInput.text = ""
        }

        onAuthRequest: function(request) {
            respond(root.password)
        }
    }

    // IPC ile kilitleme
    IpcHandler {
        target: "lock"
        function toggle() {
            root.locked = !root.locked
        }
    }
}
