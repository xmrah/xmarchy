{ ... }:

{
  wayland.windowManager.hyprland.settings = {
    # ═══════════ Pencere Kuralları (Window Rules) ═══════════
    windowrule = [
      # Otomatik Float (Açılır sistem pencereleri, diyaloglar)
      "float on, match:class ^(pavucontrol)$"
      "float on, match:class ^(blueman-manager)$"
      "float on, match:class ^(nm-connection-editor)$"
      "float on, match:class ^(org.kde.polkit-kde-authentication-agent-1)$"
      "float on, match:title ^(Open File)$"
      "float on, match:title ^(Save File)$"
      "float on, match:title ^(Confirm to replace files)$"
      "float on, match:title ^(File Operation Progress)$"
      "float on, match:class ^(mpv)$"
      "float on, match:class ^(imv)$"
      "float on, match:class ^(org.gnome.Calculator)$"

      # Çalışma Alanı (Workspace) Atamaları
      "workspace 1, match:class ^(chromium)$"
      "workspace 1, match:class ^(brave-browser)$"
      "workspace 1, match:class ^(firefox)$"
      "workspace 1, match:class ^(zen)$"
      "workspace 2, match:class ^(kitty)$"
      "workspace 3, match:class ^(org.kde.dolphin)$"
      "workspace 3, match:class ^(thunar)$"
      "workspace 4, match:class ^(code)$"
      "workspace 4, match:class ^(Code)$"
      "workspace 4, match:class ^(codium)$"
      "workspace 8, match:class ^(discord)$"
      "workspace 8, match:class ^(vesktop)$"
      "workspace 8, match:class ^(whatsapp)$"
      "workspace 9, match:class ^(Spotify)$"
      "workspace 9, match:title ^(Spotify)$"

      # Opasite (Glassmorphism Derinliği)
      "opacity 0.92 0.88, match:class ^(kitty)$"
      "opacity 0.95 0.90, match:class ^(code)$"
      "opacity 0.95 0.90, match:class ^(Code)$"
      "opacity 0.95 0.90, match:class ^(codium)$"
    ];

    # ═══════════ Katman Kuralları (Layer Rules) ═══════════
    layerrule = [
      # Quickshell: Menülerin ve launcher arkaplanının sakin ve doğal açılması
      "no_anim on, match:namespace quickshell"

      # Wofi Uygulama ve Pano Menüsü
      "animation popin 80%, match:namespace wofi"
      "blur on, match:namespace wofi"
      "ignore_alpha 0, match:namespace wofi"
    ];
  };
}
