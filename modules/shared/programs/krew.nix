{ pkgs, lib, config, ... }:

{
  config = lib.mkMerge [{
    home.packages = [
      pkgs.krew
    ];

    programs.fish = {
      interactiveShellInit = ''
        fish_add_path $HOME/.krew/bin
      '';
    };
  }];
}
