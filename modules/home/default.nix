{ pkgs, inputs, ... }:

{
  imports = [
    ../apps/webapps.nix
    ./hyprland/default.nix
  ];

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

  # ═══════════ Wofi Teması ve Konfigürasyonu ═══════════
  xdg.configFile."wofi/config".text = ''
    width=520
    height=400
    location=center
    show=drun
    prompt=  Ara...
    filter_rate=100
    allow_markup=true
    no_actions=true
    halign=fill
    orientation=vertical
    content_halign=fill
    insensitive=true
    allow_images=true
    image_size=24
    gtk_dark=true
    hide_scroll=true
    stylesheet=current-theme.css
  '';

  # Varsayılan Wofi Stili (current-theme.css ilk kurulumda mevcut değilse)
  xdg.configFile."wofi/style.css".text = ''
    * {
        font-family: "JetBrains Mono Nerd Font", monospace;
        font-size:   13px;
        outline:     none;
        border:      none;
        box-shadow:  none;
    }

    window {
        background-color: rgba(15, 17, 26, 0.85);
        border:           1px solid rgba(122, 162, 247, 0.4);
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
        background-color: rgba(26, 28, 43, 0.9);
        color:            #c0caf5;
        border:           1px solid rgba(122, 162, 247, 0.5);
        border-radius:    8px;
        padding:          8px 14px;
        margin-bottom:    8px;
        caret-color:      #7aa2f7;
    }

    #input:focus {
        border-color: rgba(122, 162, 247, 0.9);
        background-color: rgba(26, 28, 43, 1.0);
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
        background-color: rgba(122, 162, 247, 0.2);
        color:            #c0caf5;
        border-left:      3px solid #7aa2f7;
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
        background-color: rgba(122, 162, 247, 0.3);
        border-radius:    4px;
        min-height:       30px;
    }

    scrollbar slider:hover {
        background-color: rgba(122, 162, 247, 0.6);
    }
  '';

  # ═══════════ Pano Geçmişi (Cliphist) Daemon Servisleri ═══════════
  systemd.user.services.cliphist = {
    Unit = {
      Description = "Clipboard history daemon (cliphist)";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
      ConditionEnvironment = "WAYLAND_DISPLAY";
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --watch ${pkgs.cliphist}/bin/cliphist store";
      Restart = "on-failure";
      RestartSec = "3s";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  systemd.user.services.cliphist-images = {
    Unit = {
      Description = "Clipboard image history daemon (cliphist)";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
      ConditionEnvironment = "WAYLAND_DISPLAY";
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --type image --watch ${pkgs.cliphist}/bin/cliphist store";
      Restart = "on-failure";
      RestartSec = "3s";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  # ═══════════ GTK & Görünüm Yapılandırması ═══════════
  gtk = {
    enable = true;
    theme = {
      name = "catppuccin-mocha-blue-standard";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "blue" ];
        variant = "mocha";
      };
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = "Catppuccin-Mocha-Dark-Cursors";
      package = pkgs.catppuccin-cursors.mochaDark;
      size = 24;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.theme = null;
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  # İmleç (Cursor) X11 & Wayland Senkronizasyonu
  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    x11.enable = true;
    name = "Catppuccin-Mocha-Dark-Cursors";
    package = pkgs.catppuccin-cursors.mochaDark;
    size = 24;
  };

  # ═══════════ XDG MIME Varsayılan Uygulamalar ═══════════
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "chromium-browser.desktop";
      "x-scheme-handler/http" = "chromium-browser.desktop";
      "x-scheme-handler/https" = "chromium-browser.desktop";
      "x-scheme-handler/about" = "chromium-browser.desktop";
      "x-scheme-handler/unknown" = "chromium-browser.desktop";
      "image/png" = "imv.desktop";
      "image/jpeg" = "imv.desktop";
      "image/gif" = "imv.desktop";
      "image/webp" = "imv.desktop";
      "video/mp4" = "mpv.desktop";
      "video/mkv" = "mpv.desktop";
      "video/webm" = "mpv.desktop";
      "audio/mpeg" = "mpv.desktop";
      "audio/flac" = "mpv.desktop";
      "application/pdf" = "chromium-browser.desktop";
      "inode/directory" = "thunar.desktop";
    };
  };

  home.stateVersion = "25.05";
}
