{ pkgs, ... }:

{
  # ═══════════════════════════════════════════════════════════════
  # Hypridle — Boşta Kalma Zamanlayıcısı
  # Kilit Ekranı: Quickshell Native WlSessionLock (Lock.qml)
  # ═══════════════════════════════════════════════════════════════

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "quickshell ipc call lock lock";
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
        # 10 dakika → Quickshell kilit ekranını tetikle (Idempotent lock)
        {
          timeout = 600;
          on-timeout = "quickshell ipc call lock lock";
        }
        # 15 dakika → Ekranı kapat (DPMS tasarruf modu)
        {
          timeout = 900;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
        # 30 dakika → Uyku moduna al (Suspend)
        {
          timeout = 1800;
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };
}
