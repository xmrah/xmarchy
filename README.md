# Xmarchy OS

**Tavizsiz Deklaratif İşletim Sistemi (Brutalist & Impermanent)**

Xmarchy, standart işletim sistemlerinin zayıflıklarını ve şişirilmiş arayüzlerini reddeden; NixOS'un matematiksel kesinliği üzerine inşa edilmiş acımasız bir masaüstü çerçevesidir.

## Felsefe
- **Brutalist Estetik:** Yuvarlak köşeler, pastel renkler ve gereksiz animasyonlar yok. Sadece keskin hatlar, saf karanlık (#000000) ve maksimum kontrast.
- **Sıfır Gecikme (0 Latency):** Boot ekranında logo veya bekleme süresi yok. Tmux escape-time 0. Neovim eklenti yığını olmadan en saf hızında.
- **Ölümcül Vuruş (Impermanence):** Kök dizin (`/`) bellekte (tmpfs) yaşar. Her yeniden başlatmada sistem ilk günkü saflığıyla yeniden doğar. Çöp dosyalar ve kalıntılar diske yazılamaz.
- **Piller Dahil (Batteries Included):** Modern geliştirici cephaneliği (`eza`, `bat`, `lazydocker`, `btop`, `mise`) sistemle bütünleşik gelir.

## Kurulum ve Kullanım

Sistemi yerel olarak derlemek veya Live CD (ISO) oluşturmak için NixOS yüklü bir makinede:

```bash
# ISO İmajını Derlemek
nix build .#nixosConfigurations.xmarchy-iso.config.system.build.isoImage
```
