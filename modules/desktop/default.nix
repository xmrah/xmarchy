{ pkgs, ... }:

{
  # Xmarchy Brutalist Desktop (Saf Hyprland)
  
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Brutalist Desktop Bağımlılıkları
  environment.systemPackages = with pkgs; [
    wl-clipboard
    wayland-utils
  ];
}
