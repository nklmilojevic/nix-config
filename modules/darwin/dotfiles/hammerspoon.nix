{ pkgs, ... }:

{
  home.file.".hammerspoon" = {
    source = ../dots/hammerspoon;
    recursive = true;
  };
}
