{ inputs, ... }:
{
  imports = [ inputs.thurm.homeManagerModules.default ];

  # Only settings that differ from Thurm's defaults (config.example.toml upstream).
  programs.thurm = {
    enable = true;

    settings = {
      font = {
        family = "TX-02 Retina ExtraCondensed";
        family_bold = "TX-02 SemiBold ExtraCondensed";
        family_italic = "TX-02 Retina ExtraCondensed Oblique";
        family_bold_italic = "TX-02 SemiBold ExtraCondensed Oblique";
      };

      window.sidebar_width = 297.0;

      colors.theme = "catppuccin-mocha";

      terminal.copy_on_select = true;

      ai.enabled = true;

      quick_terminal = {
        hotkey = "ctrl+comma";
        size = 0.5;
        opacity = 0.8;
        animation_duration = 0.15;
      };

      remote = [
        {
          name = "pi";
          host = "10.50.0.24";
        }
        {
          name = "orbtest";
          host = "ssh://nkl@127.0.0.1:2222";
        }
      ];

      updates.channel = "tip";
    };
  };
}
