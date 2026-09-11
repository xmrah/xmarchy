{ pkgs, inputs, ... }:

{
  # Quickshell: Resmi flake'ten gelen paket (Nixpkgs senkronizasyonu zorunlu)
  environment.systemPackages = [
    inputs.quickshell.packages.${pkgs.system}.default
  ];
}
