{ pkgs, ... }:

let
  xmarchy-theme-apply = pkgs.writeShellApplication {
    name = "xmarchy-theme-apply";
    runtimeInputs = [ pkgs.jq pkgs.coreutils pkgs.hyprland ];
    text = ''
      if [ "$#" -lt 3 ]; then
        echo "Usage: xmarchy-theme-apply <theme-name> <bg-color> <accent-color>"
        exit 1
      fi

      THEME_NAME="$1"
      BG_COLOR="$2"
      ACCENT_COLOR="$3"

      # 1. Hyprland Border Renklerini Guncelle
      BG_HEX="''${BG_COLOR##}"
      ACCENT_HEX="''${ACCENT_COLOR##}"
      
      hyprctl keyword general:col.active_border "rgb(''${ACCENT_HEX})" || true
      hyprctl keyword general:col.inactive_border "rgb(''${BG_HEX})" || true

      # 2. Secilen temayi kullanici config dizinine kaydet
      mkdir -p "$HOME/.config/xmarchy"
      echo "{\"theme\": \"''${THEME_NAME}\"}" > "$HOME/.config/xmarchy/current-theme.json"

      # Sistem dizini yazilabilirse oraya da kaydet
      if [ -w /var/lib/xmarchy ]; then
        echo "{\"theme\": \"''${THEME_NAME}\"}" > /var/lib/xmarchy/current-theme.json || true
      fi
    '';
  };
in{
  environment.systemPackages = [
    xmarchy-theme-apply
  ];
}
