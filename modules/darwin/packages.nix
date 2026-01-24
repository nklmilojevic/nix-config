{pkgs}: let
  lib = import ../../lib {lib = pkgs.lib;};
in
  lib.mkPackageList {
    inherit pkgs;
    shared = ../shared/packages;
    extra = with pkgs; [
      duti
      stress
    ];
  }
