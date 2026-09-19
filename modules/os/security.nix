{ config, lib, pkgs, ... }:

{
  # ═══════════════════════════════════════════════════════════════
  # Xmarchy Security Hardening
  # Gerçek çekirdek, ağ ve bellek güvenlik sıkılaştırması
  # ═══════════════════════════════════════════════════════════════

  # Güvenlik Duvarı
  networking.firewall.enable = true;

  # Polkit & Yetkilendirme Güvenliği
  security.polkit.enable = true;
  security.sudo.wheelNeedsPassword = true;

  # Çekirdek & Ağ Güvenlik Parametreleri (Sysctl Hardening)
  boot.kernel.sysctl = {
    # SYN flood DoS saldırılarına karşı koruma
    "net.ipv4.tcp_syncookies" = 1;

    # ICMP redirect paketlerini yok say (Man-in-the-Middle koruması)
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.default.accept_redirects" = 0;
    "net.ipv6.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.default.accept_redirects" = 0;

    # IP Spoofing koruması (Reverse Path Filtering)
    "net.ipv4.conf.all.rp_filter" = 1;
    "net.ipv4.conf.default.rp_filter" = 1;

    # Bellek enjeksiyonu ve yetkisiz ptrace işlemlerini engelle
    "kernel.yama.ptrace_scope" = 1;

    # Çekirdek adres sızıntılarını kısıtla (KASLR koruması)
    "kernel.kptr_restrict" = 1;
    "kernel.dmesg_restrict" = 1;
  };
}
