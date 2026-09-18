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

## 3. Adım: VM Derleme ve Çalıştırma
Kullanıcıya testi başlatması için komutu öner (veya kullanıcı onay verirse çalıştır):
```bash
nix run .#vm
```

## 4. Adım: Kontrol Kriterleri
- QEMU penceresinde Hyprland ve Quickshell barının açılıp açılmadığını doğrula.
- RAM (4096MB) ve CPU (4 çekirdek) ayarlarının `flake.nix` içindeki `xmarchy-vm` tanımına uygun olduğunu teyit et.
