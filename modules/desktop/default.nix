{ pkgs, ... }:

{
  imports = [
    ./quickshell/default.nix
  ];

  # NOT: Hyprland konfigürasyonu Home Manager'dan yönetiliyor (modules/home).
  # Burada sadece Wayland seviyesinde gerekli sistem bağımlılıkları tanımlı.

  environment.systemPackages = with pkgs; [
    wl-clipboard
    wayland-utils
    grim
    slurp
  ];
}
