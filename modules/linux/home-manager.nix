{pkgs, ...}: let
  user = let
    envUser = builtins.getEnv "USER";
  in
    if envUser != "" then envUser else "nkl";
  xdg_configHome = "/home/${user}/.config";
in {
  home = {
    enableNixpkgsReleaseCheck = false;
    username = "${user}";
    homeDirectory = "/home/${user}";
    packages = pkgs.callPackage ./packages.nix {};
    stateVersion = "25.05";
  };

  imports = [
    ../shared/home-manager.nix
  ];
}
