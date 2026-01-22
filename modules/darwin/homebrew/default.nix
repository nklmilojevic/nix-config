{config, ...}: {
  homebrew = {
    enable = true;
    onActivation.cleanup = "uninstall";
    onActivation.upgrade = true;

    taps = builtins.attrNames config.nix-homebrew.taps;
    brews = [];

    casks = [
      "1password"
      "balenaetcher"
      "bambu-studio"
      "brave-browser"
      "calibre"
      "chatgpt"
      "claude"
      "cleanshot"
      "cloudflare-warp"
      "cryptomator"
      "cursor"
      "daisydisk"
      "devutils"
      "discord"
      "elgato-stream-deck"
      "fantastical"
      "firefox@developer-edition"
      "forklift"
      "ghostty"
      "gpg-suite"
      "hammerspoon"
      "iina"
      "intellij-idea"
      "jordanbaird-ice"
      "karabiner-elements"
      "keycastr"
      "little-snitch"
      "lunar"
      "maccy"
      "maestral"
      "medis"
      "middle"
      "orbstack"
      "plex"
      "plexamp"
      "protonvpn"
      "proxyman"
      "rapidapi"
      "raycast"
      "screen-studio"
      "slack"
      "swiftbar"
      "syntax-highlight"
      "spotify"
      "stats"
      "tableplus"
      "viber"
      "visual-studio-code"
      "vlc"
      "whatsapp"
      "zed"
      "zen"
      "zoom"
    ];

    masApps = {
      "1Password for Safari" = 1569813296;
      "Amphetamine" = 937984704;
      "Anybox" = 1593408455;
      "CARROT Weather" = 993487541;
      "Cascadea" = 1432182561;
      "Developer" = 640199958;
      "Home Assistant" = 1099568401;
      "Hover for Safari" = 1540705431;
      "FSNotes" = 1277179284;
      "iMovie" = 408981434;
      "Invoice Ninja" = 1503970375;
      "Kagi for Safari" = 1622835804;
      "Keka" = 470158793;
      "Keynote" = 409183694;
      "Logic Pro" = 634148309;
      "MQTT Explorer" = 1455214828;
      "Numbers" = 409203825;
      "NZBVortex 3" = 914250185;
      "Pages" = 409201541;
      "Parcel" = 375589283;
      "Pixelmator Pro" = 1289583905;
      "Presentify" = 1507246666;
      "Sink It" = 6449873635;
      "Soulver 3" = 1508732804;
      "SponsorBlock" = 1573461917;
      "StopTheMadness Pro" = 6471380298;
      "Tailscale" = 1475387142;
      "Telegram" = 747648890;
      "Things" = 904280696;
      "uBlock Origin Lite" = 6745342698;
      "UnTrap" = 1637438059;
      "WireGuard" = 1451685025;
      "Xcode" = 497799835;
      "Yubico Authenticator" = 1497506650;
    };
  };
}
