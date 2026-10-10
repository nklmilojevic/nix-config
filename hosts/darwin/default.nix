{ user, ... }:
let
  cachix = import ../../modules/shared/cachix/settings.nix;
in
{
  imports = [
    ../../modules/darwin
    ../../modules/shared
  ];

  nixpkgs.config.allowUnfree = true;
  # Determinate Nix owns the daemon and /etc/nix/nix.conf; these land in
  # /etc/nix/nix.custom.conf. Flakes are enabled by default.
  determinateNix = {
    enable = true;
    customSettings = {
      # extra-* appends to Determinate's defaults; plain `trusted-public-keys`
      # would drop the built-in cache.nixos.org key.
      extra-substituters = cachix.substituters;
      extra-trusted-public-keys = cachix.trusted-public-keys;
      # devenv (and other nix clients passing restricted settings) require this
      trusted-users = [
        "root"
        user
      ];
      lazy-trees = true;
    };
    determinateNixd.garbageCollector.strategy = "automatic";
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
