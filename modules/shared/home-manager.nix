{ config, pkgs, lib, ... }:

{
  imports = [
    ./programs/atuin.nix
    ./programs/direnv.nix
    ./programs/doggo.nix
    ./programs/fish.nix
    ./programs/git.nix
    ./programs/k9s.nix
    ./programs/krew.nix
    ./programs/neovim.nix
    ./programs/starship.nix
    ./programs/zoxide.nix
  ];
}
