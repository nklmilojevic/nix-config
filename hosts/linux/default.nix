{ config, pkgs, ... }:

{
  imports = [
    ../../modules/linux/home-manager.nix
    ../../modules/shared
    ../../modules/shared/cachix
  ];
}
