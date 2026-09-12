{ pkgs, lib, ... }:

{
  # NixOS paketlerinde mevcut AI araçları
  environment.systemPackages = with pkgs; [
    ollama          # Local LLM çalıştırma motoru
    tgpt            # Terminal ChatGPT istemcisi (API keysiz)
    mods            # Komut satırı AI asistanı
  ];

  # Ollama servisi (CPU varsayılan, donanıma göre cuda/rocm seçilebilir)
  services.ollama = {
    enable = true;
    acceleration = lib.mkDefault false;
  };
}
