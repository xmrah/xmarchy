{ pkgs, ... }:

{
  wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";
    "$altMod" = "ALT";

    bind = [
      # Temel (Hem SUPER hem ALT - Host ve VM çakışmaz)
      "$mod, Return, exec, kitty"
      "$altMod, Return, exec, kitty"
      "$mod, B, exec, brave || chromium || firefox"
      "$altMod, B, exec, brave || chromium || firefox"
      "$mod, Q, killactive,"
      "$altMod, Q, killactive,"

      # Pano Geçmişi (Cliphist + Wofi)
      "$mod, C, exec, cliphist list | wofi --dmenu -p 'Pano Geçmişi' | cliphist decode | wl-copy"
      "$altMod, C, exec, cliphist list | wofi --dmenu -p 'Pano Geçmişi' | cliphist decode | wl-copy"
      "$mod CTRL, V, exec, cliphist list | wofi --dmenu -p 'Pano Geçmişi' | cliphist decode | wl-copy"
      "$altMod CTRL, V, exec, cliphist list | wofi --dmenu -p 'Pano Geçmişi' | cliphist decode | wl-copy"
      "$mod, M, exit,"
      "$altMod, M, exit,"
      "$mod, F, togglefloating,"
      "$altMod, F, togglefloating,"
      "$mod, P, pseudo,"
      "$altMod, P, pseudo,"

      # Launcher (Quickshell IPC)
      "$mod, space, exec, quickshell ipc call launcher toggle"
      "$altMod, space, exec, quickshell ipc call launcher toggle"

      # Kilit Ekranı
      "$mod SHIFT, L, exec, quickshell ipc call lock toggle"
      "$altMod SHIFT, L, exec, quickshell ipc call lock toggle"

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

      # Odak değiştirme (Vim Tuşları)
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

      # Scratchpad (Sihirli Gizli Çalışma Alanı)
      "$mod, S, togglespecialworkspace, magic"
      "$altMod, S, togglespecialworkspace, magic"
      "$mod, Z, movetoworkspacesilent, special:magic"
      "$altMod, Z, movetoworkspacesilent, special:magic"

      # Quickshell Menü Kısayolları (SUPER ve ALT)
      "$mod CTRL, A, exec, quickshell ipc call audio toggle"
      "$altMod CTRL, A, exec, quickshell ipc call audio toggle"
      "$mod CTRL, B, exec, quickshell ipc call bluetooth toggle"
      "$altMod CTRL, B, exec, quickshell ipc call bluetooth toggle"
      "$mod CTRL, W, exec, quickshell ipc call network toggle"
      "$altMod CTRL, W, exec, quickshell ipc call network toggle"
      "$mod CTRL, D, exec, quickshell ipc call display toggle"
      "$altMod CTRL, D, exec, quickshell ipc call display toggle"
      "$mod CTRL, P, exec, quickshell ipc call power toggle"
      "$altMod CTRL, P, exec, quickshell ipc call power toggle"
      "$mod CTRL, C, exec, quickshell ipc call calendar toggle"
      "$altMod CTRL, C, exec, quickshell ipc call calendar toggle"
      "$mod CTRL, T, exec, kitty -e btop"
      "$altMod CTRL, T, exec, kitty -e btop"
      "$mod SHIFT, F, exec, dolphin || thunar || nautilus"
      "$altMod SHIFT, F, exec, dolphin || thunar || nautilus"
      "$mod SHIFT, C, exec, hyprpicker -a"
      "$altMod SHIFT, C, exec, hyprpicker -a"
      "$mod CTRL, N, exec, xmarchy-nightlight toggle"
      "$altMod CTRL, N, exec, xmarchy-nightlight toggle"
      "$mod, F1, exec, xmarchy-keybindings"
      "$mod, slash, exec, xmarchy-keybindings"
      "$altMod, F1, exec, xmarchy-keybindings"
      "$altMod, slash, exec, xmarchy-keybindings"
    ];

    # Ses & Parlaklık (Tekrarlanabilir)
    bindel = [
      ", XF86MonBrightnessUp, exec, xmarchy-bright up"
      ", XF86MonBrightnessDown, exec, xmarchy-bright down"
      ", XF86AudioRaiseVolume, exec, xmarchy-audio up"
      ", XF86AudioLowerVolume, exec, xmarchy-audio down"
    ];

    # Medya Kontrolleri (Kilitliyken de çalışabilir)
    bindl = [
      ", XF86AudioMute, exec, xmarchy-audio mute"
      ", XF86AudioPlay, exec, playerctl play-pause"
      ", XF86AudioNext, exec, playerctl next"
      ", XF86AudioPrev, exec, playerctl previous"
      ", XF86AudioStop, exec, playerctl stop"
    ];
  };
}
