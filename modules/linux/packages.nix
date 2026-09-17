{ pkgs }:
let
  lib = import ../../lib { inherit (pkgs) lib; };
in
lib.mkPackageList {
  inherit pkgs;
  shared = ../shared/packages;
  extra = [ ];
}
