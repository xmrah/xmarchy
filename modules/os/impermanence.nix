{ config, pkgs, ... }:

{
  # Xmarchy: Kök Dizin Yok Etme (Erase Your Darlings)
  # Her açılışta sistem sıfırlanır. Yalnızca /persist içindekiler hayatta kalır.

  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = [ "defaults" "size=4G" "mode=755" ];
  };

  # /persist/system: Sistem seviyesinde hayatta kalması gerekenler
  environment.persistence."/persist/system" = {
    hideMounts = true;
    directories = [
      "/var/log"                               # Logları tut, sorun çıkarsa okuruz
      "/var/lib/bluetooth"                     # Kulaklık eşleşmeleri silinmesin
      "/var/lib/nixos"                         # NixOS state
      "/var/lib/systemd/coredump"              # Çökme raporları
      "/etc/NetworkManager/system-connections" # Wi-Fi şifreleri
    ];
    files = [
      "/etc/machine-id"                        # Sistem kimliği değişmesin
      # SSH anahtarlarının kalıcılığı çok kritik!
      { file = "/etc/ssh/ssh_host_rsa_key"; parentDirectory = { mode = "0755"; }; }
      { file = "/etc/ssh/ssh_host_rsa_key.pub"; parentDirectory = { mode = "0755"; }; }
      { file = "/etc/ssh/ssh_host_ed25519_key"; parentDirectory = { mode = "0755"; }; }
      { file = "/etc/ssh/ssh_host_ed25519_key.pub"; parentDirectory = { mode = "0755"; }; }
    ];
  };
}
