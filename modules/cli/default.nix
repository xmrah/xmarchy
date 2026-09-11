{ pkgs, ... }:

let
  xmarchy-theme-apply = pkgs.writeShellApplication {
    name = "xmarchy-theme-apply";
    runtimeInputs = [ pkgs.jq pkgs.coreutils pkgs.hyprland ];
    text = ''
      if [ "$#" -lt 3 ]; then
        echo "Usage: xmarchy-theme-apply <theme-name> <bg-color> <fg-color>"
        exit 1
      fi

      THEME_NAME="$1"
      BG_COLOR="$2"
      FG_COLOR="$3"

      # 1. Hyprland Border Renklerini Güncelle
      # Hyprland rgb() formatı istiyor, '#' işaretini kaldırıyoruz
      FG_HEX="''${FG_COLOR#\#}"
      BG_HEX="''${BG_COLOR#\#}"
      hyprctl keyword general:col.active_border "rgb(''${FG_HEX})"
      hyprctl keyword general:col.inactive_border "rgb(''${BG_HEX})"

      # 2. Seçilen temayı Impermanence state dosyasına kaydet
      mkdir -p /var/lib/xmarchy
      echo "{\"theme\": \"$THEME_NAME\"}" > /var/lib/xmarchy/current-theme.json

      # TODO: Kitty ve Tmux canlı güncelleme komutları
    '';
  };
in
{
  environment.systemPackages = [
    xmarchy-theme-apply
  ];
}
