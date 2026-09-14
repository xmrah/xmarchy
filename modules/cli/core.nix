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
    runtimeInputs = [ pkgs.grim pkgs.slurp pkgs.wl-clipboard ];
    text = ''
      if [ "$#" -lt 1 ]; then
        echo "Usage: xmarchy-capture [screen|region]"
        exit 1
      fi

      case "$1" in
        screen)
          grim - | wl-copy
          ;;
        region)
          grim -g "$(slurp)" - | wl-copy
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
        echo "  webapp <url>           Belirtilen URL'yi bağımsız PWA penceresi olarak açar"
        echo "  dns [Cloudflare|Google|DHCP] DNS sunucusunu yapılandırır"
        echo "  scale [1|1.25|1.6|2]   Monitör ölçekleme oranını ayarlar"
        echo "  fetch                  Xmarchy özel sistem künyesini gösterir"
        echo "  audio [up|down|mute]   Ses seviyesini ayarlar"
        echo "  bright [up|down]       Ekran parlaklığını ayarlar"
        echo "  capture [screen|region] Ekran görüntüsü alır"
        echo "  power [lock|reboot|shutdown|sleep] Güç yönetimi"
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
        webapp)
          URL="''${1:-}"
          if [ -z "$URL" ]; then
            echo "Hata: Bir URL belirtmelisiniz!"
            echo "Örnek: xmarchy webapp https://discord.com/app"
            exit 1
          fi
          exec chromium --app="$URL"
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
    xmarchy-cli
  ];
}
