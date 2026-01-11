# Fish shell and shell ecosystem
{pkgs}:
with pkgs; [
  fish
  fishPlugins.puffer
  fishPlugins.done
  fishPlugins.git-abbr
  nix-your-shell
  direnv
  atuin
  zoxide
]
