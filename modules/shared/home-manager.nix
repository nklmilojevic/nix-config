{ config, pkgs, lib, ... }:


{
  imports = [
    ./programs/atuin.nix
    ./programs/direnv.nix
    ./programs/fish.nix
    ./programs/git.nix
    ./programs/k9s.nix
    ./programs/starship.nix
    ./programs/zoxide.nix
    ./programs/neovim.nix
    ./programs/krew.nix
    ./programs/doggo.nix
  ];
}
