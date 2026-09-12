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
      case "$1" in
        lock) quickshell ipc call default lock toggle ;;
        reboot) systemctl reboot ;;
        shutdown) systemctl poweroff ;;
        sleep) systemctl suspend ;;
        *) echo "Usage: xmarchy-power [lock|reboot|shutdown|sleep]" ;;
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
  ];
}
