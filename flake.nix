{
  description = "Xmarchy - Opinionated Declarative OS (Brutalist & Impermanent)";

  inputs = {
    # NixOS Unstable (En güncel paketler için)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Impermanence (tmpfs dayatması)
    impermanence.url = "github:nix-community/impermanence";
  };

  outputs = { self, nixpkgs, home-manager, impermanence, ... }@inputs:
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
          
          # Temel OS Yapılandırması ve Impermanence Dayatması
          ./modules/os/default.nix
          
          # Home Manager ve Developer Araçları (Brutalist Tema)
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
