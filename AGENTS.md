# Xmarchy — AI Agent Kuralları ve Mimari Standartları

Bu belge; Antigravity, Claude, Cline, Copilot ve Xmarchy üzerinde çalışan tüm yapay zeka ajanları için **bağlayıcı mimari anayasadır**. Her oturumda bu kurallar baştan kabul edilmiş sayılır.

---

## 1. Proje Kimliği & Felsefesi
- **Xmarchy**, basit bir Hyprland dotfiles deposu değil; **bağımsız, deklaratif ve egemen bir Linux Masaüstü İşletim Sistemidir**.
- **Temel Taşlar:** NixOS Unstable + Flakes, Linux Zen Kernel, Hyprland (Wayland), Quickshell QML masaüstü kabuğu.
- **Sadelik ve Bütünlük:** Aynı işi yapan iki farklı araç sisteme eklenemez. Sistem kendi masaüstü kabuğuna (Quickshell) güvenmelidir.

---

## 2. Quickshell & Masaüstü Kabuk Standartları
- **Tek Kilit Ekranı Prensibi:**
  - Kilit ekranı Quickshell'in yerel `WlSessionLock` bileşenidir (`modules/desktop/quickshell/plugins/lock/Lock.qml`).
  - Harici kilit programları (`hyprlock`, `swaylock`) sisteme EKLENEMEZ.
  - Manuel kilit: `SUPER + SHIFT + L` -> `quickshell ipc call lock toggle`
  - Boşta kalma (Idle) kilidi: `hypridle` timeout -> `quickshell ipc call lock toggle`
  - Uyku öncesi kilit: `before_sleep_cmd = "loginctl lock-session"` -> `quickshell ipc call lock toggle`
- **Tek Bildirim Sunucusu:**
  - Bildirimler Quickshell `NotificationServer` tarafından yönetilir. Harici `mako` veya `dunst` kurulmaz; sadece CLI betiklerinin konuşabilmesi için `libnotify` paketi sağlanır.
- **Dinamik Tema Entegrasyonu:**
  - QML dosyalarında renkler hardcode edilmez; `shell.theme.*` bağlamları kullanılır.

---

## 3. NixOS & Donanım / Disko Kuralları (HAYATİ)
- **Disk Cihazı Asla Hardcode Edilemez:**
  - `modules/hardware/disko.nix` modülü her zaman parametrik olmalıdır:
    `{ device ? "/dev/nvme0n1", ... }: { disko.devices.disk.main.device = device; ... }`
  - Kurulum scriptinde (`xmarchy-install`) disko çalıştırılırken `--argstr device "$TARGET_DISK"` argümanı zorunludur.
  - Kullanıcının seçtiği disk haricinde varsayılan bir diski formatlamak **felaket seviyesinde bir hatadır**.
- **Git Staging Kuralı:**
  - Nix Flake yapısında yeni oluşturulan dosyalar `git add` yapılmadan Nix tarafından GÖRÜLMEZ. Her yeni dosyadan sonra `git add` çalıştırılmalıdır.

---

## 4. Standart Test & Doğrulama İş Akışı (Canonical Workflow)
Ajanlar kullanıcıya alternatif seçenekler sunarak kafa karıştırmaz. Test için **tek ve kesin standart** uygulanır:

1. **Sözdizimi ve Tip Kontrolü:**
   ```bash
   nix flake check --no-build
   ```
2. **VM Derleme ve Çalıştırma (Tek Komut):**
   ```bash
   nix build .#vm -o result-vm && ./result-vm/bin/run-xmarchy-vm
   ```
- `nix build` adımı atlanıp doğrudan `./result-vm/...` çalıştırılamaz (eski derlemeyi açar).
- "Çalışıyor" demeden önce yukarıdaki derleme testi kesinlikle geçmelidir.

---

## 5. Güvenlik ve Ağ Dürüstlüğü
- **Açık ve Dürüst İsimlendirme:**
  - Mobil operatörlerin hotspot / tethering tespitini aşmak için TTL değerini 65'e sabitleyen kurallar "security" modülüne gizlenemez.
  - Bu tür kurallar `modules/os/tethering-bypass.nix` altında ve `networking.tetheringBypass.enable` seçeneğiyle **varsayılan olarak kapalı (opt-in)** tutulur.
  - `modules/os/security.nix` sadece gerçek çekirdek sıkılaştırması (KASLR, SYN cookies, ptrace scope, rp_filter, firewall) içerir.

---

## 6. CLI Araçları Standartları
- Tüm yardımcı komutlar `pkgs.writeShellApplication` ile yazılmalıdır.
- Betiklerde `runtimeInputs` eksiksiz tanımlanmalı ve `set -euo pipefail` korunmalıdır.
- Sistem güncelleme komutu daima spesifik hedefi işaret etmelidir:
  `sudo nixos-rebuild switch --flake "$FLAKE_DIR#xmarchy"`
