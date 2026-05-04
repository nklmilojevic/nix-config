{
  ...
}:
{
  programs.ghostty = {
    enable = true;
    # Ghostty is installed via Homebrew on darwin; HM's package isn't built for macOS.
    package = null;
    installBatSyntax = false;

    settings = {
      theme = "Catppuccin Mocha";

      font-family = "TX-02 Retina ExtraCondensed";
      font-family-italic = "TX-02 Retina ExtraCondensed Oblique";
      font-family-bold = "TX-02 SemiBold ExtraCondensed";
      font-size = 16;
      font-thicken = true;
      font-thicken-strength = 88;

      macos-titlebar-style = "tabs";
      macos-icon = "custom";
      macos-icon-frame = "aluminum";
      macos-icon-ghost-color = "#44475a";
      macos-icon-screen-color = "#1e1f29,#44475a";

      window-padding-balance = false;
      window-padding-x = "10,3";
      window-padding-y = 10;
      alpha-blending = "linear-corrected";

      keybind = [ "shift+enter=text:\\x1b\\r" ];
      shell-integration-features = "ssh-terminfo,ssh-env,sudo";
    };
  };
}
