# Xmarchy VM Test ve Doğrulama İş Akışı

Bu iş akışı, Xmarchy sisteminde yapılan değişikliklerin sanal makinede (QEMU) test edilmesi için izlenecek standart adımları belirler.

## 1. Adım: Değişiklik Özeti
- Yapılan değişiklikleri (`modules/os/`, `modules/desktop/`, `modules/home/` vb.) gözden geçir.
- Sözdizimi hatalarını önlemek için ilgili `.nix` veya `.qml` dosyalarını kontrol et.

## 2. Adım: Flake Sözdizimi Kontrolü
Terminalde derleme öncesi flake bütünlüğünü doğrula:
```bash
nix flake check
```
Eğer sözdizimi veya referans hatası varsa derlemeye geçmeden önce düzelt.

## 3. Adım: VM Derleme (Build)
VM paketini izole olarak derle ve `result-vm` sembolik bağını oluştur:
```bash
nix build .#vm -o result-vm
```
*Not: Bu adım, sistemi derleyerek derleme hatalarını baştan yakalar ve `result-vm/bin/run-xmarchy-vm` dosyasını hazırlar.*

## 4. Adım: VM Çalıştırma (Run)
Derlenmiş VM'i doğrudan QEMU üzerinden başlat:
```bash
./result-vm/bin/run-xmarchy-vm
```

## 5. Adım: Kontrol Kriterleri
- QEMU penceresinde Hyprland ve Quickshell barının açılıp açılmadığını doğrula.
- RAM (4096MB) ve CPU (4 çekirdek) ayarlarının `flake.nix` içindeki `xmarchy-vm` tanımına uygun olduğunu teyit et.
- Kısayolları test et:
  - `SUPER + Return` (Kitty Terminal)
  - `SUPER + Space` (Quickshell Launcher)
  - `SUPER + F1` veya `SUPER + /` (Kısayol Rehberi)
  - `SUPER + H, J, K, L` (Pencere Odak Gezinmesi)
