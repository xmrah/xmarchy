{ ... }:

{
  imports = [
    ./bindings.nix
    ./rules.nix
    ./idle.nix
  ];

  # Hyprland Window Manager Yapılandırması
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    configType = "hyprlang";

    settings = {
      monitor = ",preferred,auto,1";

      # Sanal makine ve Wayland render uyumluluğu
      env = [
        "WLR_NO_HARDWARE_CURSORS,1"
        "WLR_RENDERER_ALLOW_SOFTWARE,1"
        "AQ_NO_MODIFIERS,1"
      ];

      general = {
        gaps_in = 6;
        gaps_out = 12;
        border_size = 2;
        "col.active_border" = "rgb(cba6f7) rgb(89b4fa) 45deg";
        "col.inactive_border" = "rgb(313244)";
        layout = "dwindle";
      };

      decoration = {
        rounding = 12;
        blur = {
          enabled = true;
          size = 6;
          passes = 2;
          new_optimizations = true;
          ignore_opacity = true;
        };
        shadow = {
          enabled = true;
          range = 12;
          render_power = 3;
          color = "rgba(0,0,0,0.4)";
        };
      };

      animations = {
        enabled = true;
        bezier = "smooth, 0.25, 0.1, 0.25, 1";
        animation = [
          "windows, 1, 4, smooth, slide"
          "windowsOut, 1, 4, smooth, slide"
          "fade, 1, 4, smooth"
          "workspaces, 1, 4, smooth, slide"
        ];
      };

      input = {
        kb_layout = "tr";
        follow_mouse = 1;
        sensitivity = 0;
        touchpad = {
          natural_scroll = true;
        };
      };

      dwindle = {
        preserve_split = true;
      };

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        force_default_wallpaper = 0;
      };

      # Quickshell masaüstü kabuğunu başlat
      exec-once = [
        "quickshell"
        "xmarchy-theme-apply xmarchy-dark '#0f111a' '#7aa2f7'"
      ];
    };
  };
}
