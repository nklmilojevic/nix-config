{ config, pkgs, ... }:

{
  home.username = "nkl";
  home.homeDirectory = "/home/nkl";

  programs.home-manager.enable = true;
}
