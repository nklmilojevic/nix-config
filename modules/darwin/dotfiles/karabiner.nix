{ pkgs, ... }:

{
  home.file.".karabiner" = {
    source = ../dots/karabiner;
    recursive = true;
  };
}
