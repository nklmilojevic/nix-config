{
  inputs,
  lib,
  user,
  ...
}:
let
  myLib = import ../../lib { inherit lib; };
in
{
  home-manager = {
    useGlobalPkgs = true;
    backupFileExtension = "backup";
    extraSpecialArgs = { inherit inputs; };
    users.${user} =
      { pkgs, ... }:
      {
        imports = [ ../shared/home-manager.nix ] ++ myLib.mkProgramImports ./programs;

        home.packages = pkgs.callPackage ./packages.nix { };

        programs.man.generateCaches = false;

        # Marked broken Oct 20, 2022 check later to remove this
        # https://github.com/nix-community/home-manager/issues/3344
        manual.manpages.enable = false;
      };
  };
}
