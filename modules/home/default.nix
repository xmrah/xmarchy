{ pkgs, inputs, ... }:

{
  home.packages = with pkgs; [
    wl-clipboard
  ];

  # Kitty Terminal
  programs.kitty = {
    enable = true;
    settings = {
      background = "#000000";
      foreground = "#ffffff";
      cursor = "#ffffff";
      cursor_text_color = "#000000";
      selection_background = "#ffffff";
      selection_foreground = "#000000";
      window_padding_width = 4;
      hide_window_decorations = true;
      font_family = "JetBrainsMono Nerd Font";
      font_size = 11;
      confirm_os_window_close = 0;
      enable_audio_bell = false;
      background_opacity = "0.92";
    };
  };

  # Starship Prompt
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "$directory$git_branch$git_status$character";
      character = {
        success_symbol = "[❯](bold cyan)";
        error_symbol = "[❯](bold red)";
      };
      directory = {
        style = "bold cyan";
        truncation_length = 2;
      };
      git_branch = {
        style = "bold purple";
        format = " [$branch]($style)";
      };
      git_status = {
        style = "bold yellow";
      };
    };
  };

  # btop Sistem İzleme
  programs.btop = {
    enable = true;
    settings = {
      vim_keys = true;
      rounded_corners = true;
    };
  };

  # Tmux
  programs.tmux = {
    enable = true;
    clock24 = true;
    escapeTime = 0;
    keyMode = "vi";
    terminal = "screen-256color";
    extraConfig = ''
      set -g status-style bg=default,fg=white
      set -g window-status-current-style bg=cyan,fg=black,bold
      set -g pane-border-style fg=#444444
      set -g pane-active-border-style fg=cyan
      set -g message-style bg=black,fg=cyan
    '';
  };

  # Neovim
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # Hyprland Window Manager
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    settings = {
      monitor = ",preferred,auto,1";

      general = {
        gaps_in = 4;
        gaps_out = 8;
        border_size = 2;
        "col.active_border" = "rgb(88C0D0) rgb(81A1C1) 45deg";
        "col.inactive_border" = "rgb(3B4252)";
        layout = "dwindle";
      };

      decoration = {
        rounding = 8;
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
        pseudotile = true;
        preserve_split = true;
      };

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        force_default_wallpaper = 0;
      };

      # Quickshell ve Polkit otomatik başlatma
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
        "$mod, P, pseudo,"

        # Launcher (Quickshell IPC)
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
        ", Print, exec, xmarchy-capture screen"
        "$mod, Print, exec, xmarchy-capture region"
      ];

      # Ses kontrolleri
      bindel = [
        ", XF86MonBrightnessUp, exec, xmarchy-bright up"
        ", XF86MonBrightnessDown, exec, xmarchy-bright down"
        ", XF86AudioRaiseVolume, exec, xmarchy-audio up"
        ", XF86AudioLowerVolume, exec, xmarchy-audio down"
      ];

      bindl = [
        ", XF86AudioMute, exec, xmarchy-audio mute"
      ];
    };
  };

  home.stateVersion = "25.05";
}
