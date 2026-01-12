# Aggregates all package sets
# Usage: import ./packages { inherit pkgs; }
{pkgs}:
  (import ./core.nix {inherit pkgs;})
  ++ (import ./shell.nix {inherit pkgs;})
  ++ (import ./cli-modern.nix {inherit pkgs;})
  ++ (import ./kubernetes.nix {inherit pkgs;})
  ++ (import ./cloud.nix {inherit pkgs;})
  ++ (import ./languages.nix {inherit pkgs;})
  ++ (import ./containers.nix {inherit pkgs;})
  ++ (import ./security.nix {inherit pkgs;})
  ++ (import ./nix-tools.nix {inherit pkgs;})
  ++ (import ./dev-tools.nix {inherit pkgs;})
