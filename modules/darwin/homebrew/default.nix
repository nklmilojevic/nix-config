{ config, pkgs, ... }:

{
  homebrew = {
    enable = true;
    onActivation.cleanup = "uninstall";

    taps = builtins.attrNames config.nix-homebrew.taps;
    brews = [ ];

    casks = [
      "1password"
      "bettertouchtool"
      "brave-browser"
      "cleanshot"
      "cryptomator"
      "devutils"
      "discord"
      "firefox@developer-edition"
      "forklift"
      "hammerspoon"
      "iina"
      "istat-menus"
      "karabiner-elements"
      "lunar"
      "maestral"
      "medis"
      "notion"
      "orbstack"
      "plex"
      "plexamp"
      "proxyman"
      "rapidapi"
      "raycast"
      "slack"
      "spotify"
      "tableplus"
      "viber"
      "visual-studio-code"
      "vlc"
      "whatsapp"
      "yubico-yubikey-manager"
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
