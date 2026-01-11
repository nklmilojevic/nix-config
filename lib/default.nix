# Nix-config library functions
# Provides reusable helpers to reduce duplication across modules
{lib, ...}: {
  # Import all program modules from a directory
  # Usage: mkProgramImports ./programs
  mkProgramImports = dir:
    let
      contents = builtins.readDir dir;
      dirs = lib.filterAttrs (name: type: type == "directory") contents;
    in
      map (name: dir + "/${name}") (builtins.attrNames dirs);

  # Merge shared packages with platform-specific ones
  # Usage: mkPackageList { inherit pkgs; shared = ./shared/packages; extra = [ pkgs.duti ]; }
  mkPackageList = {
    pkgs,
    shared ? null,
    extra ? [],
  }:
    let
      sharedPackages =
        if shared != null
        then import shared {inherit pkgs;}
        else [];
    in
      sharedPackages ++ extra;

  # Standard user configuration
  # Usage: mkUser { name = "nkl"; home = "/Users/nkl"; shell = pkgs.fish; }
  mkUser = {
    name,
    home,
    shell ? null,
  }: {
    users.users.${name} =
      {
        inherit home;
      }
      // lib.optionalAttrs (shell != null) {inherit shell;};
  };

  # Common nixpkgs config
  nixpkgsConfig = {
    allowUnfree = true;
    allowBroken = true;
    allowInsecure = false;
    allowUnsupportedSystem = true;
  };

  # Common nix settings
  nixSettings = {
    experimental-features = "nix-command flakes";
  };
}
