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
      BG_HEX="''${BG_COLOR#\#}"
      ACCENT_HEX="''${ACCENT_COLOR#\#}"
      
      hyprctl keyword general:col.active_border "rgb(''${ACCENT_HEX})" || true
      hyprctl keyword general:col.inactive_border "rgb(''${BG_HEX})" || true

      # 2. Secilen temayi kullanici config dizinine kaydet
      mkdir -p "$HOME/.config/xmarchy"
      echo "{\"theme\": \"''${THEME_NAME}\"}" > "$HOME/.config/xmarchy/current-theme.json"

      # Sistem dizini yazilabilirse oraya da kaydet
      if [ -w /var/lib/xmarchy ]; then
        echo "{\"theme\": \"''${THEME_NAME}\"}" > /var/lib/xmarchy/current-theme.json || true
      fi

      # 3. Wofi Dinamik CSS Senkronizasyonu (Canli Tema)
      mkdir -p "$HOME/.config/wofi"
      cat << WOFI_CSS > "$HOME/.config/wofi/current-theme.css"
* {
    font-family: "JetBrains Mono Nerd Font", monospace;
    font-size:   13px;
    outline:     none;
    border:      none;
    box-shadow:  none;
}
window {
    background-color: ''${BG_COLOR}ee;
    border:           1px solid ''${ACCENT_COLOR}88;
    border-radius:    14px;
    padding:          12px;
}
#inner-box {
    background-color: transparent;
    border-radius:    10px;
    padding:          4px;
}
#outer-box {
    background-color: transparent;
    padding:          6px;
}
#input {
    background-color: ''${BG_COLOR};
    color:            #c0caf5;
    border:           1px solid ''${ACCENT_COLOR}66;
    border-radius:    8px;
    padding:          8px 14px;
    margin-bottom:    8px;
    caret-color:      ''${ACCENT_COLOR};
}
#input:focus {
    border-color: ''${ACCENT_COLOR};
}
#scroll {
    background-color: transparent;
    border-radius:    8px;
}
#entry {
    background-color: transparent;
    color:            #a9b1d6;
    border-radius:    8px;
    padding:          6px 12px;
    margin:           2px 0;
    transition:       background-color 150ms ease, color 100ms ease;
}
#entry:hover,
#entry:selected {
    background-color: ''${ACCENT_COLOR}33;
    color:            #ffffff;
    border-left:      3px solid ''${ACCENT_COLOR};
    padding-left:     10px;
}
#entry image {
    margin-right:   8px;
    opacity:        0.9;
}
#entry:selected image {
    opacity: 1;
}
#entry label {
    color: inherit;
}
scrollbar {
    background-color: transparent;
    border-radius:    4px;
    width:            4px;
}
scrollbar slider {
    background-color: ''${ACCENT_COLOR}4d;
    border-radius:    4px;
    min-height:       30px;
}
scrollbar slider:hover {
    background-color: ''${ACCENT_COLOR}99;
}
WOFI_CSS
    '';
  };
in {
  environment.systemPackages = [
    xmarchy-theme-apply
  ];

  # /var/lib/xmarchy dizini icin kullanici erisim yetkisi
  systemd.tmpfiles.rules = [
    "d /var/lib/xmarchy 0775 nixos users -"
  ];
}
