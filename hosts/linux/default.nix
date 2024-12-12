{ pkgs, ... }:

{
  imports = [
    ../../modules/linux/home-manager.nix
    ../../modules/shared
    ../../modules/shared/cachix
  ];

  programs.home-manager.enable = true;

  nix = {
    package = pkgs.nixStable;
  };
}
