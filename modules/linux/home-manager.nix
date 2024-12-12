{ config, pkgs, lib, ... }:

let
  user = "nkl";
  xdg_configHome = "/home/${user}/.config";
in
{
  home = {
    enableNixpkgsReleaseCheck = false;
    username = "${user}";
    homeDirectory = "/home/${user}";
    packages = pkgs.callPackage ./packages.nix { };
    stateVersion = "25.05";
  };

  imports = [
    ../shared/home-manager.nix
  ];

}
