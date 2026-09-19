{ config, lib, ... }:

with lib;

{
  # ═══════════════════════════════════════════════════════════════
  # Xmarchy Hotspot & Tethering TTL Bypass
  # Mobil operatörlerin kişisel erişim noktası (hotspot) kısıtlamalarını
  # ve tethering tespitini TTL değerini 65'e sabitleyerek aşar.
  # Varsayılan: Kapalı (Opt-in)
  # ═══════════════════════════════════════════════════════════════

  options.networking.tetheringBypass = {
    enable = mkEnableOption "Mobil operatör tethering/hotspot TTL bypass (TTL=65)";
  };

  config = mkIf config.networking.tetheringBypass.enable {
    boot.kernel.sysctl = {
      "net.ipv4.ip_default_ttl" = 65;
    };

    networking.firewall = {
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
  };
}
