# Development tools and utilities
{ pkgs }:
with pkgs;
[
  # Media
  ffmpeg_7
  imagemagick
  # Without the gphoto2 camera backend: libgphoto2 2.5.34 fails to link libintl
  # on aarch64-darwin. Drop the override once nixpkgs fixes libgphoto2.
  (sane-backends.override { libgphoto2 = null; })
  timg
  qrencode

  # Databases
  mariadb.client
  postgresql_16
  redis

  # Network diagnostics
  mtr
  netcat
  rdap
  trippy
  nextdns
  playwright

  # Build/task tools
  go-task
  just
  lefthook
  nixfmt
  oxfmt
  stylua
  minijinja
  mailersend
  mailerlite

  # AI coding assistants
  claude-code
  gemini-cli
  codex
  opencode
  omp

  # Terminal multiplexing
  herdr

  # Misc utilities
  android-tools
  home-assistant-cli
  mc
  superfile
  pv
  pwgen
  restic
  tree-sitter
  speedtest-go
  caddy
]
