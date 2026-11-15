{ config, inputs, ... }:
{
  imports = [ inputs.thurm.homeManagerModules.default ];

  # Only settings that differ from Thurm's defaults (config.example.toml upstream).
  programs.thurm = {
    enable = true;

    settings = {
      font = {
        family = "TX-02";
        style = "Retina ExtraCondensed";
      };

      window = {
        sidebar_width = 306.0;
        unfocused_split_dim = 0.1;
        active_pane_border = true;
        animation_speed = "slow";
        sidebar_group_by_repo = false;
        sidebar_usage_claude = true;
      };

      colors = {
        theme = "catppuccin-mocha";
        theme_palette = true;
        improve_contrast = true;
        display_p3 = true;
      };

      ai.enabled = true;

      tailscale = {
        enabled = true;
        web = true;
      };

      # The relay's registration code is a secret: it stays in ~/.config/thurm/settings.toml.
      push.relay = "https://thurm-push.milojevic.dev";

      terminal.copy_on_select = true;

      quick_terminal = {
        hotkey = "ctrl+comma";
        size = 0.5;
        opacity = 0.8;
        animation_duration = 0.15;
      };

      updates.channel = "tip";
    };
  };

  # thurm-nvim (Neovim with a Thurm pane per window) ships in the app and updates with it:
  # link it next to `thurm` rather than install a copy.
  home.file.".local/bin/thurm-nvim".source =
    config.lib.file.mkOutOfStoreSymlink "/Applications/Thurm.app/Contents/Helpers/thurm-nvim";
}
