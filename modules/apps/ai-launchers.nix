{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    nodejs
    (makeDesktopItem {
      name = "claude-code";
      desktopName = "Claude Code (Agent)";
      exec = "kitty -e npx -y @anthropic-ai/claude-code";
      icon = "utilities-terminal";
      categories = [ "Development" "Utility" ];
    })
    (makeDesktopItem {
      name = "cline-ai";
      desktopName = "Cline (Agent)";
      exec = "kitty -e npx -y @cline/cli";
      icon = "utilities-terminal";
      categories = [ "Development" "Utility" ];
    })
  ];
}
