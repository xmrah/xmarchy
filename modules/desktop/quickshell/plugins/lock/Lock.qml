import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pam
import Quickshell.Io

Item {
    id: root

    property bool locked: false
    property string password: ""
    property string status: ""

    WlSessionLock {
        id: lockSession
        locked: root.locked

        WlSessionLockSurface {
            color: shell.theme.bg

            Column {
                anchors.centerIn: parent
                spacing: 16

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: shell.theme.fg
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

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: shell.theme.dim
                    font.family: shell.fontFamily
                    font.pixelSize: 16
                    text: Qt.formatDateTime(new Date(), "dddd, d MMMM yyyy")
                }

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 300
                    height: 44
                    color: "transparent"
                    border.color: shell.theme.fg
                    border.width: 1

                    TextInput {
                        id: passInput
                        anchors { fill: parent; margins: 12 }
                        color: shell.theme.fg
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

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: root.status === "Incorrect" ? "#FF4444" : shell.theme.dim
                    font.family: shell.fontFamily
                    font.pixelSize: 12
                    text: root.status
                }
            }
        }
    }

    PamContext {
        id: pam
        configDirectory: "/etc/pam.d"
        config: "quickshell-lock"

        onPamMessage: function(msg) {
            root.status = msg
        }

        onCompleted: {
            root.locked = false
            root.password = ""
            root.status = ""
            passInput.text = ""
        }

        onError: {
            root.status = "Incorrect"
            passInput.text = ""
        }

        onResponseRequiredChanged: {
            if (pam.responseRequired) {
                pam.respond(root.password)
            }
        }
    }

    IpcHandler {
        target: "lock"

        // Idempotent: Her zaman ekranı kilitler (zaten kilitliyse durumu bozmaz)
        function lock() {
            root.locked = true
        }

        // Manuel kısayol için: Sadece kilitli değilse kilitler.
        // Güvenlik Kuralı: Kilit açma ASLA IPC üzerinden yapılamaz; sadece PAM şifre doğrulamasıyla açılır!
        function toggle() {
            if (!root.locked) {
                root.locked = true
            }
        }
    }
}
