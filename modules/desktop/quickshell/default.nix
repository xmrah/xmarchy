{ pkgs, ... }:

{
  # Xmarchy Quickshell Integration
  
  environment.systemPackages = with pkgs; [
    quickshell
    qt6.qtdeclarative
    qt6.qtwayland
  ];

  # Home Manager üzerinden Systemd User Service olarak Quickshelli başlat
  # Şimdilik ana modüle referans bırakıyoruz, ileride systemd eklenecek.
}
