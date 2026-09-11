{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ../cli/default.nix
    ../cli/core.nix
    ../apps/browser.nix
    ../apps/ai.nix
    ../apps/gaming.nix
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
