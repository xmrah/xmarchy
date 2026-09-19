{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ../cli/default.nix
    ../cli/core.nix
    ../apps/browser.nix
    ./security.nix
    ./idle.nix
    ./appearance.nix
    ./boot-splash.nix
    # Not: ai.nix (Ollama/ROCm), gaming.nix (Steam/Wine) ve impermanence 
    # canlı test ortamını şişirmemek ve çakışma yaratmamak için isteğe bağlı tutulmuştur.
  ];

  # ═══════════ Paket İzinleri ═══════════
  nixpkgs.config.allowUnfree = true;

  # ═══════════ Wayland & Grafik Ortam Değişkenleri ═══════════
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    # Hyprland 0.56 (Aquamarine) VM Uyumluluk Kalkanı:
    AQ_DRM_DEVICES = "/dev/dri/card0";
    AQ_NO_ATOMIC = "1";    # QEMU VirtIO GPU için legacy DRM arayüzünü zorlar
    AQ_NO_MODIFIERS = "1"; # DRM modifiers olmadan düz bellek alanı kullanır
    WLR_NO_HARDWARE_CURSORS = "1";
    WLR_RENDERER_ALLOW_SOFTWARE = "1";
  };

  # ═══════════ Ağ ═══════════
  networking.hostName = "xmarchy";
  networking.networkmanager.enable = true;
  # mDNS ve yerel ağ keşfi
  networking.firewall.enable = true;

  # ═══════════ Çekirdek (Kernel) & Ağ Optimizasyonu ═══════════
  # Zen Kernel: Masaüstü tepkiselliği ve düşük gecikme için optimize
  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.kernelModules = [ "tcp_bbr" ];
  boot.kernelParams = [ "quiet" "splash" "panic=10" "oops=panic" ];

  # Kernel Sysctl: TCP BBR, CAKE kuyruğu, bellek barajı ve Magic SysRq
  boot.kernel.sysctl = {
    "vm.max_map_count" = 2097152;
    "net.core.default_qdisc" = "cake";
    "net.ipv4.tcp_congestion_control" = "bbr";
    "kernel.sysrq" = 1;
    "vm.swappiness" = 100;
  };

  # ═══════════ Boot ═══════════
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = lib.mkDefault 3;
  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;

  # ═══════════ Bellek & Disk Optimizasyonu (Systemd) ═══════════
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 100;
    priority = 10;
  };
  services.fstrim.enable = true;

  # ═══════════ Zaman & Hızlı Açılış Servisleri ═══════════
  services.timesyncd.enable = lib.mkDefault true;
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

  # ═══════════ Güç & Pil Yönetimi (UPower + Power Profiles) ═══════════
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  # Laptop Kapak (Lid) Yönetimi
  services.logind.settings = {
    Login = {
      HandleLidSwitch = "suspend";
      HandleLidSwitchExternalPower = "lock";
      HandleLidSwitchDocked = "ignore";
    };
  };

  # ═══════════ Dosya Yöneticisi Entegrasyonu (Thunar/GVFS) ═══════════
  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
      thunar-archive-plugin
      thunar-volman
    ];
  };
  services.gvfs.enable = true;      # Çöp kutusu, harici disk bağlama, MTP
  services.tumbler.enable = true;   # Küçük resim (thumbnail) önizleme servisi

  # ═══════════ Hyprland (Sistem Seviyesi) ═══════════
  programs.hyprland = {
    enable = true;
    withUWSM = false; # Doğrudan saf Hyprland ikili oturumu (UWSM bağımlılığı ve çöküşünü engeller)
    xwayland.enable = true;
  };

  # SDDM Varsayılan Oturum & Otomatik Giriş
  services.displayManager.defaultSession = "hyprland";
  services.displayManager.autoLogin = {
    enable = true;
    user = "nixos";
  };
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # ═══════════ Güvenlik (Polkit) ═══════════
  security.polkit.enable = true;
  # ═══════════ Quickshell Lock Ekranı PAM Servisi ═══════════
  security.pam.services.quickshell-lock = {};

  # ═══════════ Kullanıcı ═══════════
  users.mutableUsers = true; # Kullanicinin sifresini degistirebilmesi icin
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
      noto-fonts-color-emoji
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
    file-roller   # Arşiv yöneticisi (zip/tar/rar vb.)
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
