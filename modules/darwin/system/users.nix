{ pkgs, user, ... }:
{
  system.primaryUser = user;

  users.users.${user} = {
    home = "/Users/${user}";
    shell = pkgs.fish;
  };

  environment.shells = with pkgs; [
    bashInteractive
    fish
    zsh
  ];

  environment.variables.SHELL = "${pkgs.fish}/bin/fish";

  programs.fish = {
    enable = true;
    useBabelfish = true;
  };
}
