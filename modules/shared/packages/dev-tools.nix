# Development tools and utilities
{ pkgs }:
with pkgs;
[
  # Media
  ffmpeg_7
  imagemagick
  sane-backends
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
  minijinja
  mailersend
  mailerlite

  # AI coding assistants
  claude-code
  gemini-cli
  codex
  opencode

  # Misc utilities
  android-tools
  home-assistant-cli
  mc
  pv
  pwgen
  restic
  tree-sitter
  speedtest-go
  caddy
]
