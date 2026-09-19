{ pkgs, ... }:

{
  # ═══════════════════════════════════════════════════════════════
  # Xmarchy Boot Splash (Plymouth)
  # Açılışta profesyonel marka görünümü
  # ═══════════════════════════════════════════════════════════════

  boot.plymouth = {
    enable = true;
    theme = "catppuccin-mocha";
    themePackages = [
      (pkgs.catppuccin-plymouth.override { variant = "mocha"; })
    ];
  };

  # Plymouth için systemd ve udev sessiz boot parametreleri
  boot.kernelParams = [ "rd.systemd.show_status=false" "rd.udev.log_level=3" "udev.log_priority=3" ];
}
