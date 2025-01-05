{pkgs, ...}: let
  user = "nkl";
  xdg_configHome = "/home/${user}/.config";
  sharedImports = ../shared/home-manager.nix;
in {
  home = {
    enableNixpkgsReleaseCheck = false;
    username = "${user}";
    homeDirectory = "/home/${user}";
    packages = pkgs.callPackage ./packages.nix {};
    stateVersion = "25.05";
  };

  imports = [
    sharedImports
  ];
}
