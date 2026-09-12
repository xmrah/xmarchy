{ pkgs, ... }:

{
  # Quickshell: Resmi Nixpkgs ikili paketi (cache.nixos.org'dan hazır, derleme gerektirmez)
  environment.systemPackages = [
    pkgs.quickshell
  ];
}
