{ pkgs, ... }:

{
  # Xmarchy: Developer Arsenal (Piller Dahil)
  # Brutalist ama iş yapmaya hazır, modern Rust tabanlı araçlarla donatılmış cephanelik.

  environment.systemPackages = with pkgs; [
    # --- Dosya ve Arama (Rust Tabanlı Modern Araçlar) ---
    eza        # ls alternatifi
    bat        # cat alternatifi (syntax highlighting)
    fzf        # Command-line fuzzy finder
    ripgrep    # grep alternatifi (çok hızlı)
    zoxide     # cd alternatifi (akıllı dizin atlama)
    fd         # find alternatifi

    # --- Git ve Docker Yönetimi ---
    lazygit    # Git için TUI
    lazydocker # Docker için TUI
    docker-compose

    # --- Sistem İzleme ---
    btop       # Modern kaynak izleme
    fastfetch  # Sistem bilgisi
    
    # --- Dil / Sürüm Yönetimi ---
    mise       # asdf/rtx alternatifi (Python, Node, Go vb. yönetimi için)
  ];

  # Docker Daemon
  virtualisation.docker.enable = true;
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };
}
