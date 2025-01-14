{...}: {
  config = {
    catppuccin = {
      btop = {
        enable = true;
      };
    };
    programs.btop = {
      enable = true;
      settings = {
        proc_sorting = "cpu direct";
      };
    };

    programs.fish = {
      shellAliases = {
        htop = "btop";
        top = "btop";
      };
    };
  };
}
