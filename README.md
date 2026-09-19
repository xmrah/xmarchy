# 🚀 Xmarchy

**Opinionated, Declarative, High-Performance Desktop OS**  
NixOS Flakes, Linux Zen Kernel, Hyprland ve Quickshell mimarisi üzerine kurulu; modern, akıcı ve kullanıma hazır bağımsız masaüstü işletim sistemi.

---

## ✨ Öne Çıkan Özellikler

### ⚡ 1. Çekirdek & Sistem Performansı
- **Linux Zen Kernel:** Masaüstü ve oyun tepkiselliği için optimize edilmiş düşük gecikmeli çekirdek.
- **TCP BBR & CAKE:** `tcp_bbr` tıkanıklık kontrolü ve `cake` kuyruk disiplini ile bufferbloat sıfırlanmış akıcı ağ iletişimi.
- **%100 ZRAM Swap:** `zstd` algoritması ile RAM kapasitesinin %100'ü kadar dinamik sıkıştırılmış takas alanı.
- **Gelişmiş Ağ & Güvenlik:** Katman 1 (Sysctl) ve Katman 2 (iptables mangle) TTL bypass (65) ile mobil hotspot/tethering gizleme, Magic SysRq (`kernel.sysrq = 1`) ve kilitlenme koruması (`panic=10 oops=panic`).
- **Impermanence & Ephemeral Root:** Kök dizin her açılışta RAM üzerinde sıfırlanır, kritik kullanıcı verileri `/persist` altında güvenle korunur.

### 🎨 2. Masaüstü & Görsel Deneyim
- **Modüler Hyprland Mimarisi:** `bindings.nix` ve `rules.nix` ile ayrıştırılmış; en güncel `match:class` ve `match:title` sözdizimine uyarlanmış deklaratif pencere kuralları, otomatik float diyaloglar ve çalışma alanı atamaları.
- **Quickshell Masaüstü Kabuğu:** QML ve Wayland-native masaüstü bileşenleri:
  - Üst Bilgi Çubuğu (Bar) & Çalışma Alanı İzleyici
  - Ses, Ağ, Bluetooth, Ekran, Güç, Hava Durumu ve Takvim Açılır Menüleri (Dinamik ekran genişliği duyarlı)
  - OSD (Ses/Parlaklık göstergeleri) ve Kilit Ekranı
  - Sakin ve yerinde açılan (`no_anim on`) pencereler ve komut paleti
- **Dinamik Tema Motoru:** Tek tıkla tema değişimi (`xmarchy-dark`, `catppuccin`, `rose-pine`, `nord`, `cyberpunk`, `xmarchy-light`). Hyprland borderları, Wofi CSS stilleri ve Bar renkleri anında senkronize olur.

### 🛠️ 3. Ergonomi, AI ve Üretkenlik Araçları
- **AI Ajan Başlatıcılar:** Claude Code (`@anthropic-ai/claude-code`) ve Cline (`@cline/cli`) otonom AI geliştirici ajanları masaüstü menülerine entegre.
- **Pano Geçmişi (Cliphist + Wofi):** Arka planda çalışan metin ve görsel pano dinleyicisi; `SUPER + C` veya `SUPER + CTRL + V` ile dinamik cam efektli Wofi arayüzünde anında arama ve yapıştırma.
- **Gece Işığı (Night Light):** `hyprsunset` tabanlı 4000K mavi ışık filtresi. `SUPER + CTRL + N` kısayoluyla veya Ekran Menüsünden (`DisplayMenu`) açılıp kapanabilir.
- **Tuş Rehberi (Cheat Sheet):** Sistemdeki tüm kısayolları kategorize ederek arama imkanı sunan Wofi tabanlı etkileşimli rehber (`SUPER + F1` veya `SUPER + /`).
- **Dinamik WebApp Yükleyici:** `xmarchy webapp install <Ad> <URL>` komutuyla herhangi bir web servisini anında sistem uygulamasına dönüştürme.
- **Sihirli Scratchpad:** `SUPER + S` ile gizli çalışma alanını çağırma, `SUPER + Z` ile pencereleri sessizce bu alana gönderme.

---

## ⌨️ Temel Klavye Kısayolları

| Kısayol | Eylem |
| :--- | :--- |
| `SUPER + Return` | Kitty Terminali Aç |
| `SUPER + Space` / `ALT + Space` | Quickshell Uygulama & Komut Paleti (Launcher) |
| `SUPER + C` / `SUPER + CTRL + V` | Pano Geçmişi Menüsü (Cliphist / Wofi) |
| `SUPER + F1` / `SUPER + /` | Kısayol Tuş Rehberi (Cheat Sheet) |
| `SUPER + H, J, K, L` | Vim Stili Pencere Odak Gezinmesi (Sol, Aşağı, Yukarı, Sağ) |
| `SUPER + CTRL + N` | Gece Işığı (Night Light - 4000K) Aç / Kapat |
| `SUPER + Q` | Aktif Pencereyi Kapat |
| `SUPER + F` | Kayan Pencere (Floating) Aç / Kapat |
| `SUPER + S` | Gizli Çalışma Alanını Aç / Kapat (Scratchpad) |
| `SUPER + Z` | Aktif Pencereyi Scratchpad'e Gönder |
| `SUPER + 1..9` | Çalışma Alanına (Workspace) Geç |
| `SUPER + SHIFT + 1..9` | Pencereyi Belirtilen Çalışma Alanına Taşı |
| `Print` | Tam Ekran Görüntüsü Al (`xmarchy-capture screen`) |
| `SUPER + Print` | Bölgesel Ekran Görüntüsü Al (`xmarchy-capture region`) |
| `SUPER + CTRL + A` | Ses Menüsü (Audio Menu) |
| `SUPER + CTRL + W` | Ağ Menüsü (Network Menu) |
| `SUPER + CTRL + B` | Bluetooth Menüsü |
| `SUPER + CTRL + D` | Ekran Ayarları Menüsü (Display Menu) |
| `SUPER + CTRL + P` | Güç Menüsü (Power Menu) |
| `SUPER + CTRL + C` | Takvim Menüsü (Calendar Menu) |

*(Not: Tüm `SUPER` kısayolları sanal makine ve çoklu ortam uyumluluğu için alternatif olarak `ALT` tuşu ile de kullanılabilir).*

---

## 💻 Xmarchy CLI Araçları

Sistem içinde kurulu gelen özel Nix-native araçlar:

- `xmarchy-audio` — Ses seviyesi artırma, azaltma, sessize alma (`vol-up`, `vol-down`, `mute`)
- `xmarchy-bright` — Ekran parlaklığını ayarlama (`up`, `down`)
- `xmarchy-capture` — Ekran görüntüsü ve bölgesel yakalama (`screen`, `region`)
- `xmarchy-nightlight` — Mavi ışık filtresi kontrolü (`on`, `off`, `toggle`, `status`)
- `xmarchy-keybindings` — Kısayol tuşlarını arama ve Wofi üzerinde listeleme
- `xmarchy-theme-apply` — Sistem genelinde dinamik tema geçişi (Hyprland + Wofi + State)
- `xmarchy webapp install <Ad> <URL>` — Chromium tabanlı bağımsız web uygulaması oluşturma
- `xmarchy webapp remove <Ad>` — Oluşturulan web uygulamasını sistemden kaldırma

---

## 🏗️ Dizin Yapısı

```
modules/
├── apps/          # Uygulama paketleri (AI ajanlar, tarayıcılar, webapps)
├── cli/           # Xmarchy Nix-native CLI suite (core.nix, default.nix)
├── desktop/       # Quickshell kabuğu, Wayland araçları, Wofi temaları
│   └── quickshell/
│       ├── plugins/   # Bar, Menüler, Launcher, OSD, Lock
│       └── themes/    # JSON tema tanımları
├── developer/     # Terminal araçları (git, zsh, bat, eza, fzf...)
├── hardware/      # Donanım algılama ve GPU hızlandırma
├── home/          # Home Manager yapılandırması
│   └── hyprland/  # Modüler Hyprland (default.nix, bindings.nix, rules.nix)
└── os/            # Çekirdek (Zen), Güvenlik (TTL 65 + Firewall), ZRAM, Pipewire, SDDM
```

---

## 🧪 Test Etme ve Derleme

### Sanal Makine (VM) ile Çalıştırma
```bash
# 1. VM derleme
nix build .#vm -o result-vm

# 2. VM çalıştırma
./result-vm/bin/run-xmarchy-vm
```

### Kurulum Medyası (Live ISO) Oluşturma
```bash
nix build .#nixosConfigurations.xmarchy-iso.config.system.build.isoImage
```

---

## 📄 Lisans
MIT License
