{ pkgs, ... }:

{
  # Steam ve Lutris gibi donanım ivmesi gerektiren araçlar
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  environment.systemPackages = with pkgs; [
    lutris
    heroic
    retroarchFull
    wineWowPackages.waylandFull
    mangohud
  ];
}
