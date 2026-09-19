{ pkgs, ... }:

{
  # ═══════════════════════════════════════════════════════════════
  # Xmarchy Idle & Ekran Kilidi Yönetimi
  # hypridle: Boşta kalma zamanlayıcısı
  # hyprlock: Hyprland native kilit ekranı
  # ═══════════════════════════════════════════════════════════════

  environment.systemPackages = with pkgs; [
    hypridle
    hyprlock
    brightnessctl
  ];

  # PAM servisi: hyprlock'un şifre doğrulaması yapabilmesi için
  security.pam.services.hyprlock = {};
}
