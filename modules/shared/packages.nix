{ pkgs }:

with pkgs; [
  _1password
  bat
  bandwhich
  curl
  docker
  fd
  ffmpeg_7
  fzf
  gettext
  gh
  git
  htop
  jq
  mc
  mtr
  netcat
  nmap
  openssl
  pwgen
  restic
  ripgrep
  tree
  tree-sitter
  watch
  wget

  php83
  php83Packages.composer
  php83Packages.php-cs-fixer
  php83Packages.deployer

  clickhouse
  postgresql_16
  redis

  fluxcd
  (google-cloud-sdk.withExtraComponents [ google-cloud-sdk.components.gke-gcloud-auth-plugin ])
  k9s
  kubectl
  kubectx
  kubernetes-helm
  skaffold
  opentofu

  age
  sops

  atuin
  direnv
  fish
  fishPlugins.puffer
  fishPlugins.done
  nix-your-shell
  zoxide

  lazygit
  lazydocker

  go
  hugo

  neovim
  pre-commit
  python312
  ruff

  bun
  nodejs_22

  steampipe
  esphome

  bottom
  nixpkgs-fmt
]