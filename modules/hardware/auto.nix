{ inputs, ... }:

{
  imports = [
    # nixos-hardware entegrasyonu
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd
  ];

  hardware.enableAllFirmware = true;
  hardware.cpu.amd.updateMicrocode = true;
  hardware.cpu.intel.updateMicrocode = true;

  # Grafik Hızlandırma (Mesa, OpenGL, Vulkan, 32-bit oyun uyumluluğu)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
}
