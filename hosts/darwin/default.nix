{ user, ... }:
{
  imports = [
    ../../modules/darwin
    ../../modules/shared
    ../../modules/shared/cachix
  ];

  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    experimental-features = "nix-command flakes";
    # devenv (and other nix clients passing restricted settings) require this
    trusted-users = [
      "root"
      user
    ];
  };
  nixpkgs.hostPlatform = "aarch64-darwin";
  system.stateVersion = 5;

  # Workaround for https://github.com/nix-darwin/nix-darwin/issues/1817
  # nixos-render-docs dropped --toc-depth in nixpkgs-unstable, breaking the
  # darwin manual (and the uninstaller, which depends on darwin-help).
  documentation = {
    enable = false;
    doc.enable = false;
    info.enable = false;
    man.enable = false;
  };
  system.tools.darwin-uninstaller.enable = false;
}
