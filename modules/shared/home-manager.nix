{ inputs, lib, ... }:
let
  myLib = import ../../lib { inherit lib; };
in
{
  imports = [
    inputs.nixvim.homeModules.nixvim
    inputs.catppuccin.homeModules.catppuccin
    inputs.krewfile.homeManagerModules.krewfile
  ]
  # Auto-import all program modules from the programs directory
  ++ myLib.mkProgramImports ./programs;

  home = {
    enableNixpkgsReleaseCheck = false;
    stateVersion = "26.05";
  };

  # catppuccin/nix: enable theming and auto-enroll every port whose program is
  # enabled (silences the autoEnable migration warning). Two ports are themed
  # by hand instead: tmux (pinned plugin + custom @catppuccin_* settings in
  # programs/tmux) and ghostty (built-in "Catppuccin Mocha" theme).
  catppuccin = {
    enable = true;
    autoEnable = true;
    tmux.enable = false;
    ghostty.enable = false;
  };
}
