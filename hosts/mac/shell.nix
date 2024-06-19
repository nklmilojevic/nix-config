{ config, pkgs, ... }:

{
  environment.shells = with pkgs; [
    bashInteractive
    fish
    zsh
  ];

  environment.variables.SHELL = "${pkgs.fish}/bin/fish";

  users.users.nkl = {
    home = "/Users/nkl";
    shell = pkgs.fish;
  };

  programs.fish.enable = true;
}
