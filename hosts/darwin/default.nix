{
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    ../../modules/darwin/home-manager.nix
    ../../modules/shared
    ../../modules/shared/cachix
    ../../modules/darwin/homebrew
  ];

  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    experimental-features = "nix-command flakes";
  };
  nixpkgs.hostPlatform = "aarch64-darwin";
  system.stateVersion = 5;

  # Workaround for https://github.com/nix-darwin/nix-darwin/issues/1817
  # nixos-render-docs dropped --toc-depth in nixpkgs-unstable, breaking the
  # darwin manual (and the uninstaller, which depends on darwin-help).
  documentation.enable = false;
  system.tools.darwin-uninstaller.enable = false;

  home-manager = {
    backupFileExtension = "backup";
    users.nkl = {
      imports = [
        inputs.krewfile.homeManagerModules.krewfile
        inputs.catppuccin.homeModules.catppuccin
      ];

      programs.man.generateCaches = false;

      programs.krewfile = {
        enable = true;
        krewPackage = pkgs.krew;
        indexes = {
          default = "https://github.com/kubernetes-sigs/krew-index.git";
          netshoot = "https://github.com/nilic/kubectl-netshoot.git";
        };
        plugins = [
          "netshoot/netshoot"
          "browse-pvc"
          "df-pv"
          "ctx"
          "exec-as"
          "ns"
          "klock"
          "kluster-capacity"
          "konfig"
          "krew"
          "neat"
          "node-shell"
          "rook-ceph"
          "pv-migrate"
          "view-secret"
          "view-allocations"
          "view-cert"
          "view-utilization"
          "tree"
        ];
      };
    };
  };
}
