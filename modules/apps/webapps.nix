{ pkgs, ... }:

{
  # ═══════════ Xmarchy Web App & Tool Desktop Entries ═══════════
  xdg.desktopEntries = {
    discord = {
      name = "Discord";
      genericName = "Sohbet & Topluluk";
      exec = "chromium --app=https://discord.com/app %U";
      icon = "discord";
      categories = [ "Network" "InstantMessaging" "Chat" ];
      terminal = false;
    };
    whatsapp = {
      name = "WhatsApp";
      genericName = "Anlık Mesajlaşma";
      exec = "chromium --app=https://web.whatsapp.com %U";
      icon = "whatsapp";
      categories = [ "Network" "InstantMessaging" "Chat" ];
      terminal = false;
    };
    chatgpt = {
      name = "ChatGPT";
      genericName = "Yapay Zeka Asistanı";
      exec = "chromium --app=https://chatgpt.com %U";
      icon = "chatgpt";
      categories = [ "Utility" "Network" ];
      terminal = false;
    };
    claude = {
      name = "Claude AI";
      genericName = "Anthropic AI";
      exec = "chromium --app=https://claude.ai %U";
      icon = "claude";
      categories = [ "Utility" "Network" ];
      terminal = false;
    };
    youtube = {
      name = "YouTube";
      genericName = "Video Akışı & Müzik";
      exec = "chromium --app=https://youtube.com %U";
      icon = "youtube";
      categories = [ "AudioVideo" "Video" ];
      terminal = false;
    };
    github = {
      name = "GitHub";
      genericName = "Kod ve Depo Yönetimi";
      exec = "chromium --app=https://github.com %U";
      icon = "github";
      categories = [ "Development" "Network" ];
      terminal = false;
    };
    btop = {
      name = "btop System Monitor";
      genericName = "Sistem Kaynak İzleyici";
      exec = "kitty -e btop";
      icon = "utilities-system-monitor";
      categories = [ "System" "Monitor" ];
      terminal = false;
    };
    neovim = {
      name = "Neovim";
      genericName = "Modern Kod Editörü";
      exec = "kitty -e nvim";
      icon = "nvim";
      categories = [ "Development" "TextEditor" ];
      terminal = false;
    };
  };

  # İkonları XDG ikon teması dizinine dağıt
  xdg.dataFile."icons/hicolor/128x128/apps/discord.png".source = ../../assets/icons/discord.png;
  xdg.dataFile."icons/hicolor/128x128/apps/whatsapp.png".source = ../../assets/icons/whatsapp.png;
  xdg.dataFile."icons/hicolor/128x128/apps/chatgpt.png".source = ../../assets/icons/chatgpt.png;
  xdg.dataFile."icons/hicolor/128x128/apps/claude.png".source = ../../assets/icons/claude.png;
  xdg.dataFile."icons/hicolor/128x128/apps/youtube.png".source = ../../assets/icons/youtube.png;
  xdg.dataFile."icons/hicolor/128x128/apps/github.png".source = ../../assets/icons/github.png;
  xdg.dataFile."icons/hicolor/128x128/apps/docker.png".source = ../../assets/icons/docker.png;
  xdg.dataFile."icons/hicolor/128x128/apps/x.png".source = ../../assets/icons/x.png;
}
