{lib, ...}: let
  myLib = import ../../lib {inherit lib;};
in {
  # Auto-import all program modules from the programs directory
  imports = myLib.mkProgramImports ./programs;
}
