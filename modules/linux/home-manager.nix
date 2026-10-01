{ pkgs, ... }:
let
  user =
    let
      envUser = builtins.getEnv "USER";
    in
    if envUser != "" then envUser else "nkl";
in
{
  home = {
    username = "${user}";
    homeDirectory = "/home/${user}";
    packages = pkgs.callPackage ./packages.nix { };
  };

  imports = [
    ../shared/home-manager.nix
  ];
}
