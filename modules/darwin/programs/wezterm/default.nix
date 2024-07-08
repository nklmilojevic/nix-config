{ pkgs, ... }:

{
  home.file.".wezterm.lua" = {
    source = ./.wezterm.lua;
  };
}
