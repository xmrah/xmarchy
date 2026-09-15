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
    wf-recorder
    tesseract5
    zbar
    qrencode
    mpv
    easyeffects
    pavucontrol
    hyprpicker
    playerctl
  ];

  # XDG Desktop Portal (ekran paylaşımı, dosya seçici diyalogları)
  xdg.portal = {
    enable = true;
    extraPortals = [ 
      pkgs.xdg-desktop-portal-hyprland 
      pkgs.xdg-desktop-portal-gtk
    ];
    config.common.default = "*";
  };
}
