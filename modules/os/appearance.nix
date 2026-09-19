{ pkgs, ... }:

{
  # ═══════════════════════════════════════════════════════════════
  # Xmarchy Görsel Tutarlılık Katmanı
  # GTK / Qt / İkon / İmleç Tema Birliği
  # ═══════════════════════════════════════════════════════════════

  environment.systemPackages = with pkgs; [
    # GTK Tema
    catppuccin-gtk
    # İkon Teması
    papirus-icon-theme
    # İmleç Teması
    catppuccin-cursors.mochaDark
    # Qt Tema Senkronizasyonu
    libsForQt5.qt5ct
    qt6Packages.qt6ct
    # Bildirim gönderici (CLI araçları ve betikler için)
    libnotify
  ];

  # Qt uygulamaları için tema motoru
  qt = {
    enable = true;
    platformTheme = "qt5ct";
  };
}
