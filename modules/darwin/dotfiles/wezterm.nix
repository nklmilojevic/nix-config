{ pkgs, ... }:

{
  home.file.".wezterm.lua" = {
    source = ../dots/wezterm/.wezterm.lua;
    recursive = true;
  };
}
