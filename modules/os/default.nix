{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    inputs.impermanence.nixosModules.impermanence
    ./impermanence.nix
  ];

  # The Killer Feature: Impermanence (tmpfs dayatması)
  # Not: Live ISO zaten RAM üzerinde çalışır. Kurulum sonrasında disk üzerindeki 
  # kök dizini tmpfs olarak ayarlayacak mantık budur.
  # fileSystems."/" = {
  #   device = "none";
  #   fsType = "tmpfs";
  #   options = [ "defaults" "size=4G" "mode=755" ];
  # };

  networking.hostName = "xmarchy";
  
  # Xmarchy Brutal Boot: 0 saniye gecikme, logolar yok.
  boot.loader.timeout = lib.mkForce 0;
  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;

  # Temel Paketler (Kurulumsuz, anında hazır araçlar)
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    fastfetch
  ];

  # Sistem versiyonu
  system.stateVersion = "24.05";
}
