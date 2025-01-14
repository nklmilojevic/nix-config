{...}: {
  config = {
    catppuccin = {
      bat = {
        enable = true;
      };
    };

    programs.bat = {
      enable = true;
    };

    programs.fish = {
      shellAliases = {
        cat = "bat --paging=never --style plain";
      };
    };
  };
}
