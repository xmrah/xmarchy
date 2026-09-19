{ pkgs, ... }:

{
  # ═══════════════════════════════════════════════════════════════
  # Xmarchy Idle & Güç Yönetimi
  # hypridle: Boşta kalma zamanlayıcısı
  # Kilit Ekranı: Quickshell (Lock.qml) tarafından yönetilir
  # ═══════════════════════════════════════════════════════════════

  environment.systemPackages = with pkgs; [
    hypridle
    brightnessctl
  ];
}
