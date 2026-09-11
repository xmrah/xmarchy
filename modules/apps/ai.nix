{ pkgs, ... }:

{
  # NixOS paketlerinde mevcut AI araçları
  environment.systemPackages = with pkgs; [
    ollama          # Local LLM çalıştırma motoru
    tgpt            # Terminal ChatGPT istemcisi (API keysiz)
    mods            # Komut satırı AI asistanı
  ];

  # Ollama servisini başlat (Local LLM'ler için)
  services.ollama = {
    enable = true;
    acceleration = "rocm"; # AMD/Intel/Nvidia sistemine göre ayarlanabilir
  };
}
