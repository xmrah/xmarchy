import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

Item {
    id: root

    property bool opened: false
    property int popupX: 500
    property int popupY: 40

    // Canlı Hava Durumu Verileri
    property string currentTemp: "23°C"
    property string currentIcon: "󰖙"
    property string feelsLike: "20°C"
    property string windSpeed: "9 km/h"
    property string humidity: "36%"
    property string locationName: "41.0082, 28.9784"
    property var forecastDays: [
        { day: "TUESDAY", icon: "󰖙", maxTemp: "24°", minTemp: "18°" },
        { day: "WEDNESDAY", icon: "󰖕", maxTemp: "23°", minTemp: "17°" },
        { day: "THURSDAY", icon: "󰖕", maxTemp: "24°", minTemp: "18°" }
    ]

    readonly property var dayNames: ["SUNDAY", "MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY"]

    function weatherCodeToIcon(code) {
        if (code === 0) return "󰖙" // Açık / Güneşli
        if (code <= 3) return "󰖕" // Parçalı Bulutlu
        if (code >= 45 && code <= 48) return "󰖑" // Sis
        if (code >= 51 && code <= 67) return "󰖗" // Yağmur
        if (code >= 71 && code <= 86) return "󰼶" // Kar
        if (code >= 95) return "󰙾" // Fırtına
        return "󰖐" // Bulutlu
    }

    function fetchWeather() {
        var xhr = new XMLHttpRequest()
        xhr.open("GET", "https://api.open-meteo.com/v1/forecast?latitude=41.0082&longitude=28.9784&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m&daily=weather_code,temperature_2m_max,temperature_2m_min&timezone=auto&forecast_days=4")
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                try {
                    var res = JSON.parse(xhr.responseText)
                    var cur = res.current
                    root.currentTemp = Math.round(cur.temperature_2m) + "°C"
                    root.feelsLike = Math.round(cur.apparent_temperature) + "°C"
                    root.windSpeed = Math.round(cur.wind_speed_10m) + " km/h"
                    root.humidity = Math.round(cur.relative_humidity_2m) + "%"
                    root.currentIcon = weatherCodeToIcon(cur.weather_code)

                    var daily = res.daily
                    var daysList = []
                    // İndeks 1, 2, 3 (Gelecek 3 gün)
                    for (var i = 1; i <= 3 && i < daily.time.length; i++) {
                        var dateObj = new Date(daily.time[i] + "T12:00:00")
                        var dName = root.dayNames[dateObj.getDay()]
                        daysList.push({
                            day: dName,
                            icon: weatherCodeToIcon(daily.weather_code[i]),
                            maxTemp: Math.round(daily.temperature_2m_max[i]) + "°",
                            minTemp: Math.round(daily.temperature_2m_min[i]) + "°"
                        })
                    }
                    if (daysList.length > 0) {
                        root.forecastDays = daysList
                    }
                } catch (e) {}
            }
        }
        xhr.send()
    }

    Component.onCompleted: fetchWeather()

    Timer {
        interval: 900000 // 15 dakikada bir güncelle
        running: true
        repeat: true
        onTriggered: root.fetchWeather()
    }

    function openAt(x: int, y: int) {
        root.popupX = Math.max(10, Math.min(x, 1920 - 460))
        root.popupY = shell.barHeight + 6
        root.opened = true
        root.fetchWeather()
    }

    function toggle(x: int, y: int) {
        if (root.opened) {
            root.opened = false
        } else {
            root.openAt(x, y)
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
                id: popupCard
                width: 480
                height: 220
                x: root.popupX
                y: root.popupY
                radius: 12
                color: shell.theme.bg
                border.color: shell.theme.accent
                border.width: 1

                Column {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 16

                    // ═══════════════ 1. Üst Kahraman Bölümü (Hero & Detaylar) ═══════════════
                    RowLayout {
                        width: parent.width
                        spacing: 16

                        // Sol: Büyük Hava İkonu ve Büyük Sıcaklık
                        Row {
                            spacing: 12
                            Layout.alignment: Qt.AlignVCenter

                            Text {
                                text: root.currentIcon
                                color: shell.theme.accent
                                font.family: shell.fontFamily
                                font.pixelSize: 44
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: root.currentTemp
                                color: shell.theme.fg
                                font.family: shell.fontFamily
                                font.pixelSize: 42
                                font.bold: true
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Item { Layout.fillWidth: true }

                        // Sağ: Konum ve 3 Metrik (FEELS, WIND, HUMID)
                        Column {
                            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                            spacing: 8

                            // Konum İğnesi & Koordinat
                            Row {
                                anchors.right: parent.right
                                spacing: 6

                                Text {
                                    text: "󰍎"
                                    color: shell.theme.accent
                                    font.family: shell.fontFamily
                                    font.pixelSize: 13
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    text: root.locationName
                                    color: shell.theme.dim
                                    font.family: shell.fontFamily
                                    font.pixelSize: 11
                                    font.bold: true
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            // 3 Metrik Satırı
                            Row {
                                anchors.right: parent.right
                                spacing: 16

                                Column {
                                    spacing: 2
                                    Text { text: "FEELS"; color: shell.theme.dim; font.pixelSize: 10; font.bold: true; font.family: shell.fontFamily }
                                    Text { text: root.feelsLike; color: shell.theme.fg; font.pixelSize: 12; font.bold: true; font.family: shell.fontFamily }
                                }

                                Column {
                                    spacing: 2
                                    Text { text: "WIND"; color: shell.theme.dim; font.pixelSize: 10; font.bold: true; font.family: shell.fontFamily }
                                    Text { text: root.windSpeed; color: shell.theme.fg; font.pixelSize: 12; font.bold: true; font.family: shell.fontFamily }
                                }

                                Column {
                                    spacing: 2
                                    Text { text: "HUMID"; color: shell.theme.dim; font.pixelSize: 10; font.bold: true; font.family: shell.fontFamily }
                                    Text { text: root.humidity; color: shell.theme.fg; font.pixelSize: 12; font.bold: true; font.family: shell.fontFamily }
                                }
                            }
                        }
                    }

                    // ═══════════════ 2. Yatay Ayırıcı Çizgi ═══════════════
                    Rectangle {
                        width: parent.width
                        height: 1
                        color: shell.theme.surface
                    }

                    // ═══════════════ 3. Alt 3 Günlük Hava Tahmini ═══════════════
                    Row {
                        width: parent.width
                        spacing: 12

                        Repeater {
                            model: root.forecastDays
                            delegate: Item {
                                required property var modelData
                                width: (parent.width - 24) / 3
                                height: 50

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 4

                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: modelData.day
                                        color: shell.theme.dim
                                        font.family: shell.fontFamily
                                        font.pixelSize: 10
                                        font.bold: true
                                        font.letterSpacing: 1
                                    }

                                    Row {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        spacing: 8

                                        Text {
                                            text: modelData.icon
                                            color: shell.theme.accent
                                            font.family: shell.fontFamily
                                            font.pixelSize: 16
                                            anchors.verticalCenter: parent.verticalCenter
                                        }

                                        Row {
                                            spacing: 4
                                            anchors.verticalCenter: parent.verticalCenter

                                            Text {
                                                text: modelData.maxTemp
                                                color: shell.theme.fg
                                                font.family: shell.fontFamily
                                                font.pixelSize: 12
                                                font.bold: true
                                            }

                                            Text {
                                                text: modelData.minTemp
                                                color: shell.theme.dim
                                                font.family: shell.fontFamily
                                                font.pixelSize: 12
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
