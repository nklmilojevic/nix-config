# Development tools and utilities
{pkgs}:
with pkgs; [
  # Media
  ffmpeg_7
  imagemagick
  timg
  qrencode

  # Databases
  postgresql_16
  redis

  # Network diagnostics
  mtr
  netcat
  rdap
  trippy
  nextdns

  # Build/task tools
  go-task
  lefthook
  minijinja

  # AI coding assistants
  claude-code
  gemini-cli
  codex
  opencode

  # Misc utilities
  mc
  pwgen
  restic
  tree-sitter
  speedtest-go
  caddy
]
