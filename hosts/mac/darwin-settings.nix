{ config, pkgs, ... }:

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
        "/Applications/Brave Browser.app/"
        "/System/Applications/Mail.app/"
        "/Applications/Slack.app/"
        "/Applications/Telegram.app"
        "/Applications/WezTerm.app/"
        "/Applications/Fantastical.app/"
        "/Applications/Discord.app/"
        "/Applications/Anybox.app/"
        "/Applications/Things3.app/"
        "/Applications/Spotify.app/"
        "/Applications/RapidAPI.app/"
        "/applications/TablePlus.app/"
      ];
      persistent-others = [
        "/Users/nkl/Downloads"
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
  };

  system.defaults.CustomUserPreferences = {
    # Avoid creating .DS_Store files on network or USB volumes
    "com.apple.desktopservices" = {
      DSDontWriteNetworkStores = true;
      DSDontWriteUSBStores = true;
    };
  };

  system.activationScripts.postUserActivation.text = ''
    # Following line should allow us to avoid a logout/login cycle
    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    killall Dock
  '';

  security.pam.enableSudoTouchIdAuth = true;

}
