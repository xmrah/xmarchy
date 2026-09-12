{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ../cli/default.nix
    ../cli/core.nix
    ../apps/browser.nix
    # Not: ai.nix (Ollama/ROCm), gaming.nix (Steam/Wine) ve impermanence 
    # canlı test ortamını şişirmemek ve çakışma yaratmamak için isteğe bağlı tutulmuştur.
  ];

  # ═══════════ Ağ ═══════════
  networking.hostName = "xmarchy";
  networking.networkmanager.enable = true;
  # mDNS ve yerel ağ keşfi
  networking.firewall.enable = true;

  # ═══════════ Çekirdek (Kernel) ═══════════
  # Zen Kernel: Masaüstü tepkiselliği ve düşük gecikme için optimize
  boot.kernelPackages = pkgs.linuxPackages_zen;

  # ═══════════ Boot ═══════════
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = lib.mkDefault 3;
  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;
  boot.kernelParams = [ "quiet" "splash" ];

  # ═══════════ Bellek & Disk Optimizasyonu (Systemd) ═══════════
  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };
  services.fstrim.enable = true;

  # ═══════════ Zaman & Hızlı Açılış Servisleri ═══════════
  services.timesyncd.enable = true;
  # Açılışta interneti bekleme, masaüstünü gecikmesiz aç
  systemd.services.NetworkManager-wait-online.enable = false;

  # ═══════════ Ses (Pipewire) ═══════════
  security.rtkit.enable = true; # Pipewire gerçek zamanlı öncelik için
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;   # PulseAudio uyumluluk
    jack.enable = true;    # JACK uyumluluk
    wireplumber.enable = true;
  };

  # ═══════════ Bluetooth ═══════════
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  # ═══════════ Hyprland (Sistem Seviyesi) ═══════════
  programs.hyprland.enable = true;

  # ═══════════ Display Manager (SDDM) ═══════════
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "where_is_my_sddm_theme"; # Sonra özelleştirilecek
  };

  # ═══════════ Güvenlik (Polkit) ═══════════
  security.polkit.enable = true;

  # ═══════════ Kullanıcı ═══════════
  users.mutableUsers = false;
  users.users.nixos = {
    isNormalUser = true;
    description = "Xmarchy User";
    initialPassword = "xmarchy"; # İlk kurulumda değiştirilmeli
    extraGroups = [
      "wheel"          # sudo
      "networkmanager" # Wi-Fi yönetimi
      "video"          # Parlaklık kontrolü
      "audio"          # Ses erişimi
      "docker"         # Docker
      "input"          # Dokunmatik/tablet
    ];
    shell = pkgs.bash;
  };

  # ═══════════ Locale / Saat / Klavye ═══════════
  time.timeZone = "Europe/Istanbul";
  i18n.defaultLocale = "tr_TR.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "tr_TR.UTF-8";
    LC_IDENTIFICATION = "tr_TR.UTF-8";
    LC_MEASUREMENT = "tr_TR.UTF-8";
    LC_MONETARY = "tr_TR.UTF-8";
    LC_NAME = "tr_TR.UTF-8";
    LC_NUMERIC = "tr_TR.UTF-8";
    LC_PAPER = "tr_TR.UTF-8";
    LC_TELEPHONE = "tr_TR.UTF-8";
    LC_TIME = "tr_TR.UTF-8";
  };
  console.keyMap = "trq";

  # ═══════════ Fontlar ═══════════
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      jetbrains-mono
      nerd-fonts.jetbrains-mono
      noto-fonts
      noto-fonts-emoji
      noto-fonts-cjk-sans
    ];
    fontconfig = {
      defaultFonts = {
        monospace = [ "JetBrainsMono Nerd Font" ];
        sansSerif = [ "Noto Sans" ];
        serif = [ "Noto Serif" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };

  # ═══════════ Temel Paketler ═══════════
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    polkit_gnome  # Polkit şifre diyalogu
  ];

  # Polkit Agent'ı Hyprland ile birlikte başlat
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "Polkit authentication agent";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  system.stateVersion = "25.05";
}
