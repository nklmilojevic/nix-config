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
    stateVersion = "24.11";
  };

  imports = [
    ../shared/home-manager.nix
  ];

}
