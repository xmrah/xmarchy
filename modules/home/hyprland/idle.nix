{ pkgs, ... }:

{
  # ═══════════════════════════════════════════════════════════════
  # Hypridle — Boşta Kalma Zamanlayıcısı
  # Hyprlock — Native Kilit Ekranı
  # ═══════════════════════════════════════════════════════════════

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };
      listener = [
        # 5 dakika → Ekran parlaklığını düşür
        {
          timeout = 300;
          on-timeout = "brightnessctl -s set 10";
          on-resume = "brightnessctl -r";
        }
        # 10 dakika → Ekranı kilitle
        {
          timeout = 600;
          on-timeout = "loginctl lock-session";
        }
        # 15 dakika → Ekranı kapat
        {
          timeout = 900;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
        # 30 dakika → Uyku moduna al
        {
          timeout = 1800;
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };

  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = false;
        grace = 5;
        hide_cursor = true;
      };

      background = [
        {
          path = "screenshot";
          blur_passes = 3;
          blur_size = 8;
          noise = 1.17e-2;
          contrast = 0.8916;
          brightness = 0.6;
          vibrancy = 0.1696;
        }
      ];

      input-field = [
        {
          size = "250, 50";
          outline_thickness = 2;
          dots_size = 0.26;
          dots_spacing = 0.15;
          dots_center = true;
          dots_rounding = -1;
          outer_color = "rgb(313244)";
          inner_color = "rgb(1e1e2e)";
          font_color = "rgb(cdd6f4)";
          fade_on_empty = true;
          fade_timeout = 1000;
          placeholder_text = "<i>Şifre...</i>";
          hide_input = false;
          rounding = 12;
          check_color = "rgb(a6e3a1)";
          fail_color = "rgb(f38ba8)";
          fail_text = "<i>Hatalı şifre ($ATTEMPTS)</i>";
          position = "0, -80";
          halign = "center";
          valign = "center";
        }
      ];

      label = [
        # Saat
        {
          text = "cmd[update:1000] echo \"$(date +%H:%M)\"";
          color = "rgb(cdd6f4)";
          font_size = 72;
          font_family = "JetBrains Mono Nerd Font";
          position = "0, 120";
          halign = "center";
          valign = "center";
        }
        # Tarih
        {
          text = "cmd[update:60000] echo \"$(date '+%A, %d %B %Y')\"";
          color = "rgb(a6adc8)";
          font_size = 16;
          font_family = "JetBrains Mono Nerd Font";
          position = "0, 50";
          halign = "center";
          valign = "center";
        }
        # Kullanıcı
        {
          text = "  $USER";
          color = "rgb(89b4fa)";
          font_size = 14;
          font_family = "JetBrains Mono Nerd Font";
          position = "0, -30";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };
}
