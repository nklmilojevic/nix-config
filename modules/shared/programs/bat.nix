{
  pkgs,
  ...
}:
{
  config = {
    programs.bat = {
      enable = true;
      config = {
        theme = "Dracula";
      };
    };

    programs.fish = {
      shellAliases = {
        cat = "bat --paging=never --style plain";
      };
    };
  };
}