{ pkgs, lib, ... }:

{
  # Xmarchy Live CD Ayarları
  isoImage.isoName = lib.mkForce "xmarchy-brutalist.iso";
  isoImage.makeEfiBootable = true;
  isoImage.makeUsbBootable = true;
  
  # Otomatik giriş (Live CD için)
  services.getty.autologinUser = "nixos";
}
