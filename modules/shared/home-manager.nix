{ lib, ... }:
let
  myLib = import ../../lib { inherit lib; };
in
{
  # Auto-import all program modules from the programs directory
  imports = myLib.mkProgramImports ./programs;

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
