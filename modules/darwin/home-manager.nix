{
  inputs,
  lib,
  user,
  hostName,
  isRemote,
  ...
}:
let
  myLib = import ../../lib { inherit lib; };
in
{
  home-manager = {
    useGlobalPkgs = true;
    backupFileExtension = "backup";
    extraSpecialArgs = {
      inherit inputs hostName isRemote;
    };
    users.${user} =
      { config, pkgs, ... }:
      {
        imports = [ ../shared/home-manager.nix ] ++ myLib.mkProgramImports ./programs;

        home.packages = pkgs.callPackage ./packages.nix { };

        # Expose Little Snitch's CLI for headless/SSH management (`sudo littlesnitch`).
        home.file.".local/bin/littlesnitch".source =
          config.lib.file.mkOutOfStoreSymlink "/Applications/Little Snitch.app/Contents/Components/littlesnitch";

        programs.man.generateCaches = false;

        # Marked broken Oct 20, 2022 check later to remove this
        # https://github.com/nix-community/home-manager/issues/3344
        manual.manpages.enable = false;
      };
  };
}
