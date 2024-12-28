{ pkgs, ... }:

{
  config = {
    home.packages = [
      pkgs.zellij
    ];

    home.file.".config/zellij" = {
      source = ./zellij;
      recursive = true;
    };

    programs.zellij = {
      enable = true;
    };
  };
}
