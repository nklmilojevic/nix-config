# Programming language runtimes and tools
{pkgs}:
with pkgs; [
  # Go
  go
  hugo

  # Rust
  rustup

  # Ruby
  ruby

  # PHP
  php84
  php84Packages.composer

  # Python
  uv
  (poetry.withPlugins (ps: [
    pkgs.poetryPlugins.poetry-plugin-shell
  ]))
  (python313.withPackages (ps: [
    ps.pyyaml
    ps.ruff
    ps.pillow
  ]))

  # JavaScript/TypeScript
  bun
  nodejs_24
  pnpm

  # Lua
  lua51Packages.luarocks-nix
]
