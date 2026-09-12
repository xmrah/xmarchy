{
  description = "Xmarchy - Declarative Modern Desktop OS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = { self, nixpkgs, home-manager, impermanence, nixos-hardware, ... }@inputs:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
  in
  {
    nixosConfigurations = {
      # 1. Xmarchy Live ISO Hedefi
      # Komut: nix build .#iso
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

      # 2. Xmarchy Hızlı VM Test Hedefi (QEMU Penceresi)
      # Komut: nix run .#vm
      xmarchy-vm = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./modules/os/default.nix
          ./modules/developer/arsenal.nix
          ./modules/desktop/default.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.nixos = import ./modules/home/default.nix;
            
            # VM Yapılandırması (Host önbelleğini paylaşır, ISO gerektirmez)
            virtualisation.memorySize = 4096;
            virtualisation.cores = 4;
            virtualisation.graphics = true;
          }
        ];
      };
    };

    # Kolay kısayollar:
    # nix run .#vm  -> Sanal makineyi hemen açar
    # nix build .#iso -> ISO dosyasını paketler
    packages.${system} = {
      default = self.packages.${system}.vm;
      vm = self.nixosConfigurations.xmarchy-vm.config.system.build.vm;
      iso = self.nixosConfigurations.xmarchy-iso.config.system.build.isoImage;
    };
  };
}
