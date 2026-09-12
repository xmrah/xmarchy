# Xmarchy

**Opinionated Declarative Desktop OS** — NixOS Flakes üzerine kurulu, kullanıma hazır masaüstü işletim sistemi.

## Özellikler

- **NixOS Flakes** — Tekrarlanabilir, deklaratif sistem yapılandırması
- **Impermanence** — Her açılışta sıfırlanan temiz sistem (kalıcı veriler `/persist` altında)
- **Quickshell** — Wayland-native masaüstü kabuğu (Bar, OSD, Bildirimler, Tema Motoru, Uygulama Başlatıcı, Kilit Ekranı)
- **Hyprland** — Modern tiling Wayland compositor (blur, animasyonlar, gölgeler)
- **Nix-Native CLI Suite** — `xmarchy-audio`, `xmarchy-bright`, `xmarchy-capture`, `xmarchy-power`, `xmarchy-theme-apply`
- **Dinamik Tema Motoru** — Sağ tıkla tema değiştir, Hyprland + Terminal + Bar anında güncellenir
- **Pipewire** — Düşük gecikmeli ses altyapısı (ALSA + PulseAudio + JACK uyumlu)
- **Modüler Uygulama Ekosistemi** — AI, Gaming, Browser modülleri ayrı Nix dosyalarında

## ISO İndirme

```bash
nix build .#nixosConfigurations.xmarchy-iso.config.system.build.isoImage
```

## Yapı

```
modules/
├── apps/          # Uygulama modülleri (ai, browser, gaming)
├── cli/           # Nix-native CLI araçları
├── desktop/       # Quickshell + Wayland bileşenleri
│   └── quickshell/
│       ├── plugins/   # Bar, OSD, Bildirimler, Launcher, Lock, ThemeMenu
│       └── themes/    # JSON tema dosyaları
├── developer/     # Geliştirici araçları (eza, bat, fzf, lazygit...)
├── hardware/      # Donanım algılama
├── home/          # Home Manager (Hyprland, Kitty, Tmux, Neovim, Starship)
└── os/            # Sistem altyapısı (Pipewire, NetworkManager, SDDM, Fonts)
```

## Lisans

MIT
