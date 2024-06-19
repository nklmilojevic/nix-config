{ config, pkgs, ... }:

{
  services.nix-daemon.enable = true;
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = "nix-command flakes";
  nixpkgs.hostPlatform = "aarch64-darwin";
}
