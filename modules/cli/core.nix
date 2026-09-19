{ pkgs, ... }:

let
  xmarchy-audio = pkgs.writeShellApplication {
    name = "xmarchy-audio";
    runtimeInputs = [ pkgs.wireplumber pkgs.jq pkgs.gawk pkgs.quickshell ];
    text = ''
      if [ "$#" -lt 1 ]; then
        echo "Usage: xmarchy-audio [up|down|mute]"
        exit 1
      fi

      CMD="$1"
      SINK="@DEFAULT_AUDIO_SINK@"

      case "$CMD" in
        up)
          wpctl set-volume -l 1.0 "$SINK" 5%+
          ;;
        down)
          wpctl set-volume "$SINK" 5%-
          ;;
        mute)
          wpctl set-mute "$SINK" toggle
          ;;
      esac

      # Yeni seviyeyi alıp OSD'ye gönder
      VOL=$(wpctl get-volume "$SINK" | awk '{print int($2 * 100)}')
      MUTED=$(wpctl get-volume "$SINK" | grep -q MUTED && echo "1" || echo "0")
      
      if [ "$MUTED" = "1" ]; then
        quickshell ipc call osd show "MUTE" 0 || true
      else
        quickshell ipc call osd show "VOL" "$VOL" || true
      fi
    '';
  };

  xmarchy-bright = pkgs.writeShellApplication {
    name = "xmarchy-bright";
    runtimeInputs = [ pkgs.brightnessctl pkgs.gawk pkgs.quickshell ];
    text = ''
      if [ "$#" -lt 1 ]; then
        echo "Usage: xmarchy-bright [up|down]"
        exit 1
      fi

      case "$1" in
        up)
          brightnessctl set +5%
          ;;
        down)
          brightnessctl set 5%-
          ;;
      esac

      # Yeni seviyeyi alıp OSD'ye gönder
      MAX=$(brightnessctl m)
      CUR=$(brightnessctl g)
      VAL=$(awk "BEGIN {print int(($CUR/$MAX)*100)}")
      
      quickshell ipc call osd show "BRT" "$VAL" || true
    '';
  };

  xmarchy-capture = pkgs.writeShellApplication {
    name = "xmarchy-capture";
    runtimeInputs = [
      pkgs.grim
      pkgs.slurp
      pkgs.wl-clipboard
      pkgs.wf-recorder
      pkgs.tesseract5
      pkgs.zbar
      pkgs.qrencode
      pkgs.mpv
      pkgs.libnotify
      pkgs.procps
      pkgs.coreutils
    ];
    text = ''
      if [ "$#" -lt 1 ]; then
        echo "Kullanım: xmarchy-capture [screen|region|record-screen|record-region|record-stop|ocr|qr-scan|qr-gen|webcam]"
        exit 1
      fi

      VID_DIR="$HOME/Videos/Recordings"
      mkdir -p "$VID_DIR"
      TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
      VID_FILE="$VID_DIR/record_$TIMESTAMP.mp4"

      case "$1" in
        screen)
          grim - | wl-copy
          notify-send "Ekran Görüntüsü" "Tüm ekran panoya kopyalandı." -i camera-photo || true
          ;;
        region)
          GEOM=$(slurp)
          if [ -n "$GEOM" ]; then
            grim -g "$GEOM" - | wl-copy
            notify-send "Ekran Görüntüsü" "Seçilen alan panoya kopyalandı." -i camera-photo || true
          fi
          ;;
        record-screen)
          if pgrep -x "wf-recorder" >/dev/null; then
            pkill -INT -x wf-recorder
            notify-send "Ekran Kaydı" "Kayıt durduruldu ve kaydedildi." -i media-record || true
          else
            notify-send "Ekran Kaydı Başladı" "Tüm ekran sesli olarak kaydediliyor..." -i media-record || true
            wf-recorder --audio -f "$VID_FILE"
          fi
          ;;
        record-region)
          if pgrep -x "wf-recorder" >/dev/null; then
            pkill -INT -x wf-recorder
            notify-send "Ekran Kaydı" "Kayıt durduruldu ve kaydedildi." -i media-record || true
          else
            GEOM=$(slurp)
            if [ -n "$GEOM" ]; then
              notify-send "Ekran Kaydı Başladı" "Seçilen alan sesli olarak kaydediliyor..." -i media-record || true
              wf-recorder -g "$GEOM" --audio -f "$VID_FILE"
            fi
          fi
          ;;
        record-stop)
          if pgrep -x "wf-recorder" >/dev/null; then
            pkill -INT -x wf-recorder
            notify-send "Ekran Kaydı" "Kayıt tamamlandı: $VID_DIR" -i media-record || true
          else
            notify-send "Ekran Kaydı" "Şu anda aktif bir kayıt bulunmuyor." || true
          fi
          ;;
        ocr)
          GEOM=$(slurp)
          if [ -n "$GEOM" ]; then
            OCR_TEXT=$(grim -g "$GEOM" - | tesseract - stdout 2>/dev/null || true)
            if [ -n "$OCR_TEXT" ]; then
              echo "$OCR_TEXT" | wl-copy
              notify-send "Canlı OCR" "Tanınan metin panoya kopyalandı!" -i edit-copy || true
            else
              notify-send "Canlı OCR" "Metin algılanamadı." || true
            fi
          fi
          ;;
        qr-scan)
          GEOM=$(slurp)
          if [ -n "$GEOM" ]; then
            QR_TEXT=$(grim -g "$GEOM" - | zbarimg --raw - 2>/dev/null | tr -d "\r\n" || true)
            if [ -n "$QR_TEXT" ]; then
              echo "$QR_TEXT" | wl-copy
              notify-send "QR Kod Okundu" "$QR_TEXT" -i edit-copy || true
            else
              notify-send "QR Kod" "Görselde QR kod bulunamadı." || true
            fi
          fi
          ;;
        qr-gen)
          CLIP_TEXT=$(wl-paste 2>/dev/null || true)
          if [ -n "$CLIP_TEXT" ]; then
            qrencode -o - "$CLIP_TEXT" | mpv --geometry=350x350 --autofit=350x350 --keep-open=yes - || true
          else
            notify-send "QR Kod Üretici" "Panoda metin bulunamadı." || true
          fi
          ;;
        webcam)
          if [ -e /dev/video0 ]; then
            mpv --demuxer-lavf-format=video4linux2 --demuxer-lavf-o-set=input_format=mjpeg av://v4l2:/dev/video0 --geometry=480x270 --autofit=480x270 --title="Xmarchy Webcam Mirror" --untimed || true
          else
            notify-send "Webcam" "/dev/video0 kamerası bulunamadı." || true
          fi
          ;;
        *)
          echo "Bilinmeyen parametre: $1"
          exit 1
          ;;
      esac
    '';
  };

  xmarchy-power = pkgs.writeShellApplication {
    name = "xmarchy-power";
    runtimeInputs = [ pkgs.systemd pkgs.quickshell ];
    text = ''
      case "''${1:-}" in
        lock) quickshell ipc call lock toggle ;;
        reboot) systemctl reboot ;;
        shutdown) systemctl poweroff ;;
        sleep) systemctl suspend ;;
        *) echo "Usage: xmarchy-power [lock|reboot|shutdown|sleep]" ;;
      esac
    '';
  };

  xmarchy-network-status = pkgs.writeShellApplication {
    name = "xmarchy-network-status";
    runtimeInputs = [ pkgs.iproute2 pkgs.iputils pkgs.jq pkgs.coreutils pkgs.gawk pkgs.networkmanager ];
    text = ''
      export LC_ALL=C
      route_info=$(ip -j route get 1.1.1.1 2>/dev/null || echo "[]")
      iface=$(echo "$route_info" | jq -r '.[0].dev // ""')
      gw=$(echo "$route_info" | jq -r '.[0].gateway // ""')
      ip=$(echo "$route_info" | jq -r '.[0].prefsrc // ""')

      if [ -z "$iface" ]; then
        echo '{"connected":false,"name":"Offline","type":"none","phrase":"DISCONNECTED","ping":"--","packet_loss":"100%","rx_bytes":0,"tx_bytes":0,"ip":"--","gateway":"--","dns":"DHCP"}'
        exit 0
      fi

      dev_type="ethernet"
      dev_name="Ethernet"
      if [ -d "/sys/class/net/$iface/wireless" ]; then
        dev_type="wifi"
        dev_name=$(nmcli -t -f GENERAL.CONNECTION dev show "$iface" 2>/dev/null | head -1 | cut -d: -f2)
        [ -z "$dev_name" ] && dev_name="Wi-Fi"
      fi

      rx=$(cat "/sys/class/net/$iface/statistics/rx_bytes" 2>/dev/null || echo 0)
      tx=$(cat "/sys/class/net/$iface/statistics/tx_bytes" 2>/dev/null || echo 0)

      target="$gw"
      [ -z "$target" ] && target="1.1.1.1"
      ping_out=$(ping -n -c 1 -W 1 "$target" 2>/dev/null || true)
      ping_ms=$(echo "$ping_out" | awk -F"time=" '/time=/ { split($2, a, " "); print int(a[1])" ms"; exit }')
      loss=$(echo "$ping_out" | awk -F"," '/packet loss/ { for (i=1; i<=NF; i++) if ($i ~ /packet loss/) { gsub(/^[ \t]+|[ \t]+$/, "", $i); print $i; exit } }')
      [ -z "$ping_ms" ] && ping_ms="-- ms"
      [ -z "$loss" ] && loss="0% packet loss"
      loss_pct=$(echo "$loss" | awk '{print $1}')

      dns="DHCP"
      dns_servers=$(nmcli dev show "$iface" 2>/dev/null | awk '/IP4.DNS/ {print $2}')
      if echo "$dns_servers" | grep -qE "1.1.1.1|1.0.0.1"; then
        dns="Cloudflare"
      elif echo "$dns_servers" | grep -qE "8.8.8.8|8.8.4.4"; then
        dns="Google"
      fi

      jq -n \
        --arg connected "true" \
        --arg type "$dev_type" \
        --arg name "$dev_name" \
        --arg phrase "HAULING BYTES" \
        --arg ping "$ping_ms" \
        --arg loss "$loss_pct" \
        --arg rx_bytes "$rx" \
        --arg tx_bytes "$tx" \
        --arg ip "$ip" \
        --arg gw "$gw" \
        --arg dns "$dns" \
        '{connected: ($connected == "true"), type: $type, name: $name, phrase: $phrase, ping: $ping, packet_loss: $loss, rx_bytes: ($rx_bytes | tonumber), tx_bytes: ($tx_bytes | tonumber), ip: $ip, gateway: $gw, dns: $dns}'
    '';
  };

  xmarchy-nightlight = pkgs.writeShellApplication {
    name = "xmarchy-nightlight";
    runtimeInputs = [ pkgs.hyprsunset pkgs.hyprland pkgs.procps pkgs.gawk pkgs.libnotify pkgs.coreutils ];
    text = ''
      CMD="''${1:-toggle}"
      ON_TEMP=4000
      OFF_TEMP=6500

      if ! pgrep -x hyprsunset >/dev/null 2>&1; then
        hyprsunset &
        sleep 0.3
      fi

      case "$CMD" in
        status)
          CUR=$(hyprctl hyprsunset temperature 2>/dev/null | grep -oE '[0-9]+' | head -n1 || echo "")
          if [ -n "$CUR" ] && [ "$CUR" -le 5000 ]; then
            echo "on"
          else
            echo "off"
          fi
          ;;
        on)
          hyprctl hyprsunset temperature $ON_TEMP >/dev/null 2>&1 || true
          notify-send -a "Xmarchy" -i weather-clear-night "Gece Işığı Aktif" "Renk sıcaklığı 4000K olarak ayarlandı."
          ;;
        off)
          hyprctl hyprsunset temperature $OFF_TEMP >/dev/null 2>&1 || true
          notify-send -a "Xmarchy" -i display-brightness "Gece Işığı Kapalı" "Renk sıcaklığı normale (6500K) döndürüldü."
          ;;
        toggle)
          STATUS=$(hyprctl hyprsunset temperature 2>/dev/null | grep -oE '[0-9]+' | head -n1 || echo "")
          if [ -n "$STATUS" ] && [ "$STATUS" -le 5000 ]; then
            hyprctl hyprsunset temperature $OFF_TEMP >/dev/null 2>&1 || true
            notify-send -a "Xmarchy" -i display-brightness "Gece Işığı Kapalı" "Renk sıcaklığı normale (6500K) döndürüldü."
          else
            hyprctl hyprsunset temperature $ON_TEMP >/dev/null 2>&1 || true
            notify-send -a "Xmarchy" -i weather-clear-night "Gece Işığı Aktif" "Renk sıcaklığı 4000K olarak ayarlandı."
          fi
          ;;
      esac
    '';
  };

  xmarchy-keybindings = pkgs.writeShellApplication {
    name = "xmarchy-keybindings";
    runtimeInputs = [ pkgs.wofi pkgs.hyprland pkgs.gawk pkgs.coreutils ];
    text = ''
      KEYLIST="✦ UYGULAMALAR & BAŞLATICI
  SUPER + Return               Terminali Aç (Kitty)
  SUPER + B                    Tarayıcıyı Aç (Brave/Chromium/Firefox)
  SUPER + Space                Uygulama Başlatıcı (Quickshell Launcher)
  SUPER + SHIFT + F            Dosya Yöneticisi (Dolphin/Thunar)
  SUPER + CTRL + T             Sistem Kaynak İzleyici (btop)
  SUPER + SHIFT + C            Renk Seçici (Hyprpicker)
  SUPER + Q                    Pencereyi Kapat

✦ MENÜLER & DENETİM MERKEZİ
  SUPER + CTRL + A             Ses Menüsü & Mikser (Audio)
  SUPER + CTRL + B             Bluetooth Menüsü
  SUPER + CTRL + W             Ağ & Wi-Fi Menüsü
  SUPER + CTRL + D             Ekran, Ölçek & Gece Işığı
  SUPER + CTRL + P             Güç Menüsü (Kapat/Yeniden Başlat)
  SUPER + CTRL + C             Takvim & Saat Menüsü
  SUPER + CTRL + N             Gece Işığı Aç/Kapat (Hyprsunset)
  SUPER + F1 (veya SUPER + /)   Bu Kısayol Rehberini Göster

✦ PANO & ÇALIŞMA ALANLARI
  SUPER + C                    Pano Geçmişi & Arama (Cliphist + Wofi)
  SUPER + CTRL + V             Pano Geçmişi & Arama (Alternatif)
  SUPER + S                    Sihirli Çalışma Alanı (Scratchpad) Aç/Kapat
  SUPER + Z                    Odaktaki Pencereyi Scratchpad'e Gönder
  SUPER + 1..9                 1-9 Numaralı Çalışma Alanına Geç
  SUPER + SHIFT + 1..9         Pencereyi 1-9 Çalışma Alanına Taşı

✦ MEDYA & YAKALAMA
  Print                        Tam Ekran Görüntüsü Al
  SUPER + Print                Bölge Ekran Görüntüsü Al
  Fn + F1-F12 (Medya Tuşları)  Ses Aç/Kıs/Sustur, Parlaklık, Oynat/Durdur"

      echo "$KEYLIST" | wofi --dmenu -p "Kısayol Rehberi" || true
    '';
  };

  xmarchy-cli = pkgs.writeShellApplication {
    name = "xmarchy";
    runtimeInputs = [
      pkgs.jq
      pkgs.coreutils
      pkgs.quickshell
      pkgs.wireplumber
      pkgs.procps
      pkgs.fastfetch
      pkgs.chromium
      pkgs.networkmanager
      pkgs.nixos-rebuild
      pkgs.nix
      xmarchy-audio
      xmarchy-bright
      xmarchy-capture
      xmarchy-power
      xmarchy-network-status
    ];
    text = ''
      show_banner() {
        echo -e "\033[1;36m"
        cat << 'BANNER'
  __  __                         _           
  \ \/ /_ __ ___   __ _ _ __ ___| |__  _   _ 
   \  /| '_ ` _ \ / _` | '__/ __| '_ \| | | |
   /  \| | | | | | (_| | | | (__| | | | |_| |
  /_/\_\_| |_| |_|\__,_|_|  \___|_| |_|\__, |
                                       |___/ 
        Sovereign Declarative Desktop OS
BANNER
        echo -e "\033[0m"
      }

      show_help() {
        show_banner
        echo "Kullanım: xmarchy <komut> [argümanlar]"
        echo ""
        echo "Komutlar:"
        echo "  theme [ad]             Masaüstü temasını listeler veya canlı uygular"
        echo "                         (xmarchy-dark, catppuccin, rose-pine, nord, cyberpunk, xmarchy-light)"
        echo "  status                 Sistem ve masaüstü durum özetini gösterir"
        echo "  update                 Sistem paketlerini (flake.lock) günceller ve derler"
        echo "  rollback               Bir önceki çalışan sistem nesline anında geri döner"
        echo "  generations            Mevcut sistem nesillerini listeler"
        echo "  webapp <url>           Belirtilen URL'yi bağımsız PWA penceresi olarak açar"
        echo "  dns [Cloudflare|Google|DHCP] DNS sunucusunu yapılandırır"
        echo "  scale [1|1.25|1.6|2]   Monitör ölçekleme oranını ayarlar"
        echo "  fetch                  Xmarchy özel sistem künyesini gösterir"
        echo "  audio [up|down|mute]   Ses seviyesini ayarlar"
        echo "  bright [up|down]       Ekran parlaklığını ayarlar"
        echo "  capture [screen|region|record-screen|ocr|qr-scan] Ekran görüntüsü, sesli kayıt, OCR ve QR araçları"
        echo "  power [lock|reboot|shutdown|sleep] Güç yönetimi"
        echo "  install                Xmarchy diske kurulum yardımcısı (Disko + NixOS)"
        echo ""
      }

      SUB="''${1:-}"
      if [ -n "$SUB" ]; then
        shift
      fi

      case "$SUB" in
        theme)
          THEME_NAME="''${1:-}"
          if [ -z "$THEME_NAME" ]; then
            CURRENT=$(jq -r .theme "$HOME/.config/xmarchy/current-theme.json" 2>/dev/null || echo "xmarchy-dark")
            echo "Mevcut Tema: $CURRENT"
            echo ""
            echo "Kullanılabilir Temalar:"
            echo "  • xmarchy-dark  (Varsayılan Tokyo Koyu)"
            echo "  • catppuccin    (Mocha Pastel & Totoro)"
            echo "  • rose-pine     (Sıcak Gül & İskandinav)"
            echo "  • nord          (Arktik Mavi & Kar)"
            echo "  • cyberpunk     (Neon Gece & Cyber Izgara)"
            echo "  • xmarchy-light (Minimalist Aydınlık)"
            echo ""
            echo "Uygulamak için: xmarchy theme <ad>"
          else
            quickshell ipc call theme apply "$THEME_NAME" || echo "Quickshell IPC ulaşılamadı."
            echo "Tema '$THEME_NAME' uygulandı."
          fi
          ;;
        status)
          show_banner
          echo "──────────────────────────────────────────────"
          echo "  OS:           Xmarchy (NixOS Linux Zen)"
          echo "  Masaüstü:     Hyprland Wayland Compositor"
          echo "  Kabuk:        Quickshell 0.3.0 QML"
          echo "  Tema:         $(jq -r .theme "$HOME/.config/xmarchy/current-theme.json" 2>/dev/null || echo "xmarchy-dark")"
          echo "  Bellek:       $(free -h | awk '/Mem:/ {print $3 " / " $2}')"
          echo "  Çalışma:      $(uptime -p)"
          echo "──────────────────────────────────────────────"
          ;;
        update)
          echo -e "\033[1;34m:: Xmarchy Sistemi Güncelleniyor...\033[0m"
          FLAKE_DIR="''${XMARCHY_FLAKE_DIR:-/etc/nixos}"
          if [ ! -d "$FLAKE_DIR" ] && [ -d "$HOME/Projects/xmarchy" ]; then
            FLAKE_DIR="$HOME/Projects/xmarchy"
          fi
          echo "Hedef Flake: $FLAKE_DIR"
          sudo nix flake update "$FLAKE_DIR"
          sudo nixos-rebuild switch --flake "$FLAKE_DIR"
          echo -e "\033[1;32m✓ Sistem başarıyla güncellendi ve etkinleştirildi!\033[0m"
          ;;
        rollback)
          echo -e "\033[1;33m:: Önceki stabil nesile geri dönülüyor (Rollback)...\033[0m"
          sudo nixos-rebuild switch --rollback
          echo -e "\033[1;32m✓ Önceki nesil başarıyla etkinleştirildi!\033[0m"
          ;;
        generations)
          echo -e "\033[1;36m:: Xmarchy Sistem Nesilleri (Generations):\033[0m"
          nixos-rebuild list-generations
          ;;
        webapp)
          ACTION="''${1:-}"
          if [ "$ACTION" = "install" ]; then
            shift || true
            APP_NAME="''${1:-}"
            APP_URL="''${2:-}"
            if [ -z "$APP_NAME" ] || [ -z "$APP_URL" ]; then
              echo "Kullanım: xmarchy webapp install <Uygulama Adı> <URL>"
              echo "Örnek: xmarchy webapp install 'Claude' 'https://claude.ai'"
              exit 1
            fi
            ICON_DIR="$HOME/.local/share/icons/hicolor/256x256/apps"
            DESKTOP_DIR="$HOME/.local/share/applications"
            mkdir -p "$ICON_DIR" "$DESKTOP_DIR"
            SAFE_NAME=$(echo "$APP_NAME" | tr '[:upper:]' '[:lower:]' | tr -c '[:alnum:]' '-')
            ICON_PATH="$ICON_DIR/$SAFE_NAME.png"
            curl -fsSL --max-time 6 -o "$ICON_PATH" "https://www.google.com/s2/favicons?domain=$APP_URL&sz=256" || true
            cat > "$DESKTOP_DIR/$SAFE_NAME.desktop" <<EOF
[Desktop Entry]
Version=1.0
Name=$APP_NAME
Comment=$APP_NAME Web Uygulaması
Exec=chromium --app=$APP_URL %U
Terminal=false
Type=Application
Icon=$SAFE_NAME
Categories=Network;Utility;
StartupNotify=true
EOF
            chmod +x "$DESKTOP_DIR/$SAFE_NAME.desktop"
            echo -e "\033[1;32m✓ '$APP_NAME' başarıyla kuruldu! Başlatıcıda (SUPER + Space) arayabilirsiniz.\033[0m"
          elif [ "$ACTION" = "remove" ]; then
            shift || true
            APP_NAME="''${1:-}"
            SAFE_NAME=$(echo "$APP_NAME" | tr '[:upper:]' '[:lower:]' | tr -c '[:alnum:]' '-')
            rm -f "$HOME/.local/share/applications/$SAFE_NAME.desktop"
            echo -e "\033[1;33m✓ '$APP_NAME' uygulaması kaldırıldı.\033[0m"
          else
            URL="''${1:-}"
            if [ -n "$URL" ]; then
              exec chromium --app="$URL"
            else
              echo "Kullanım:"
              echo "  xmarchy webapp install <Ad> <URL>   Yeni web uygulaması kurar"
              echo "  xmarchy webapp remove <Ad>          Web uygulamasını kaldırır"
              echo "  xmarchy webapp <URL>                URL'i uygulama modunda açar"
            fi
          fi
          ;;
        nightlight)
          shift || true
          exec xmarchy-nightlight "$@"
          ;;
        keys|keybindings)
          exec xmarchy-keybindings
          ;;
        dns)
          PROVIDER="''${1:-}"
          case "$PROVIDER" in
            Cloudflare|cloudflare)
              nmcli connection show --active | awk 'NR>1 {print $1}' | while read -r con; do
                [ -n "$con" ] && nmcli connection modify "$con" ipv4.ignore-auto-dns yes ipv4.dns "1.1.1.1 1.0.0.1" 2>/dev/null || true
              done
              echo "DNS sağlayıcı: Cloudflare (1.1.1.1, 1.0.0.1) uygulandı."
              ;;
            Google|google)
              nmcli connection show --active | awk 'NR>1 {print $1}' | while read -r con; do
                [ -n "$con" ] && nmcli connection modify "$con" ipv4.ignore-auto-dns yes ipv4.dns "8.8.8.8 8.8.4.4" 2>/dev/null || true
              done
              echo "DNS sağlayıcı: Google (8.8.8.8, 8.8.4.4) uygulandı."
              ;;
            DHCP|dhcp)
              nmcli connection show --active | awk 'NR>1 {print $1}' | while read -r con; do
                [ -n "$con" ] && nmcli connection modify "$con" ipv4.ignore-auto-dns no ipv4.dns "" 2>/dev/null || true
              done
              echo "DNS sağlayıcı: DHCP (Otomatik) uygulandı."
              ;;
            *)
              echo "Kullanım: xmarchy dns [Cloudflare|Google|DHCP]"
              exit 1
              ;;
          esac
          ;;
        scale)
          SCALE_VAL="''${1:-1}"
          hyprctl keyword monitor ",preferred,auto,$SCALE_VAL" || true
          echo "Monitör ölçeği $SCALE_VAL olarak ayarlandı."
          ;;
        fetch)
          fastfetch --logo-type small --structure title:separator:os:kernel:uptime:packages:shell:wm:terminal:cpu:memory:break:colors 2>/dev/null || fastfetch
          ;;
        audio)
          exec xmarchy-audio "$@"
          ;;
        bright)
          exec xmarchy-bright "$@"
          ;;
        capture)
          exec xmarchy-capture "$@"
          ;;
        power)
          exec xmarchy-power "$@"
          ;;
        install)
          exec xmarchy-install "$@"
          ;;
        help|--help|-h|"")
          show_help
          ;;
        *)
          echo "Bilinmeyen komut: $SUB"
          show_help
          exit 1
          ;;
      esac
    '';
  };

in
{
  environment.systemPackages = [
    xmarchy-audio
    xmarchy-bright
    xmarchy-capture
    xmarchy-power
    xmarchy-network-status
    xmarchy-nightlight
    xmarchy-keybindings
    xmarchy-cli
  ];
}
