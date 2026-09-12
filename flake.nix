{
  description = "Xmarchy - Opinionated Declarative OS (Opinionated Declarative Desktop OS)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # Quickshell resmi flake (Nixpkgs ile senkronize edilmeli - ZORUNLU)
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, impermanence, nixos-hardware, quickshell, ... }@inputs:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
  in
  {
    nixosConfigurations = {
      # Xmarchy Live ISO Hedefi
      # Komut: nix build .#nixosConfigurations.xmarchy-iso.config.system.build.isoImage
      xmarchy-iso = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"

          ./modules/os/default.nix
          ./modules/developer/arsenal.nix
          ./modules/hardware/auto.nix
          ./modules/desktop/default.nix
          ./iso/default.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.nixos = import ./modules/home/default.nix;
          }
        ];
      };
    };
  };
}
