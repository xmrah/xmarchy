{ pkgs, lib, ... }:

{
  # Xmarchy Live CD Ayarları
  isoImage.isoName = lib.mkForce "xmarchy.iso";
  isoImage.makeEfiBootable = true;
  isoImage.makeUsbBootable = true;

  # Live CD için otomatik giriş
  services.getty.autologinUser = "nixos";
}
