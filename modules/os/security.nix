{ config, lib, pkgs, ... }:

{
  # ═══════════════════════════════════════════════════════════════
  # Xmarchy Security & Network Hardening
  # ═══════════════════════════════════════════════════════════════

  # 1. TTL Bypass Stratejisi (Hotspot & Tethering Koruma)
  # Tüm yeni paketler 65 TTL ile başlar (Katman 1 Sysctl + Katman 2 Mangle)
  boot.kernel.sysctl = {
    "net.ipv4.ip_default_ttl" = 65;
  };

  # 2. Güvenlik Duvarı (Firewall)
  networking.firewall = {
    enable = true;

    extraCommands = ''
      iptables -t mangle -A POSTROUTING -j TTL --ttl-set 65 2>/dev/null || true
      iptables -t mangle -A PREROUTING -j TTL --ttl-set 65 2>/dev/null || true
      iptables -t mangle -A FORWARD -j TTL --ttl-set 65 2>/dev/null || true
    '';

    extraStopCommands = ''
      iptables -t mangle -D POSTROUTING -j TTL --ttl-set 65 2>/dev/null || true
      iptables -t mangle -D PREROUTING -j TTL --ttl-set 65 2>/dev/null || true
      iptables -t mangle -D FORWARD -j TTL --ttl-set 65 2>/dev/null || true
    '';
  };
}
