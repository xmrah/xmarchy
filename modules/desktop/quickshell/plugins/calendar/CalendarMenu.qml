import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

Item {
    id: root

    property bool opened: false
    property var today: new Date()
    property int viewYear: today.getFullYear()
    property int viewMonth: today.getMonth() // 0-indexed

    readonly property var monthNames: [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
    ]

    readonly property var weekdays: ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]

    function openAt(x: int, y: int) {
        root.today = new Date()
        root.viewYear = root.today.getFullYear()
        root.viewMonth = root.today.getMonth()
        root.opened = true
    }

    function toggle() {
        if (root.opened) {
            root.opened = false
        } else {
            root.openAt(0, 0)
        }
    }

    function prevMonth() {
        if (viewMonth === 0) {
            viewMonth = 11
            viewYear--
        } else {
            viewMonth--
        }
    }

    function nextMonth() {
        if (viewMonth === 11) {
            viewMonth = 0
            viewYear++
        } else {
            viewMonth++
        }
    }

    function resetToToday() {
        root.today = new Date()
        root.viewYear = root.today.getFullYear()
        root.viewMonth = root.today.getMonth()
    }

    // Yıl ilerleme yüzdesi (0.0 - 1.0)
    readonly property real yearProgress: {
        var start = new Date(today.getFullYear(), 0, 1)
        var diff = (today - start) + ((start.getTimezoneOffset() - today.getTimezoneOffset()) * 60 * 1000)
        var oneDay = 1000 * 60 * 60 * 24
        var day = Math.floor(diff / oneDay) + 1
        var isLeap = (today.getFullYear() % 4 === 0 && today.getFullYear() % 100 !== 0) || (today.getFullYear() % 400 === 0)
        var total = isLeap ? 366 : 365
        return Math.min(1.0, Math.max(0.0, day / total))
    }

    // ISO Hafta Numarası Hesaplama
    function getIsoWeek(d) {
        var target = new Date(d.valueOf())
        var dayNr = (d.getDay() + 6) % 7
        target.setDate(target.getDate() - dayNr + 3)
        var firstThursday = target.valueOf()
        target.setMonth(0, 1)
        if (target.getDay() !== 4) {
            target.setMonth(0, 1 + ((4 - target.getDay()) + 7) % 7)
        }
        return 1 + Math.ceil((firstThursday - target) / 604800000)
    }

    // 42 günlük takvim matrisi ve 6 haftalık ISO numaraları
    property var gridData: generateCalendar(viewYear, viewMonth)

    function generateCalendar(year, month) {
        var firstDayOfWeek = new Date(year, month, 1).getDay() // 0 = Sunday
        var daysInCurMonth = new Date(year, month + 1, 0).getDate()
        var daysInPrevMonth = new Date(year, month, 0).getDate()

        var weeks = []
        var cells = []

        // Önceki aydan taşan günler
        for (var i = firstDayOfWeek - 1; i >= 0; i--) {
            var pDate = new Date(year, month - 1, daysInPrevMonth - i)
            cells.push({
                day: daysInPrevMonth - i,
                inMonth: false,
                isToday: false,
                date: pDate
            })
        }

        // Mevcut ayın günleri
        var nowYear = today.getFullYear()
        var nowMonth = today.getMonth()
        var nowDay = today.getDate()

        for (var d = 1; d <= daysInCurMonth; d++) {
            var cDate = new Date(year, month, d)
            var isCurrent = (year === nowYear && month === nowMonth && d === nowDay)
            cells.push({
                day: d,
                inMonth: true,
                isToday: isCurrent,
                date: cDate
            })
        }

        // Sonraki aydan taşan günler (toplam 42 hücreye tamamla: 6 hafta)
        var nextDays = 42 - cells.length
        for (var n = 1; n <= nextDays; n++) {
            var nDate = new Date(year, month + 1, n)
            cells.push({
                day: n,
                inMonth: false,
                isToday: false,
                date: nDate
            })
        }

        // 6 haftalık satırlara ve hafta numaralarına böl
        for (var w = 0; w < 6; w++) {
            var rowDays = cells.slice(w * 7, (w + 1) * 7)
            // Satırın ortasındaki günü (Çarşamba) referans alarak hafta numarasını bul
            var midDay = rowDays[3].date
            var isoW = getIsoWeek(midDay)
            weeks.push({
                weekNum: isoW,
                days: rowDays
            })
        }

        return weeks
    }

    onViewYearChanged: gridData = generateCalendar(viewYear, viewMonth)
    onViewMonthChanged: gridData = generateCalendar(viewYear, viewMonth)

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
                width: 460
                height: 440
                anchors.horizontalCenter: parent.horizontalCenter
                y: shell.barHeight + 6
                radius: 12
                color: shell.theme.bg
                border.color: shell.theme.accent
                border.width: 1

                Column {
                    anchors.fill: parent
                    anchors.margins: 24
                    spacing: 16

                    // ═══════════════ 1. Kahraman Başlık (Hero Header) ═══════════════
                    Row {
                        spacing: 14
                        anchors.horizontalCenter: parent.horizontalCenter

                        Text {
                            text: "󰸗"
                            color: shell.theme.accent
                            font.family: shell.fontFamily
                            font.pixelSize: 34
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: root.monthNames[root.today.getMonth()] + "  " + root.today.getDate()
                            color: shell.theme.fg
                            font.family: shell.fontFamily
                            font.pixelSize: 34
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    // ═══════════════ 2. Yıl İlerleme Çubuğu (Year Progress) ═══════════════
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 12

                        Text {
                            text: root.today.getFullYear()
                            color: shell.theme.dim
                            font.family: shell.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        // Progress Bar Track
                        Rectangle {
                            width: 280
                            height: 6
                            radius: 3
                            color: shell.theme.surface
                            anchors.verticalCenter: parent.verticalCenter

                            // Fill
                            Rectangle {
                                height: parent.height
                                width: parent.width * root.yearProgress
                                radius: 3
                                color: shell.theme.accent
                            }
                        }

                        Text {
                            text: Math.round(root.yearProgress * 100) + "%"
                            color: shell.theme.dim
                            font.family: shell.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    // ═══════════════ 3. Takvim Başlıkları (W, SUN..SAT) ═══════════════
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 8

                        // Week Column Title
                        Text {
                            width: 28
                            text: "W"
                            horizontalAlignment: Text.AlignHCenter
                            color: shell.theme.dim
                            font.family: shell.fontFamily
                            font.pixelSize: 11
                            font.bold: true
                        }

                        Repeater {
                            model: root.weekdays
                            delegate: Text {
                                required property var modelData
                                width: 44
                                text: modelData
                                horizontalAlignment: Text.AlignHCenter
                                color: shell.theme.dim
                                font.family: shell.fontFamily
                                font.pixelSize: 11
                                font.bold: true
                            }
                        }
                    }

                    // ═══════════════ 4. Günler Matrisi (6 Hafta x 7 Gün) ═══════════════
                    Column {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 6

                        Repeater {
                            model: root.gridData
                            delegate: Row {
                                required property var modelData
                                spacing: 8

                                // Hafta Numarası
                                Text {
                                    width: 28
                                    height: 28
                                    text: modelData.weekNum
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    color: shell.theme.dim
                                    font.family: shell.fontFamily
                                    font.pixelSize: 11
                                }

                                // 7 Gün Hücreleri
                                Repeater {
                                    model: modelData.days
                                    delegate: Rectangle {
                                        required property var modelData
                                        width: 44
                                        height: 28
                                        radius: 6
                                        color: modelData.isToday ? shell.theme.surface : "transparent"
                                        border.color: modelData.isToday ? shell.theme.accent : "transparent"
                                        border.width: modelData.isToday ? 1 : 0

                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.day
                                            color: modelData.isToday ? shell.theme.accent : (modelData.inMonth ? shell.theme.fg : shell.theme.dim)
                                            font.family: shell.fontFamily
                                            font.pixelSize: 12
                                            font.bold: modelData.isToday
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // ═══════════════ 5. Alt Navigasyon Barı (< AY YIL >) ═══════════════
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 24

                        // Sol Ok (Önceki Ay)
                        Rectangle {
                            width: 28
                            height: 24
                            radius: 4
                            color: prevMouse.containsMouse ? shell.theme.surface : "transparent"
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                anchors.centerIn: parent
                                text: "❮"
                                color: prevMouse.containsMouse ? shell.theme.accent : shell.theme.dim
                                font.pixelSize: 12
                            }

                            MouseArea {
                                id: prevMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.prevMonth()
                            }
                        }

                        // Ay & Yıl Başlığı (Tıklandığında bugüne döner)
                        Text {
                            text: root.monthNames[root.viewMonth].toUpperCase() + "  " + root.viewYear
                            color: monthTitleMouse.containsMouse ? shell.theme.accent : shell.theme.dim
                            font.family: shell.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                            font.letterSpacing: 2
                            anchors.verticalCenter: parent.verticalCenter

                            MouseArea {
                                id: monthTitleMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.resetToToday()
                            }
                        }

                        // Sağ Ok (Sonraki Ay)
                        Rectangle {
                            width: 28
                            height: 24
                            radius: 4
                            color: nextMouse.containsMouse ? shell.theme.surface : "transparent"
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                anchors.centerIn: parent
                                text: "❯"
                                color: nextMouse.containsMouse ? shell.theme.accent : shell.theme.dim
                                font.pixelSize: 12
                            }

                            MouseArea {
                                id: nextMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.nextMonth()
                            }
                        }
                    }
                }
            }

            Item {
                focus: root.opened
                Keys.onEscapePressed: root.opened = false
                Keys.onLeftPressed: root.prevMonth()
                Keys.onRightPressed: root.nextMonth()
            }
        }
    }
}
