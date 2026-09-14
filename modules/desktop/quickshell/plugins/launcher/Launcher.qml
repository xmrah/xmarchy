import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import Quickshell.Io

Item {
    id: root

    property bool opened: false
    property string query: ""
    property var navStack: [] // array of menu IDs navigated into
    property string currentMenuId: "root"
    property var displayItems: []
    property int selectedIndex: 0

    // ═══════════════ Veri Tanımları (Tree Data) ═══════════════

    readonly property var rootCategories: [
        {
            id: "apps",
            label: "Uygulamalar",
            icon: "󰀻",
            category: "Katalog",
            subtext: "Yüklü grafik uygulamaları",
            description: "Sistemde kurulu tüm grafik uygulamaları listeleyin, arayın ve anında başlatın.",
            badge: "Apps ›",
            isMenu: true
        },
        {
            id: "tools",
            label: "Araçlar & Tetikleyiciler",
            icon: "󱓞",
            category: "Sistem Araçları",
            subtext: "Ekran görüntüsü, renk seçici, PWA",
            description: "Ekran görüntüsü alma, ekran kaydı, canlı renk seçici, uyanık kalma ve pratik yardımcılar.",
            badge: "Tools ›",
            isMenu: true
        },
        {
            id: "style",
            label: "Görünüm & Temalar",
            icon: "",
            category: "Kişiselleştirme",
            subtext: "Xmarchy renkleri, temalar, ölçek",
            description: "Xmarchy renk paletleri, temalar, duvar kağıtları ve Wayland dinamik ekran ölçekleme ayarları.",
            badge: "Style ›",
            isMenu: true
        },
        {
            id: "nixos",
            label: "NixOS & Sistem Yönetimi",
            icon: "",
            category: "NixOS Ekosistemi",
            subtext: "Rebuild, update, çöp temizliği",
            description: "Sistem yapılandırma yenileme (rebuild), flake güncellemeleri, çöp temizliği ve servis kontrolleri.",
            badge: "NixOS ›",
            isMenu: true
        },
        {
            id: "setup",
            label: "Yapılandırma & Ağ",
            icon: "",
            category: "Ağ & Ayarlar",
            subtext: "DNS sağlayıcıları, varsayılanlar",
            description: "Tek tıkla DNS sağlayıcı geçişi (Cloudflare, Google, DHCP), varsayılan editör ve terminal ayarları.",
            badge: "Setup ›",
            isMenu: true
        },
        {
            id: "power",
            label: "Güç & Oturum",
            icon: "",
            category: "Oturum Yönetimi",
            subtext: "Kilit, uyku, yeniden başlatma, kapat",
            description: "Ekran kilitleme, askıya alma, yeniden başlatma ve güvenli kapatma seçenekleri.",
            badge: "Power ›",
            isMenu: true
        }
    ]

    readonly property var toolItems: [
        {
            id: "tools.screenshot_area",
            label: "Ekran Görüntüsü (Seçili Alan)",
            icon: "󰄀",
            category: "Araçlar",
            subtext: "Bölgesel ekran görüntüsü al",
            description: "Seçilen ekran bölgesini slurp ile yakalar ve panoya kopyalar.",
            action: "grim -g \"$(slurp)\" - | wl-copy && notify-send 'Ekran Görüntüsü' 'Seçili alan panoya kopyalandı'",
            badge: "grim+slurp",
            isTool: true
        },
        {
            id: "tools.screenshot_full",
            label: "Tam Ekran Görüntüsü",
            icon: "󰹑",
            category: "Araçlar",
            subtext: "Tüm ekranı panoya çek",
            description: "Tüm monitörün ekran görüntüsünü alır ve panoya kopyalar.",
            action: "grim - | wl-copy && notify-send 'Ekran Görüntüsü' 'Tüm ekran panoya kopyalandı'",
            badge: "grim",
            isTool: true
        },
        {
            id: "tools.color_picker",
            label: "Canlı Renk Seçici",
            icon: "󰃉",
            category: "Araçlar",
            subtext: "Piksel büyüteciyle HEX kodu al",
            description: "Piksel büyüteci ile ekrandan renk seçer (HEX) ve panoya kopyalar.",
            action: "hyprpicker -a",
            badge: "hyprpicker",
            isTool: true
        },
        {
            id: "tools.stay_awake",
            label: "Uyanık Kal (Idle Inhibit)",
            icon: "󰅶",
            category: "Araçlar",
            subtext: "Ekran koruyucuyu geçici durdur",
            description: "Ekran koruyucu ve otomatik askıya alma zamanlayıcısını açar veya kapatır.",
            action: "pkill hypridle || hypridle",
            badge: "hypridle",
            isTool: true
        },
        {
            id: "tools.speedtest",
            label: "Ağ Hız & Ping Testi",
            icon: "󰓅",
            category: "Araçlar",
            subtext: "Cloudflare DNS gecikmesini ölç",
            description: "Ağ geçidine ve Cloudflare DNS sunucusuna canlı paket gecikmesini ölçer.",
            action: "kitty -e ping 1.1.1.1",
            badge: "ping",
            isTool: true
        },
        {
            id: "tools.webapp",
            label: "Web Uygulaması Aç (PWA)",
            icon: "󰏖",
            category: "Araçlar",
            subtext: "Bağımsız web penceresi başlat",
            description: "Belirtilen bir URL'yi bağımsız Chromium PWA penceresi olarak başlatır.",
            action: "xmarchy webapp https://google.com",
            badge: "PWA",
            isTool: true
        }
    ]

    readonly property var styleItems: [
        {
            id: "style.xmarchy_dark",
            label: "Tema: Xmarchy Dark",
            icon: "󰸌",
            category: "Görünüm",
            subtext: "Derin lacivert-mor orijinal tema",
            description: "Modern, derin lacivert ve mor tonlarına sahip orijinal Xmarchy karanlık teması.",
            action: "xmarchy theme xmarchy-dark",
            badge: "Dark",
            isTheme: true,
            themeKey: "xmarchy-dark"
        },
        {
            id: "style.catppuccin",
            label: "Tema: Catppuccin Mocha",
            icon: "󰸌",
            category: "Görünüm",
            subtext: "Yumuşak pastel leylak estetiği",
            description: "Dinlendirici pastel leylak, lavanta ve mavi tonlarıyla Catppuccin estetiği.",
            action: "xmarchy theme catppuccin",
            badge: "Catppuccin",
            isTheme: true,
            themeKey: "catppuccin"
        },
        {
            id: "style.rose_pine",
            label: "Tema: Rosé Pine",
            icon: "󰸌",
            category: "Görünüm",
            subtext: "Gül kurusu ve çam minimalist tasarım",
            description: "Sıcak gül kurusu, altın sarısı ve çam tonlarıyla minimalist tasarım.",
            action: "xmarchy theme rose-pine",
            badge: "Rose Pine",
            isTheme: true,
            themeKey: "rose-pine"
        },
        {
            id: "style.nord",
            label: "Tema: Nord",
            icon: "󰸌",
            category: "Görünüm",
            subtext: "Arktik kutup mavisi ve arduvaz",
            description: "Arktik kutup mavisi ve arduvaz grisi tonlarıyla soğuk berrak tema.",
            action: "xmarchy theme nord",
            badge: "Nord",
            isTheme: true,
            themeKey: "nord"
        },
        {
            id: "style.cyberpunk",
            label: "Tema: Cyberpunk",
            icon: "󰸌",
            category: "Görünüm",
            subtext: "Neon camgöbeği ve parlak pembe",
            description: "Neon camgöbeği ve parlak pembe neon kontrastına sahip fütüristik tema.",
            action: "xmarchy theme cyberpunk",
            badge: "Cyberpunk",
            isTheme: true,
            themeKey: "cyberpunk"
        },
        {
            id: "style.xmarchy_light",
            label: "Tema: Xmarchy Light",
            icon: "󰸌",
            category: "Görünüm",
            subtext: "Göz yormayan aydınlık beyaz tema",
            description: "Yüksek kontrastlı, göz yormayan aydınlık beyaz masaüstü teması.",
            action: "xmarchy theme xmarchy-light",
            badge: "Light",
            isTheme: true,
            themeKey: "xmarchy-light"
        },
        {
            id: "style.scale_1",
            label: "Monitör Ölçeği: 1x (Standart)",
            icon: "󰍹",
            category: "Ekran",
            subtext: "100% piksel oranı",
            description: "Varsayılan 100% Wayland ölçeklendirme uygular.",
            action: "hyprctl keyword monitor ,preferred,auto,1",
            badge: "1x"
        },
        {
            id: "style.scale_125",
            label: "Monitör Ölçeği: 1.25x (Orta Büyütme)",
            icon: "󰍹",
            category: "Ekran",
            subtext: "125% rahat okuma",
            description: "125% ölçek ile UI elemanlarını daha rahat okunur hale getirir.",
            action: "hyprctl keyword monitor ,preferred,auto,1.25",
            badge: "1.25x"
        },
        {
            id: "style.scale_16",
            label: "Monitör Ölçeği: 1.6x (HiDPI)",
            icon: "󰍹",
            category: "Ekran",
            subtext: "160% 2K ekran ölçeği",
            description: "2K ve yüksek çözünürlüklü paneller için ideal 160% ölçekleme.",
            action: "hyprctl keyword monitor ,preferred,auto,1.6",
            badge: "1.6x"
        },
        {
            id: "style.scale_2",
            label: "Monitör Ölçeği: 2x (Retina)",
            icon: "󰍹",
            category: "Ekran",
            subtext: "200% 4K Retina ölçeği",
            description: "4K ekranlar için tam iki katı Retina ölçekleme.",
            action: "hyprctl keyword monitor ,preferred,auto,2",
            badge: "2x"
        }
    ]

    readonly property var nixosItems: [
        {
            id: "nixos.rebuild",
            label: "NixOS Rebuild Switch",
            icon: "󰑐",
            category: "NixOS",
            subtext: "Yapılandırmayı derle ve etkinleştir",
            description: "Sistem yapılandırmasını derler ve oturumu kapatmadan anında etkinleştirir.",
            action: "kitty -e sudo nixos-rebuild switch --flake /persist/nixos-config",
            badge: "switch",
            isNixos: true
        },
        {
            id: "nixos.update",
            label: "Nix Flake Paket Güncellemesi",
            icon: "󰑓",
            category: "NixOS",
            subtext: "flake.lock girdilerini güncelle",
            description: "flake.lock dosyasındaki girdi depolarını ve paket sürümlerini günceller.",
            action: "kitty -e nix flake update /persist/nixos-config",
            badge: "update",
            isNixos: true
        },
        {
            id: "nixos.gc",
            label: "Çöp Temizliği (Garbage Collect)",
            icon: "󰭌",
            category: "NixOS",
            subtext: "Eski nesilleri ve artıkları sil",
            description: "Eski nesillerdeki artık paketleri temizler ve disk alanını boşaltır.",
            action: "kitty -e nix-collect-garbage -d",
            badge: "clean",
            isNixos: true
        },
        {
            id: "nixos.fetch",
            label: "Fastfetch Sistem Künyesi",
            icon: "󰣆",
            category: "NixOS",
            subtext: "Donanım ve OS özetini görüntüle",
            description: "Donanım, işletim sistemi, çekirdek ve masaüstü özetini terminalde gösterir.",
            action: "kitty -e xmarchy fetch",
            badge: "fetch",
            isNixos: true
        },
        {
            id: "nixos.btop",
            label: "Btop Donanım & Süreç Monitörü",
            icon: "󰍹",
            category: "NixOS",
            subtext: "Grafik CPU/RAM/Disk/Ağ monitörü",
            description: "CPU, GPU, RAM, Disk ve Ağ süreçlerini grafik arayüzle canlı izleyin.",
            action: "kitty -e btop",
            badge: "btop",
            isNixos: true
        },
        {
            id: "nixos.restart_shell",
            label: "Quickshell Kabuğunu Yeniden Başlat",
            icon: "󰜉",
            category: "NixOS",
            subtext: "Barı ve panelleri sıfırla",
            description: "Masaüstü panellerini, barı ve bildirim motorunu yeniden yükler.",
            action: "systemctl --user restart quickshell",
            badge: "quickshell",
            isNixos: true
        },
        {
            id: "nixos.restart_audio",
            label: "Pipewire Ses Servisini Yeniden Başlat",
            icon: "",
            category: "NixOS",
            subtext: "Pipewire ve Wireplumber sıfırla",
            description: "Pipewire ses sunucusunu sıfırlayarak donanım bağlantılarını tazeler.",
            action: "systemctl --user restart pipewire wireplumber",
            badge: "pipewire",
            isNixos: true
        }
    ]

    readonly property var setupItems: [
        {
            id: "setup.dns_cloudflare",
            label: "DNS: Cloudflare (1.1.1.1)",
            icon: "󰅟",
            category: "Ağ & DNS",
            subtext: "1.1.1.1, 1.0.0.1 gizlilik odaklı",
            description: "Hızlı ve gizlilik odaklı Cloudflare DNS (1.1.1.1, 1.0.0.1) uygular.",
            action: "xmarchy dns Cloudflare",
            badge: "Cloudflare",
            isDns: true
        },
        {
            id: "setup.dns_google",
            label: "DNS: Google (8.8.8.8)",
            icon: "󰊭",
            category: "Ağ & DNS",
            subtext: "8.8.8.8, 8.8.4.4 genel DNS",
            description: "Google Public DNS (8.8.8.8, 8.8.4.4) sunucularını aktif eder.",
            action: "xmarchy dns Google",
            badge: "Google",
            isDns: true
        },
        {
            id: "setup.dns_dhcp",
            label: "DNS: DHCP (Otomatik / Router)",
            icon: "󰩟",
            category: "Ağ & DNS",
            subtext: "Modemin yerel ayarlarına dön",
            description: "Yerel modem ve yönlendiricinizin otomatik DNS ayarlarına döner.",
            action: "xmarchy dns DHCP",
            badge: "DHCP",
            isDns: true
        },
        {
            id: "setup.term_kitty",
            label: "Varsayılan Terminal: Kitty",
            icon: "",
            category: "Uygulama",
            subtext: "GPU hızlandırmalı modern terminal",
            description: "Donanım hızlandırmalı GPU destekli Kitty terminal emülatörü.",
            action: "kitty",
            badge: "Terminal"
        },
        {
            id: "setup.browser_chromium",
            label: "Varsayılan Tarayıcı: Chromium",
            icon: "",
            category: "Uygulama",
            subtext: "Açık kaynak hızlı web tarayıcısı",
            description: "Hızlı ve güvenli açık kaynak Chromium web tarayıcısı.",
            action: "chromium",
            badge: "Web"
        }
    ]

    readonly property var powerItems: [
        {
            id: "power.lock",
            label: "Ekranı Kilitle",
            icon: "",
            category: "Güç",
            subtext: "Oturumu hemen kilitle",
            description: "Oturumu güvenli şekilde kilitler ve kimlik doğrulama ekranına geçer.",
            action: "loginctl lock-session",
            badge: "Lock"
        },
        {
            id: "power.suspend",
            label: "Askıya Al (Suspend)",
            icon: "󰒲",
            category: "Güç",
            subtext: "Düşük güç tüketimli uyku kipine geç",
            description: "Bilgisayarı düşük güç tüketimli uyku durumuna geçirir.",
            action: "systemctl suspend",
            badge: "Sleep"
        },
        {
            id: "power.logout",
            label: "Oturumu Kapat (Logout)",
            icon: "󰍃",
            category: "Güç",
            subtext: "Hyprland oturumunu sonlandır",
            description: "Hyprland Wayland oturumunu kapatıp giriş yöneticisine döner.",
            action: "hyprctl dispatch exit",
            badge: "Exit"
        },
        {
            id: "power.reboot",
            label: "Bilgisayarı Yeniden Başlat",
            icon: "󰜉",
            category: "Güç",
            subtext: "Sistemi güvenle yeniden başlat",
            description: "Tüm sistem servislerini güvenle sonlandırıp bilgisayarı yeniden başlatır.",
            action: "systemctl reboot",
            badge: "Reboot"
        },
        {
            id: "power.shutdown",
            label: "Bilgisayarı Kapat (Shutdown)",
            icon: "󰐥",
            category: "Güç",
            subtext: "Donanım gücünü tamamen kes",
            description: "İşletim sistemini kapatır ve donanım gücünü tamamen keser.",
            action: "systemctl poweroff",
            badge: "Poweroff"
        }
    ]

    // ═══════════════ Yardımcı Metotlar (Logic) ═══════════════

    function toggle() {
        if (root.opened) {
            root.close()
        } else {
            root.open()
        }
    }

    function open() {
        root.opened = true
        root.query = ""
        root.navStack = []
        root.currentMenuId = "root"
        root.selectedIndex = 0
        searchInput.text = ""
        rebuildDisplay()
        searchInput.forceActiveFocus()
    }

    function close() {
        root.opened = false
        root.query = ""
        root.navStack = []
        root.currentMenuId = "root"
        root.selectedIndex = 0
    }

    function goBack() {
        if (root.navStack.length > 0) {
            var prev = root.navStack[root.navStack.length - 1]
            root.navStack = root.navStack.slice(0, root.navStack.length - 1)
            root.currentMenuId = prev
            root.selectedIndex = 0
            rebuildDisplay()
            return true
        }
        return false
    }

    function getBreadcrumbText() {
        if (root.query.length > 0) {
            return "Arama"
        }
        if (root.currentMenuId === "root") {
            return "Kök"
        }
        var shortNames = {
            "apps": "Uygulamalar",
            "tools": "Araçlar",
            "style": "Görünüm",
            "nixos": "NixOS",
            "setup": "Ayarlar",
            "power": "Güç"
        }
        return "Kök › " + (shortNames[root.currentMenuId] || root.currentMenuId)
    }

    function getAllStaticItems() {
        var all = []
        all = all.concat(root.toolItems)
        all = all.concat(root.styleItems)
        all = all.concat(root.nixosItems)
        all = all.concat(root.setupItems)
        all = all.concat(root.powerItems)
        return all
    }

    function rebuildDisplay() {
        var q = root.query.toLowerCase().trim()
        root.selectedIndex = 0

        if (q.length > 0) {
            // ─── Global Spotlight Arama Modu ───
            var matches = []

            // 1. Sistem Eylemleri Araması
            var statics = getAllStaticItems()
            for (var i = 0; i < statics.length; i++) {
                var item = statics[i]
                if (item.label.toLowerCase().indexOf(q) >= 0 ||
                    item.category.toLowerCase().indexOf(q) >= 0 ||
                    (item.subtext && item.subtext.toLowerCase().indexOf(q) >= 0) ||
                    item.description.toLowerCase().indexOf(q) >= 0 ||
                    (item.badge && item.badge.toLowerCase().indexOf(q) >= 0)) {
                    matches.push(item)
                }
            }

            // 2. Kurulu Uygulamalar Araması
            var apps = DesktopEntries.applications.values
            for (var j = 0; j < apps.length; j++) {
                var app = apps[j]
                var name = app.name ? app.name.toLowerCase() : ""
                var genName = app.genericName ? app.genericName.toLowerCase() : ""
                var comm = app.comment ? app.comment.toLowerCase() : ""
                if (name.indexOf(q) >= 0 || genName.indexOf(q) >= 0 || comm.indexOf(q) >= 0) {
                    var cleanSub = app.genericName || app.comment || "Masaüstü Uygulaması"
                    matches.push({
                        id: "app." + (app.id || name),
                        label: app.name || "Uygulama",
                        icon: "󰣆",
                        appIcon: app.icon || "",
                        category: "Uygulama",
                        subtext: cleanSub,
                        description: app.comment || app.genericName || "Sistemde kurulu uygulama.",
                        badge: "",
                        isApp: true,
                        appEntry: app
                    })
                }
            }

            root.displayItems = matches
            return
        }

        // ─── Hiyerarşik Ağaç Modu ───
        if (root.currentMenuId === "root") {
            root.displayItems = root.rootCategories
        } else if (root.currentMenuId === "apps") {
            var appList = []
            var allApps = DesktopEntries.applications.values
            for (var a = 0; a < allApps.length; a++) {
                var currentApp = allApps[a]
                if (!currentApp || !currentApp.name) continue
                var cleanAppSub = currentApp.genericName || currentApp.comment || ""
                if (!cleanAppSub && currentApp.categories && currentApp.categories.length > 0) {
                    cleanAppSub = currentApp.categories[0]
                }
                if (!cleanAppSub) cleanAppSub = "Masaüstü Uygulaması"

                appList.push({
                    id: "app." + (currentApp.id || currentApp.name),
                    label: currentApp.name,
                    icon: "󰣆",
                    appIcon: currentApp.icon || "",
                    category: "Uygulama",
                    subtext: cleanAppSub,
                    description: currentApp.comment || currentApp.genericName || "Sistemde kurulu grafiksel masaüstü uygulaması.",
                    badge: "",
                    isApp: true,
                    appEntry: currentApp
                })
            }
            appList.sort(function(x, y) { return x.label.localeCompare(y.label) })
            root.displayItems = appList
        } else if (root.currentMenuId === "tools") {
            root.displayItems = root.toolItems
        } else if (root.currentMenuId === "style") {
            root.displayItems = root.styleItems
        } else if (root.currentMenuId === "nixos") {
            root.displayItems = root.nixosItems
        } else if (root.currentMenuId === "setup") {
            root.displayItems = root.setupItems
        } else if (root.currentMenuId === "power") {
            root.displayItems = root.powerItems
        } else {
            root.displayItems = root.rootCategories
        }
    }

    function activateItem(item) {
        if (!item) return

        if (item.isMenu) {
            // Alt Menüye Gir
            root.navStack.push(root.currentMenuId)
            root.currentMenuId = item.id
            root.query = ""
            searchInput.text = ""
            rebuildDisplay()
            return
        }

        if (item.isApp && item.appEntry) {
            // Masaüstü Uygulamasını Başlat
            item.appEntry.execute()
            root.close()
            return
        }

        if (item.action) {
            // Komut / Eylemi Çalıştır
            Hyprland.dispatch("exec " + item.action)
            root.close()
            return
        }
    }

    function getActionButtonText(item) {
        if (!item) return ""
        if (item.isMenu) return "Alt Menüye Gir [↵]"
        if (item.isApp) return "Uygulamayı Başlat [↵]"
        return "Eylemi Çalıştır [↵]"
    }

    // ═══════════════ Görsel Pencere (PanelWindow) ═══════════════

    PanelWindow {
        id: panelWindow
        visible: root.opened
        anchors { top: true; left: true; right: true; bottom: true }
        exclusiveZone: -1
        color: Qt.rgba(0, 0, 0, 0.65)

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        Item {
            anchors.fill: parent

            // Dış alana tıklayınca kapat
            MouseArea {
                anchors.fill: parent
                onClicked: root.close()
            }

            // Ana Kart (Command Palette - 740 x 480)
            Rectangle {
                id: mainCard
                anchors.centerIn: parent
                width: 740
                height: 480
                radius: 12
                color: shell.theme.bg
                border.color: shell.theme.accent
                border.width: 1
                clip: true

                // Tıklamanın dışarı sızmasını engelle
                MouseArea {
                    anchors.fill: parent
                    onClicked: {}
                }

                // ═══════════ ÜST: Arama ve Breadcrumb Çubuğu ═══════════
                Rectangle {
                    id: headerBar
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 52
                    color: shell.theme.surface

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        spacing: 12

                        Text {
                            text: "󰍉"
                            color: shell.theme.accent
                            font.pixelSize: 18
                            font.family: shell.fontFamily
                            Layout.alignment: Qt.AlignVCenter
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true

                            TextInput {
                                id: searchInput
                                anchors.fill: parent
                                verticalAlignment: TextInput.AlignVCenter
                                color: shell.theme.fg
                                font.family: shell.fontFamily
                                font.pixelSize: 14
                                clip: true
                                onTextChanged: {
                                    root.query = text
                                    root.rebuildDisplay()
                                }

                                Keys.onEscapePressed: {
                                    if (root.query.length > 0) {
                                        searchInput.text = ""
                                    } else {
                                        root.close()
                                    }
                                }

                                Keys.onDownPressed: {
                                    if (root.displayItems.length > 0) {
                                        root.selectedIndex = (root.selectedIndex + 1) % root.displayItems.length
                                        resultList.positionViewAtIndex(root.selectedIndex, ListView.Contain)
                                    }
                                }

                                Keys.onUpPressed: {
                                    if (root.displayItems.length > 0) {
                                        root.selectedIndex = (root.selectedIndex - 1 + root.displayItems.length) % root.displayItems.length
                                        resultList.positionViewAtIndex(root.selectedIndex, ListView.Contain)
                                    }
                                }

                                Keys.onReturnPressed: {
                                    if (root.displayItems.length > 0 && root.selectedIndex >= 0 && root.selectedIndex < root.displayItems.length) {
                                        root.activateItem(root.displayItems[root.selectedIndex])
                                    }
                                }

                                Keys.onRightPressed: {
                                    if (root.displayItems.length > 0 && root.selectedIndex >= 0 && root.selectedIndex < root.displayItems.length) {
                                        var itm = root.displayItems[root.selectedIndex]
                                        if (itm.isMenu) {
                                            root.activateItem(itm)
                                        }
                                    }
                                }

                                Keys.onLeftPressed: {
                                    if (root.query.length === 0) {
                                        root.goBack()
                                    }
                                }

                                Keys.onPressed: function(event) {
                                    if (event.key === Qt.Key_Backspace && root.query.length === 0) {
                                        if (root.goBack()) {
                                            event.accepted = true
                                        }
                                    }
                                }
                            }

                            Text {
                                visible: searchInput.text.length === 0
                                anchors.fill: parent
                                verticalAlignment: Text.AlignVCenter
                                text: "Bir eylem veya uygulama arayın..."
                                color: shell.theme.dim
                                font.family: shell.fontFamily
                                font.pixelSize: 14
                            }
                        }

                        // Dinamik Breadcrumb / Yol Rozeti (Taşma korumalı)
                        Rectangle {
                            id: breadcrumbBadge
                            Layout.alignment: Qt.AlignVCenter
                            Layout.preferredHeight: 22
                            Layout.preferredWidth: Math.min(130, breadcrumbText.implicitWidth + 16)
                            radius: 11
                            color: shell.theme.bg
                            border.color: shell.theme.dim
                            border.width: 1
                            clip: true

                            Text {
                                id: breadcrumbText
                                anchors.centerIn: parent
                                width: parent.width - 12
                                text: root.getBreadcrumbText()
                                color: shell.theme.accent
                                font.family: shell.fontFamily
                                font.pixelSize: 10
                                font.bold: true
                                elide: Text.ElideRight
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }

                        // ESC Kapatma Butonu
                        Rectangle {
                            Layout.alignment: Qt.AlignVCenter
                            Layout.preferredHeight: 22
                            Layout.preferredWidth: 36
                            radius: 4
                            color: shell.theme.bg
                            border.color: shell.theme.dim
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: "ESC"
                                color: shell.theme.dim
                                font.family: shell.fontFamily
                                font.pixelSize: 9
                                font.bold: true
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.close()
                            }
                        }
                    }
                }

                // Yatay Ayırıcı Çizgi
                Rectangle {
                    id: headerDivider
                    anchors.top: headerBar.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 1
                    color: shell.theme.dim
                    opacity: 0.2
                }

                // ═══════════ ORTA: Çift Panel (Liste + Canlı Önizleme) ═══════════
                Item {
                    anchors.top: headerDivider.bottom
                    anchors.bottom: footerBar.top
                    anchors.left: parent.left
                    anchors.right: parent.right

                    // ─── Sol Panel (%58 Genişlik - Sonuçlar Listesi) ───
                    Item {
                        id: leftPane
                        width: parent.width * 0.58
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left

                        ListView {
                            id: resultList
                            anchors.fill: parent
                            anchors.margins: 8
                            model: root.displayItems
                            clip: true
                            spacing: 4
                            boundsBehavior: Flickable.StopAtBounds

                            delegate: Rectangle {
                                required property var modelData
                                required property int index
                                width: ListView.view.width
                                height: 46
                                radius: 8
                                color: index === root.selectedIndex ? shell.theme.accent : (rowMouse.containsMouse ? shell.theme.surface : "transparent")

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 12
                                    spacing: 12

                                    // İkon
                                    Item {
                                        width: 24
                                        height: 24
                                        Layout.alignment: Qt.AlignVCenter

                                        IconImage {
                                            anchors.fill: parent
                                            source: modelData.appIcon ? Quickshell.iconPath(modelData.appIcon) : ""
                                            visible: status === Image.Ready
                                        }

                                        Text {
                                            anchors.centerIn: parent
                                            visible: !modelData.appIcon
                                            text: modelData.icon ?? "󰣆"
                                            color: index === root.selectedIndex ? shell.theme.bg : shell.theme.accent
                                            font.family: shell.fontFamily
                                            font.pixelSize: 16
                                        }
                                    }

                                    // Başlık & Alt Açıklama
                                    Column {
                                        Layout.fillWidth: true
                                        Layout.alignment: Qt.AlignVCenter
                                        spacing: 2

                                        Text {
                                            text: modelData.label ?? ""
                                            color: index === root.selectedIndex ? shell.theme.bg : shell.theme.fg
                                            font.family: shell.fontFamily
                                            font.pixelSize: 13
                                            font.bold: true
                                            elide: Text.ElideRight
                                            width: parent.width
                                        }

                                        Text {
                                            visible: text.length > 0
                                            text: modelData.subtext ? modelData.subtext : (root.query.length > 0 ? (modelData.category ?? "") : "")
                                            color: index === root.selectedIndex ? Qt.rgba(shell.theme.bg.r, shell.theme.bg.g, shell.theme.bg.b, 0.75) : shell.theme.dim
                                            font.family: shell.fontFamily
                                            font.pixelSize: 10
                                            elide: Text.ElideRight
                                            width: parent.width
                                        }
                                    }

                                    // Sağ Rozet / Ok / Başlat Butonu
                                    Text {
                                        text: modelData.isMenu ? "›" : (modelData.isApp ? (index === root.selectedIndex ? "↵ Başlat" : "") : (modelData.badge ?? "↵"))
                                        color: index === root.selectedIndex ? shell.theme.bg : shell.theme.dim
                                        font.family: shell.fontFamily
                                        font.pixelSize: modelData.isMenu ? 16 : 10
                                        font.bold: true
                                        Layout.alignment: Qt.AlignVCenter
                                    }
                                }

                                MouseArea {
                                    id: rowMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onEntered: root.selectedIndex = index
                                    onClicked: root.activateItem(modelData)
                                }
                            }
                        }

                        // Sonuç Bulunamadı Görünümü
                        Column {
                            anchors.centerIn: parent
                            spacing: 8
                            visible: root.displayItems.length === 0

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "󰍉"
                                color: shell.theme.dim
                                font.family: shell.fontFamily
                                font.pixelSize: 32
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "Eşleşen eylem veya uygulama bulunamadı"
                                color: shell.theme.dim
                                font.family: shell.fontFamily
                                font.pixelSize: 12
                            }
                        }
                    }

                    // ─── Dikey Ayırıcı Çizgi ───
                    Rectangle {
                        id: verticalDivider
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.left: leftPane.right
                        width: 1
                        color: shell.theme.dim
                        opacity: 0.2
                    }

                    // ─── Sağ Panel (%42 Genişlik - Akıllı Canlı Önizleme Kartı) ───
                    Item {
                        id: rightPane
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.left: verticalDivider.right
                        anchors.right: parent.right

                        readonly property var selItem: (root.displayItems.length > 0 && root.selectedIndex >= 0 && root.selectedIndex < root.displayItems.length) ? root.displayItems[root.selectedIndex] : null

                        Column {
                            anchors.fill: parent
                            anchors.margins: 18
                            spacing: 12
                            visible: rightPane.selItem !== null

                            // Büyük İkon + Başlık
                            RowLayout {
                                width: parent.width
                                spacing: 14

                                Rectangle {
                                    width: 44
                                    height: 44
                                    radius: 10
                                    color: shell.theme.surface
                                    border.color: shell.theme.accent
                                    border.width: 1
                                    Layout.alignment: Qt.AlignVCenter

                                    IconImage {
                                        anchors.fill: parent
                                        anchors.margins: 6
                                        source: rightPane.selItem?.appIcon ? Quickshell.iconPath(rightPane.selItem.appIcon) : ""
                                        visible: status === Image.Ready
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        visible: !rightPane.selItem?.appIcon
                                        text: rightPane.selItem?.icon ?? "󰣆"
                                        color: shell.theme.accent
                                        font.family: shell.fontFamily
                                        font.pixelSize: 22
                                    }
                                }

                                Column {
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignVCenter
                                    spacing: 3

                                    Text {
                                        text: rightPane.selItem?.label ?? ""
                                        color: shell.theme.fg
                                        font.family: shell.fontFamily
                                        font.pixelSize: 14
                                        font.bold: true
                                        wrapMode: Text.Wrap
                                        width: parent.width
                                    }

                                    Rectangle {
                                        height: 18
                                        radius: 9
                                        color: shell.theme.accent
                                        width: catBadgeText.implicitWidth + 12

                                        Text {
                                            id: catBadgeText
                                            anchors.centerIn: parent
                                            text: rightPane.selItem?.category ?? "Eylem"
                                            color: shell.theme.bg
                                            font.family: shell.fontFamily
                                            font.pixelSize: 9
                                            font.bold: true
                                        }
                                    }
                                }
                            }

                            // Açıklama Metni
                            Text {
                                width: parent.width
                                text: rightPane.selItem?.description ?? ""
                                color: shell.theme.fg
                                font.family: shell.fontFamily
                                font.pixelSize: 12
                                wrapMode: Text.Wrap
                                lineHeight: 1.3
                                opacity: 0.85
                            }

                            // Ayırıcı Çizgi
                            Rectangle {
                                width: parent.width
                                height: 1
                                color: shell.theme.dim
                                opacity: 0.2
                            }

                            // ─── ÖZEL CONTEXT 1: Tema Önizlemesi ───
                            Column {
                                width: parent.width
                                spacing: 8
                                visible: rightPane.selItem?.isTheme ?? false

                                Text {
                                    text: "TEMA RENK PALETİ"
                                    color: shell.theme.dim
                                    font.family: shell.fontFamily
                                    font.pixelSize: 10
                                    font.bold: true
                                }

                                RowLayout {
                                    spacing: 8
                                    property var thm: rightPane.selItem?.themeKey ? shell.themes[rightPane.selItem.themeKey] : null

                                    Repeater {
                                        model: parent.thm ? [parent.thm.bg, parent.thm.surface, parent.thm.accent, parent.thm.accent2, parent.thm.fg] : []
                                        delegate: Rectangle {
                                            required property string modelData
                                            width: 22
                                            height: 22
                                            radius: 11
                                            color: modelData
                                            border.color: shell.theme.dim
                                            border.width: 1
                                        }
                                    }
                                }

                                Text {
                                    text: "Duvar Kağıdı: " + (rightPane.selItem?.themeKey ? (shell.themes[rightPane.selItem.themeKey]?.wallpaper ?? "") : "")
                                    color: shell.theme.dim
                                    font.family: shell.fontFamily
                                    font.pixelSize: 11
                                }
                            }

                            // ─── ÖZEL CONTEXT 2: NixOS Eylemi Önizlemesi ───
                            Column {
                                width: parent.width
                                spacing: 6
                                visible: rightPane.selItem?.isNixos ?? false

                                Text {
                                    text: "ÇALIŞTIRILACAK SİSTEM KOMUTU"
                                    color: shell.theme.dim
                                    font.family: shell.fontFamily
                                    font.pixelSize: 10
                                    font.bold: true
                                }

                                Rectangle {
                                    width: parent.width
                                    height: cmdPreviewText.implicitHeight + 12
                                    radius: 6
                                    color: shell.theme.surface
                                    border.color: shell.theme.accent
                                    border.width: 1

                                    Text {
                                        id: cmdPreviewText
                                        anchors.fill: parent
                                        anchors.margins: 6
                                        text: rightPane.selItem?.action ?? ""
                                        color: shell.theme.accent
                                        font.family: shell.fontFamily
                                        font.pixelSize: 10
                                        wrapMode: Text.WrapAnywhere
                                    }
                                }
                            }

                            // ─── ÖZEL CONTEXT 3: Araç / DNS Önizlemesi ───
                            Column {
                                width: parent.width
                                spacing: 6
                                visible: (rightPane.selItem?.isTool ?? false) || (rightPane.selItem?.isDns ?? false)

                                Text {
                                    text: rightPane.selItem?.isDns ? "DNS YAPILANDIRMASI" : "HEDEF ÇIKTI & BİLGİ"
                                    color: shell.theme.dim
                                    font.family: shell.fontFamily
                                    font.pixelSize: 10
                                    font.bold: true
                                }

                                Rectangle {
                                    width: parent.width
                                    height: 46
                                    radius: 6
                                    color: shell.theme.surface
                                    border.color: shell.theme.dim
                                    border.width: 1

                                    Column {
                                        anchors.fill: parent
                                        anchors.margins: 6
                                        spacing: 2

                                        Text {
                                            text: "Hedef: " + (rightPane.selItem?.badge ?? "Hazır")
                                            color: shell.theme.accent
                                            font.family: shell.fontFamily
                                            font.pixelSize: 11
                                            font.bold: true
                                        }

                                        Text {
                                            text: rightPane.selItem?.isDns ? "Sistem ağ geçidine anında uygulanır" : "Panoya kopyalanır ve sistem bildirimi verilir"
                                            color: shell.theme.dim
                                            font.family: shell.fontFamily
                                            font.pixelSize: 10
                                        }
                                    }
                                }
                            }

                            // ─── ÖZEL CONTEXT 4: Uygulama Teknik Detayları ───
                            Column {
                                width: parent.width
                                spacing: 6
                                visible: rightPane.selItem?.isApp ?? false

                                Text {
                                    text: "UYGULAMA KÜNYESİ"
                                    color: shell.theme.dim
                                    font.family: shell.fontFamily
                                    font.pixelSize: 10
                                    font.bold: true
                                }

                                Rectangle {
                                    width: parent.width
                                    height: 46
                                    radius: 6
                                    color: shell.theme.surface
                                    border.color: shell.theme.dim
                                    border.width: 1

                                    Column {
                                        anchors.fill: parent
                                        anchors.margins: 6
                                        spacing: 2

                                        Text {
                                            text: "Masaüstü ID: " + (rightPane.selItem?.appEntry?.id ?? rightPane.selItem?.label ?? "")
                                            color: shell.theme.fg
                                            font.family: shell.fontFamily
                                            font.pixelSize: 10
                                            elide: Text.ElideRight
                                            width: parent.width
                                        }

                                        Text {
                                            text: "Durum: Sistemde kurulu & başlatmaya hazır"
                                            color: shell.theme.accent
                                            font.family: shell.fontFamily
                                            font.pixelSize: 10
                                        }
                                    }
                                }
                            }

                            // ─── ÖZEL CONTEXT 5: Kategori Rehberi ───
                            Column {
                                width: parent.width
                                spacing: 6
                                visible: rightPane.selItem?.isMenu ?? false

                                Text {
                                    text: "MENÜ GEZİNİM İPUCU"
                                    color: shell.theme.dim
                                    font.family: shell.fontFamily
                                    font.pixelSize: 10
                                    font.bold: true
                                }

                                Rectangle {
                                    width: parent.width
                                    height: 46
                                    radius: 6
                                    color: shell.theme.surface
                                    border.color: shell.theme.dim
                                    border.width: 1

                                    Column {
                                        anchors.fill: parent
                                        anchors.margins: 6
                                        spacing: 2

                                        Text {
                                            text: "Alt menüye girmek için [↵] veya [→] tuşuna basın"
                                            color: shell.theme.accent
                                            font.family: shell.fontFamily
                                            font.pixelSize: 10
                                            font.bold: true
                                        }

                                        Text {
                                            text: "Geri dönmek için [←] veya [Backspace] kullanın"
                                            color: shell.theme.dim
                                            font.family: shell.fontFamily
                                            font.pixelSize: 10
                                        }
                                    }
                                }
                            }

                            // Boşluk Doldurucu
                            Item { Layout.fillHeight: true }

                            // Çalıştır / Başlat / Gir Butonu
                            Rectangle {
                                width: parent.width
                                height: 34
                                radius: 8
                                color: shell.theme.accent

                                Text {
                                    anchors.centerIn: parent
                                    text: root.getActionButtonText(rightPane.selItem)
                                    color: shell.theme.bg
                                    font.family: shell.fontFamily
                                    font.pixelSize: 12
                                    font.bold: true
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.activateItem(rightPane.selItem)
                                }
                            }
                        }
                    }
                }

                // ═══════════ ALT: Footer / İpuçları Çubuğu ═══════════
                Rectangle {
                    id: footerBar
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 32
                    color: shell.theme.surface

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16

                        RowLayout {
                            spacing: 16
                            Layout.alignment: Qt.AlignVCenter

                            Text {
                                text: "󰁝󰁅 Gezin"
                                color: shell.theme.dim
                                font.family: shell.fontFamily
                                font.pixelSize: 11
                            }

                            Text {
                                text: "↵ Seç / Çalıştır"
                                color: shell.theme.dim
                                font.family: shell.fontFamily
                                font.pixelSize: 11
                            }

                            Text {
                                text: "← Geri"
                                color: shell.theme.dim
                                font.family: shell.fontFamily
                                font.pixelSize: 11
                            }
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: "Xmarchy Command Center"
                            color: shell.theme.dim
                            font.family: shell.fontFamily
                            font.pixelSize: 10
                            Layout.alignment: Qt.AlignVCenter
                        }
                    }
                }
            }
        }
    }
}
