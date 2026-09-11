{ pkgs, inputs, ... }:

{
  # Brutalist Home-Manager Config for Xmarchy

  home.packages = with pkgs; [
    tmux
  ];

  # Kitty (programs modülü ile tip güvenli konfigürasyon)
  programs.kitty = {
    enable = true;
    settings = {
      background = "#000000";
      foreground = "#ffffff";
      window_padding_width = 0;
      hide_window_decorations = true;
      font_family = "JetBrains Mono";
    };
  };

  # Tmux Config (Hardcore Hacker Feel, 0 gecikme)
  programs.tmux = {
    enable = true;
    clock24 = true;
    escapeTime = 0;
    keyMode = "vi";
    extraConfig = ''
      set -g status-style bg=black,fg=white
      set -g window-status-current-style bg=white,fg=black,bold
    '';
  };

  # Neovim (Sadece LSP ve Treesitter, minimal, 0 milisaniye gecikme)
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # Brutalist Hyprland (Sıfır Animasyon, Sıfır Yuvarlak Köşe)
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    settings = {
      monitor = ",preferred,auto,1";

      general = {
        gaps_in = 0;
        gaps_out = 0;
        border_size = 1;
        "col.active_border" = "rgb(FFFFFF)";
        "col.inactive_border" = "rgb(000000)";
        layout = "master";
      };

      decoration = {
        rounding = 0;
        blur = { enabled = false; };
        shadow = { enabled = false; };
      };

      animations = {
        enabled = false;
      };

      "$mod" = "SUPER";
      bind = [
        "$mod, Return, exec, kitty"
        "$mod, C, killactive,"
        "$mod, M, exit,"
        "$mod, F, togglefloating,"
        "$mod, space, exec, wofi --show drun"
      ];
    };
  };

  home.stateVersion = "25.05";
}
