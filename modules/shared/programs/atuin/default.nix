{pkgs, ...}: {
  catppuccin = {
    fish = {
      enable = true;
    };
  };
  programs.atuin = {
    enable = true;
    flags = [
      "--disable-up-arrow"
    ];
    settings = {
      dialect = "uk";
      inline_height = "40";
      show_help = "false";
      sync_address = "https://atuin.nikola.wtf";
      auto_sync = true;
      sync_frequency = "1m";
      search_mode = "fuzzy";
      sync = {
        records = true;
      };
    };
  };
}
