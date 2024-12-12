{ config, pkgs, ... }:

{
  homebrew = {
    enable = true;
    onActivation.cleanup = "uninstall";

    taps = builtins.attrNames config.nix-homebrew.taps;
    brews = [ ];

    casks = [
      "1password"
      "balenaetcher"
      "brave-browser"
      "cleanshot"
      "cloudflare-warp"
      "cryptomator"
      "devutils"
      "discord"
      "elgato-stream-deck"
      "firefox@developer-edition"
      "forklift"
      "hammerspoon"
      "iina"
      "intellij-idea"
      "jordanbaird-ice"
      "karabiner-elements"
      "little-snitch"
      "lunar"
      "maestral"
      "medis"
      "middle"
      "notion"
      "orbstack"
      "plex"
      "plexamp"
      "protonvpn"
      "proxyman"
      "rapidapi"
      "raycast"
      "slack"
      "spotify"
      "stats"
      "tableplus"
      "viber"
      "visual-studio-code"
      "vlc"
      "whatsapp"
      "wezterm"
      "winbox"
      "zed"
      "zoom"
    ];

    masApps = {
      "Amphetamine" = 937984704;
      "Anybox" = 1593408455;
      "Fantastical" = 975937182;
      "Invoice Ninja" = 1503970375;
      "Keka" = 470158793;
      "Logic Pro" = 634148309;
      "NotePlan" = 1505432629;
      "Pixelmator Pro" = 1289583905;
      "Reeder" = 1529448980;
      "Tailscale" = 1475387142;
      "Telegram" = 747648890;
      "Things" = 904280696;
      "WireGuard" = 1451685025;
    };
  };
}
