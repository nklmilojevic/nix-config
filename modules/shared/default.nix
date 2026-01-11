{lib, ...}: let
  myLib = import ../../lib {inherit lib;};
in {
  nixpkgs.config = myLib.nixpkgsConfig;
}
