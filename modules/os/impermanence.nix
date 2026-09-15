{ config, pkgs, inputs, ... }:

{
  # =========================================================================
  # UYARI: Bu modul YALNIZCA disko ile bicimlendirilmis kurulu bir sistemde
  # kullanilmalidir. ISO veya VM hedeflerinde IMPORT ETMEYIN.
  #
  # On kosullar:
  # 1. Disk btrfs subvolume'lerle yapilandirilmis olmali:
  #    - @root   -> / (her acilista silinir)
  #    - @persist -> /persist (kalici veri)
  #    - @nix     -> /nix (store)
  # 2. flake.nix'te impermanence input'u tanimli olmali
  # =========================================================================

  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];

  # Kok dizin her acilista sifirlanir (tmpfs)
  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = [ "defaults" "size=4G" "mode=755" ];
  };

  fileSystems."/persist".neededForBoot = true;
  fileSystems."/home".neededForBoot = true;

  # Kalici disk montaji (disko tarafindan tanimlanmali)
  # fileSystems."/persist" = {
  #   device = "/dev/disk/by-label/persist";
  #   fsType = "btrfs";
  #   options = [ "subvol=@persist" "compress=zstd" "noatime" ];
  #   neededForBoot = true;
  # };

  # /persist/system: Sistem seviyesinde hayatta kalmasi gerekenler
  environment.persistence."/persist/system" = {
    hideMounts = true;
    directories = [
      "/var/lib/xmarchy"                       # Xmarchy State (Tema vb.)
      "/var/log"                               # Loglar
      "/var/lib/bluetooth"                     # Bluetooth eslesmeleri
      "/var/lib/nixos"                         # NixOS state
      "/var/lib/systemd/coredump"              # Cokme raporlari
      "/etc/NetworkManager/system-connections" # Wi-Fi sifreleri
    ];
    files = [
      "/etc/machine-id"
      { file = "/etc/ssh/ssh_host_rsa_key"; parentDirectory = { mode = "0755"; }; }
      { file = "/etc/ssh/ssh_host_rsa_key.pub"; parentDirectory = { mode = "0755"; }; }
      { file = "/etc/ssh/ssh_host_ed25519_key"; parentDirectory = { mode = "0755"; }; }
      { file = "/etc/ssh/ssh_host_ed25519_key.pub"; parentDirectory = { mode = "0755"; }; }
    ];

    # Kullanici seviyesinde kalici dizinler (Disko @home subvolume haricinde / tmpfs durumunda korur)
    users.nixos = {
      directories = [
        "Downloads"
        "Documents"
        "Pictures"
        "Projects"
        ".config/xmarchy"
        ".local/share"
        { directory = ".ssh"; mode = "0700"; }
        { directory = ".gnupg"; mode = "0700"; }
      ];
    };
  };
}
