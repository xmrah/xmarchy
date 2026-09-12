{ pkgs, lib, ... }:

{
  # Xmarchy Live CD Ayarları
  image.fileName = lib.mkForce "xmarchy.iso";
  isoImage.makeEfiBootable = true;
  isoImage.makeUsbBootable = true;

  # Live CD için otomatik giriş
  services.getty.autologinUser = "nixos";
}
