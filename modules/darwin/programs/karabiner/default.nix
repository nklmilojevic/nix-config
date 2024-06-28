{ pkgs, ... }:

{
  home.file.".karabiner" = {
    source = ./karabiner;
    recursive = true;
  };
}
