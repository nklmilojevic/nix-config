{
  system.defaults = {
    dock = {
      minimize-to-application = true;
      show-process-indicators = true;
      show-recents = false;
      static-only = false;
      showhidden = false;
      tilesize = 48;
      wvous-bl-corner = 1;
      wvous-br-corner = 1;
      wvous-tl-corner = 1;
      wvous-tr-corner = 1;
      persistent-apps = [
        # "/System/Cryptexes/App/System/Applications/Safari.app"
        "/Applications/Brave Origin.app"
        "/System/Applications/Mail.app/"
        "/System/Applications/Messages.app/"
        "/Applications/Slack.app/"
        "/Applications/Telegram.app"
        # "/Applications/Ghostty.app/"
        "/Applications/Thurm.app/"
        "/Applications/Fantastical.app/"
        "/Applications/Discord.app/"
        "/Applications/Anybox.app/"
        "/Applications/Things3.app/"
        "/Applications/FSNotes.app/"
        "/Applications/Spotify.app/"
        "/Applications/RapidAPI.app/"
        "/Applications/TablePro.app/"
        "/Applications/Linear.app/"
      ];
    };

    finder = {
      ShowPathbar = true;
      FXEnableExtensionChangeWarning = false;
      ShowStatusBar = true;
    };

    NSGlobalDomain = {
      AppleKeyboardUIMode = 3;
      AppleMeasurementUnits = "Centimeters";
      InitialKeyRepeat = 30;
      KeyRepeat = 1;
      "com.apple.keyboard.fnState" = true;
      AppleShowScrollBars = "WhenScrolling";
    };

    loginwindow = {
      GuestEnabled = false;
    };

    menuExtraClock = {
      Show24Hour = true;
    };

    trackpad = {
      Clicking = true;
      Dragging = false;
      TrackpadThreeFingerDrag = false;
    };

    CustomUserPreferences = {
      # Avoid creating .DS_Store files on network or USB volumes
      "com.apple.desktopservices" = {
        DSDontWriteNetworkStores = true;
        DSDontWriteUSBStores = true;
      };
      "com.apple.frameworks.diskimages" = {
        skip-verify = true;
        skip-verify-locked = true;
        skip-verify-remote = true;
      };
    };
  };
}
