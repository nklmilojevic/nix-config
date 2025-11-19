{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ../../modules/darwin/home-manager.nix
    ../../modules/shared
    ../../modules/shared/cachix
    ../../modules/darwin/homebrew
  ];

  nix.enable = false;
  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    experimental-features = "nix-command flakes";
  };
  nix.extraOptions = ''
    access-tokens = github.com=$GITHUB_TOKEN
  '';
  nixpkgs.hostPlatform = "aarch64-darwin";
  system.stateVersion = 5;

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
          "view-secret"
          "view-utilization"
          "tree"
        ];
      };
    };
  };
}
