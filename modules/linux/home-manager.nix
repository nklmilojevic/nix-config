{pkgs, ...}: let
  user = "nkl";
  xdg_configHome = "/home/${user}/.config";
  sharedImports = ../shared/home-manager.nix;
  packagesFile = ./packages.nix;
in {
  home = {
    enableNixpkgsReleaseCheck = false;
    username = "${user}";
    homeDirectory = "/home/${user}";
    packages = pkgs.callPackage packagesFile {};
    stateVersion = "25.05";
  };

  imports = [
    sharedImports
  ];
}
