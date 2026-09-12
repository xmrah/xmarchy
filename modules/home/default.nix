{ pkgs, inputs, ... }:

{
  home.packages = with pkgs; [
    wl-clipboard
  ];

  # Quickshell konfigürasyonunu ~/.config/quickshell altına bağla
  xdg.configFile."quickshell".source = ../desktop/quickshell;

  # Kitty Terminal (Catppuccin Mocha Sleek Palette)
  programs.kitty = {
    enable = true;
    settings = {
      background = "#1e1e2e";
      foreground = "#cdd6f4";
      cursor = "#cba6f7";
      cursor_text_color = "#11111b";
      selection_background = "#cba6f7";
      selection_foreground = "#11111b";
      window_padding_width = 12;
      hide_window_decorations = true;
      font_family = "JetBrainsMono Nerd Font";
      font_size = 11;
      confirm_os_window_close = 0;
      enable_audio_bell = false;
      background_opacity = "0.94";
      # Modern Catppuccin Renkleri
      color0 = "#45475a";
      color8 = "#585b70";
      color1 = "#f38ba8";
      color9 = "#f38ba8";
      color2 = "#a6e3a1";
      color10 = "#a6e3a1";
      color3 = "#f9e2af";
      color11 = "#f9e2af";
      color4 = "#89b4fa";
      color12 = "#89b4fa";
      color5 = "#f5c2e7";
      color13 = "#f5c2e7";
      color6 = "#94e2d5";
      color14 = "#94e2d5";
      color7 = "#bac2de";
      color15 = "#a6adc8";
    };
  };

  # Bash & Fastfetch Entegrasyonu
  programs.bash = {
    enable = true;
    enableCompletion = true;
    initExtra = ''
      # Terminal her açıldığında estetik Xmarchy karşılama ekranı
      if [[ $- == *i* ]]; then
        fastfetch --logo-type small --structure title:separator:os:kernel:uptime:packages:shell:wm:terminal:cpu:memory:break:colors 2>/dev/null || true
      fi
    '';
    shellAliases = {
      ll = "ls -la --color=auto";
      rebuild = "sudo nixos-rebuild switch --flake .";
      theme = "xmarchy-theme-apply";
      fetch = "fastfetch";
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
    withRuby = false;
    withPython3 = false;
  };

  # Hyprland Window Manager
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
      ];

      "$mod" = "SUPER";
      "$altMod" = "ALT";
      bind = [
        # Temel (Hem SUPER hem ALT - Host ve VM çakışmaz)
        "$mod, Return, exec, kitty"
        "$altMod, Return, exec, kitty"
        "$mod, B, exec, brave || chromium || firefox"
        "$altMod, B, exec, brave || chromium || firefox"
        "$mod, C, killactive,"
        "$altMod, C, killactive,"
        "$mod, Q, killactive,"
        "$altMod, Q, killactive,"
        "$mod, M, exit,"
        "$altMod, M, exit,"
        "$mod, F, togglefloating,"
        "$altMod, F, togglefloating,"
        "$mod, P, pseudo,"
        "$altMod, P, pseudo,"

        # Launcher (Quickshell IPC)
        "$mod, space, exec, quickshell ipc call default launcher toggle"
        "$altMod, space, exec, quickshell ipc call default launcher toggle"

        # Kilit Ekranı
        "$mod SHIFT, L, exec, quickshell ipc call default lock toggle"
        "$altMod SHIFT, L, exec, quickshell ipc call default lock toggle"

        # Workspace geçişleri (SUPER)
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"

        # Workspace geçişleri (ALT - Sanal Makinede Doğrudan Çalışır)
        "$altMod, 1, workspace, 1"
        "$altMod, 2, workspace, 2"
        "$altMod, 3, workspace, 3"
        "$altMod, 4, workspace, 4"
        "$altMod, 5, workspace, 5"
        "$altMod, 6, workspace, 6"
        "$altMod, 7, workspace, 7"
        "$altMod, 8, workspace, 8"
        "$altMod, 9, workspace, 9"

        # Pencere taşıma (SUPER)
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"

        # Pencere taşıma (ALT)
        "$altMod SHIFT, 1, movetoworkspace, 1"
        "$altMod SHIFT, 2, movetoworkspace, 2"
        "$altMod SHIFT, 3, movetoworkspace, 3"
        "$altMod SHIFT, 4, movetoworkspace, 4"
        "$altMod SHIFT, 5, movetoworkspace, 5"
        "$altMod SHIFT, 6, movetoworkspace, 6"
        "$altMod SHIFT, 7, movetoworkspace, 7"
        "$altMod SHIFT, 8, movetoworkspace, 8"
        "$altMod SHIFT, 9, movetoworkspace, 9"

        # Odak değiştirme
        "$mod, H, movefocus, l"
        "$altMod, H, movefocus, l"
        "$mod, L, movefocus, r"
        "$altMod, L, movefocus, r"
        "$mod, K, movefocus, u"
        "$altMod, K, movefocus, u"
        "$mod, J, movefocus, d"
        "$altMod, J, movefocus, d"

        # Ekran görüntüsü
        ", Print, exec, xmarchy-capture screen"
        "$mod, Print, exec, xmarchy-capture region"
        "$altMod, Print, exec, xmarchy-capture region"
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
