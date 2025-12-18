{
  pkgs,
  lib,
  ...
}: let
  # Ghostty uses a simple key = value format
  # Lists become multiple entries with the same key
  toGhosttyConfig = attrs:
    lib.concatStringsSep "\n" (
      lib.flatten (
        lib.mapAttrsToList (
          key: value:
            if lib.isList value
            then map (v: "${key} = ${toString v}") value
            else "${key} = ${toString value}"
        )
        attrs
      )
    );

  ghosttyConfigAttrs = {
    # Theme
    theme = "Catppuccin Mocha";

    # Fonts
    font-family = "TX-02 Retina ExtraCondensed";
    font-family-italic = "TX-02 Retina ExtraCondensed Oblique";
    font-family-bold = "TX-02 SemiBold ExtraCondensed";
    font-size = 16;
    font-thicken = true;

    # macOS specific
    macos-titlebar-style = "tabs";
    macos-icon = "custom";
    macos-icon-frame = "aluminum";
    macos-icon-ghost-color = "#44475a";
    macos-icon-screen-color = "#1e1f29,#44475a";

    # Window
    window-padding-balance = false;
    window-padding-x = 10;
    window-padding-y = "10,2";
    alpha-blending = "linear-corrected";

    # Keybindings
    keybind = "shift+enter=text:\\x1b\\r";

    auto-update-channel = "tip";
  };

  ghosttyConfig = pkgs.writeText "ghostty-config" (toGhosttyConfig ghosttyConfigAttrs);
in {
  home.file.".config/ghostty/config".source = ghosttyConfig;
}
