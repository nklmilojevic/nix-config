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
      "brave-browser"
      "calibre"
      "cleanshot"
      "cloudflare-warp"
      "cryptomator"
      "daisydisk"
      "devutils"
      "discord"
      "elgato-stream-deck"
      "eloston-chromium"
      "firefox@developer-edition"
      "forklift"
      "ghostty"
      "hammerspoon"
      "iina"
      "intellij-idea"
      "jordanbaird-ice"
      "karabiner-elements"
      "keycastr"
      "little-snitch"
      "lunar"
      "maestral"
      "medis"
      "middle"
      "notion"
      "orbstack"
      "orion"
      "plex"
      "plexamp"
      "protonvpn"
      "proxyman"
      "rapidapi"
      "raycast"
      "slack"
      "syntax-highlight"
      "spotify"
      "stats"
      "tableplus"
      "viber"
      "visual-studio-code"
      "vlc"
      "whatsapp"
      "wezterm@nightly"
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
