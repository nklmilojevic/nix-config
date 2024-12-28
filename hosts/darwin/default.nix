{ inputs, pkgs, ... }:

{
  imports = [
    ../../modules/darwin/home-manager.nix
    ../../modules/shared
    ../../modules/shared/cachix
    ../../modules/darwin/homebrew
  ];

  services.nix-daemon.enable = true;
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = "nix-command flakes";
  nixpkgs.hostPlatform = "aarch64-darwin";
  system.stateVersion = 5;

  home-manager.users.nkl = {
    imports = [
      inputs.krewfile.homeManagerModules.krewfile
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
        "kluster-capacity"
        "konfig"
        "krew"
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

}
