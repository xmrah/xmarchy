{ pkgs, ... }:

{
  # Brutalist Home-Manager Config for Xmarchy
  
  home.packages = with pkgs; [
    # ghostty # (Nixpkgs unstable'da yeni girmeye başladı, gerekirse kitty fallback yaparız)
    kitty
    tmux
    neovim
  ];

  # Tmux Config (Hardcore Hacker Feel, 0 gecikme)
  programs.tmux = {
    enable = true;
    clock24 = true;
    escapeTime = 0;
    keyMode = "vi";
    # Saf siyah, 0 süsleme, Brutalist estetik
    extraConfig = ''
      set -g status-style bg=black,fg=white
      set -g window-status-current-style bg=white,fg=black,bold
    '';
  };

  # Ghostty / Kitty Brutalist Ayarları
  home.file.".config/kitty/kitty.conf".text = ''
    background #000000
    foreground #ffffff
    window_padding_width 0
    hide_window_decorations yes
    font_family JetBrains Mono
  '';

  # Neovim (Sadece LSP ve Treesitter, minimal, 0 milisaniye gecikme)
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  home.stateVersion = "24.05";
}
