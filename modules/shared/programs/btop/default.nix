{
  pkgs,
  ...
}:
{
  config = {
    programs.btop = {
      enable = true;
      settings = {
        color_theme = "Dracula";
        theme_background = false;
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