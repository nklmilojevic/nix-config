{
  pkgs,
  lib,
  ...
}:
{
  config = lib.mkMerge [
    {
      home.packages = [
        pkgs.krew
      ];

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

      programs.fish = {
        interactiveShellInit = ''
          fish_add_path $HOME/.krew/bin
        '';
      };
    }
  ];
}
