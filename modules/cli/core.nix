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
        quickshell ipc call default osd show "MUTE" 0 || true
      else
        quickshell ipc call default osd show "VOL" "$VOL" || true
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
      
      quickshell ipc call default osd show "BRT" "$VAL" || true
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
        lock) quickshell ipc call default lock toggle ;;
        reboot) systemctl reboot ;;
        shutdown) systemctl poweroff ;;
        sleep) systemctl suspend ;;
        *) echo "Usage: xmarchy-power [lock|reboot|shutdown|sleep]" ;;
      esac
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
      xmarchy-audio
      xmarchy-bright
      xmarchy-capture
      xmarchy-power
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
            quickshell ipc call default theme apply "$THEME_NAME" || echo "Quickshell IPC ulaşılamadı."
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
    xmarchy-cli
  ];
}
