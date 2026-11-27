{ lib, ... }:
{
  # Rex terminals prepend REX_BIN_DIR to PATH, but nix-darwin's PATH reset and
  # the fish_add_path calls in fish init push it back; restore it last.
  # https://www.superlogical.com/rex/docs/automate/cli#nix
  programs.fish.interactiveShellInit = lib.mkAfter ''
    if set -q REX_BIN_DIR
      fish_add_path --path --prepend --move $REX_BIN_DIR
    end
  '';
}
