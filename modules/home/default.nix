{ pkgs, inputs, ... }:

{
  home.packages = with pkgs; [
    tmux
    wofi        # Fallback launcher
    wl-clipboard
  ];

  # Kitty (Brutalist Terminal)
  programs.kitty = {
    enable = true;
    settings = {
      background = "#000000";
      foreground = "#ffffff";
      cursor = "#ffffff";
      cursor_text_color = "#000000";
      selection_background = "#ffffff";
      selection_foreground = "#000000";
      window_padding_width = 0;
      hide_window_decorations = true;
      font_family = "JetBrains Mono";
      font_size = 11;
      confirm_os_window_close = 0;
      enable_audio_bell = false;
    };
  };

  # Starship Prompt (Brutalist — sadece dizin ve git)
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "$directory$git_branch$git_status$character";
      character = {
        success_symbol = "[>](bold white)";
        error_symbol = "[x](bold red)";
      };
      directory = {
        style = "bold white";
        truncation_length = 2;
      };
      git_branch = {
        style = "bold white";
        format = " [$branch]($style)";
      };
      git_status = {
        style = "bold white";
      };
    };
  };

  # btop (Brutalist Sistem İzleme)
  programs.btop = {
    enable = true;
    settings = {
      color_theme = "TTY";
      theme_background = false;
      vim_keys = true;
      rounded_corners = false;
    };
  };

  # Tmux (0 Gecikme, Brutalist)
  programs.tmux = {
    enable = true;
    clock24 = true;
    escapeTime = 0;
    keyMode = "vi";
    terminal = "screen-256color";
    extraConfig = ''
      set -g status-style bg=black,fg=white
      set -g window-status-current-style bg=white,fg=black,bold
      set -g pane-border-style fg=white
      set -g pane-active-border-style fg=white
      set -g message-style bg=black,fg=white
    '';
  };

  # Neovim (Minimal, 0ms)
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # Hyprland (Brutalist WM)
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
        "col.inactive_border" = "rgb(333333)";
        layout = "master";
      };

      decoration = {
        rounding = 0;
        blur = { enabled = false; };
        shadow = { enabled = false; };
      };

      animations = { enabled = false; };

      input = {
        kb_layout = "tr";
        follow_mouse = 1;
        sensitivity = 0;
      };

      master = {
        new_status = "slave";
      };

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        force_default_wallpaper = 0;
      };

      # Quickshell otomatik başlatma
      exec-once = [
        "quickshell"
      ];

      "$mod" = "SUPER";
      bind = [
        # Temel
        "$mod, Return, exec, kitty"
        "$mod, C, killactive,"
        "$mod, M, exit,"
        "$mod, F, togglefloating,"

        # Launcher (Quickshell IPC ile)
        "$mod, space, exec, quickshell ipc call default launcher toggle"

        # Kilit Ekranı
        "$mod SHIFT, L, exec, quickshell ipc call default lock toggle"

        # Workspace geçişleri
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"

        # Pencere taşıma
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"

        # Odak değiştirme
        "$mod, H, movefocus, l"
        "$mod, L, movefocus, r"
        "$mod, K, movefocus, u"
        "$mod, J, movefocus, d"

        # Ekran görüntüsü
        ", Print, exec, grim - | wl-copy"
        "$mod, Print, exec, grim -g "$(slurp)" - | wl-copy"
      ];

      # Ses kontrolleri (OSD ile)
      bindel = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ];

      bindl = [
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ];
    };
  };

  home.stateVersion = "25.05";
}
