{ pkgs, ... }:

let
  xmarchy-install = pkgs.writeShellApplication {
    name = "xmarchy-install";
    runtimeInputs = with pkgs; [
      util-linux     # lsblk, fdisk
      coreutils
      gawk
      nix
      nixos-install-tools
      git
    ];
    text = ''
      set -euo pipefail

      echo -e "\033[1;36m"
      cat << 'BANNER'
  ╔═══════════════════════════════════════════════════╗
  ║        Xmarchy Installer — Diske Kurulum         ║
  ║     Sovereign Declarative Desktop OS              ║
  ╚═══════════════════════════════════════════════════╝
BANNER
      echo -e "\033[0m"

      # 1. Disk Seçimi
      echo -e "\033[1;33m:: Kullanılabilir Diskler:\033[0m"
      lsblk -d -p -n -o NAME,SIZE,MODEL | grep -v "loop\|sr\|ram"
      echo ""

      read -rp "Hedef disk (örn: /dev/nvme0n1 veya /dev/sda): " TARGET_DISK

      if [ ! -b "$TARGET_DISK" ]; then
        echo -e "\033[1;31mHata: '$TARGET_DISK' geçerli bir blok aygıtı değil!\033[0m"
        exit 1
      fi

      echo ""
      echo -e "\033[1;31m⚠  DİKKAT: $TARGET_DISK üzerindeki TÜM VERİLER SİLİNECEK!\033[0m"
      read -rp "Devam etmek istiyor musunuz? (evet/hayır): " CONFIRM
      if [ "$CONFIRM" != "evet" ]; then
        echo "Kurulum iptal edildi."
        exit 0
      fi

      # 2. Flake Dizinini Bul
      FLAKE_DIR=""
      if [ -d "/etc/nixos/flake.nix" ] || [ -f "/etc/nixos/flake.nix" ]; then
        FLAKE_DIR="/etc/nixos"
      elif [ -d "$HOME/Projects/xmarchy" ] && [ -f "$HOME/Projects/xmarchy/flake.nix" ]; then
        FLAKE_DIR="$HOME/Projects/xmarchy"
      else
        echo -e "\033[1;33m:: Xmarchy flake bulunamadı, GitHub'dan klonlanıyor...\033[0m"
        FLAKE_DIR="/tmp/xmarchy-install"
        git clone https://github.com/xmrah/xmarchy.git "$FLAKE_DIR" || {
          echo -e "\033[1;31mHata: Repo klonlanamadı!\033[0m"
          exit 1
        }
      fi

      echo -e "\033[1;34m:: Flake dizini: $FLAKE_DIR\033[0m"

      # 3. Disko ile Disk Biçimlendirme
      echo -e "\033[1;34m:: Disk biçimlendiriliyor (disko)...\033[0m"
      sudo nix run github:nix-community/disko -- \
        --mode disko \
        --argstr device "$TARGET_DISK" \
        "$FLAKE_DIR/modules/hardware/disko.nix" || {
          echo -e "\033[1;31mHata: Disk biçimlendirme başarısız!\033[0m"
          exit 1
        }

      # 4. NixOS Kurulumu
      echo -e "\033[1;34m:: NixOS kurulumu başlatılıyor...\033[0m"
      sudo nixos-install --flake "$FLAKE_DIR#xmarchy" --no-root-password

      echo ""
      echo -e "\033[1;32m╔═══════════════════════════════════════════════════╗\033[0m"
      echo -e "\033[1;32m║  ✓ Xmarchy başarıyla kuruldu!                    ║\033[0m"
      echo -e "\033[1;32m║                                                   ║\033[0m"
      echo -e "\033[1;32m║  Varsayılan kullanıcı: nixos                     ║\033[0m"
      echo -e "\033[1;32m║  Varsayılan şifre:     xmarchy                   ║\033[0m"
      echo -e "\033[1;32m║                                                   ║\033[0m"
      echo -e "\033[1;32m║  Lütfen ilk girişte şifrenizi değiştirin:        ║\033[0m"
      echo -e "\033[1;32m║  $ passwd                                        ║\033[0m"
      echo -e "\033[1;32m╚═══════════════════════════════════════════════════╝\033[0m"
      echo ""
      read -rp "Sistemi yeniden başlatmak ister misiniz? (evet/hayır): " REBOOT
      if [ "$REBOOT" = "evet" ]; then
        sudo reboot
      fi
    '';
  };
in {
  environment.systemPackages = [
    xmarchy-install
  ];
}
