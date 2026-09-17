# The nixpkgs starship with the local `detect_input` patch applied. Shared by
# the home-manager module below and the `starship` flake package output, so the
# two cannot drift apart.
{ pkgs }:
pkgs.starship.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [ ./detect-input.patch ];
})
