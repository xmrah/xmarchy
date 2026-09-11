{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    inputs.impermanence.nixosModules.impermanence
    ./impermanence.nix
  ];

  networking.hostName = "xmarchy";

  # Xmarchy Brutal Boot: 0 saniye gecikme, logolar yok.
  boot.loader.timeout = lib.mkForce 0;
  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;

  # Temel Paketler (Arsenal'de olmayanlar)
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
  ];

  system.stateVersion = "25.05";
}
