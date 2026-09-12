{ pkgs, ... }:

{
  imports = [
    ./quickshell/default.nix
  ];

  # Hyprland Wayland masaüstü bağımlılıkları
  environment.systemPackages = with pkgs; [
    wl-clipboard
    wayland-utils
    grim
    slurp
    xdg-utils
  ];

  # XDG Desktop Portal (ekran paylaşımı, dosya seçici diyalogları)
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };
}
