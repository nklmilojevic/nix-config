{pkgs}:
with pkgs; [
  _1password-cli
  bat
  cachix
  curl
  curlie
  docker
  fd
  ffmpeg_7
  fzf
  gettext
  gh
  git
  unixtools.ping
  jq
  mc
  mtr
  netcat
  nmap
  openssh
  openssl
  pwgen
  restic
  ripgrep
  tree
  tree-sitter
  watch
  wget

  nil
  alejandra

  php83
  php83Packages.composer
  php83Packages.php-cs-fixer

  clickhouse
  postgresql_16
  redis

  fluxcd
  (google-cloud-sdk.withExtraComponents [google-cloud-sdk.components.gke-gcloud-auth-plugin])
  k9s
  kubectl
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
  fishPlugins.git-abbr

  nix-your-shell
  zoxide

  lazydocker

  go
  hugo

  pre-commit
  poetry
  ruff
  uv

  (python312.withPackages (ps: [
    ps.llm
    ps.pyyaml
    ps.llm-cmd
  ]))

  bun
  nodejs_22

  steampipe
  esphome

  btop
  nixpkgs-fmt

  ruby_3_3
  rubyPackages_3_3.solargraph

  lua54Packages.luarocks-nix

  speedtest-go
  neofetch
  zulu

  tshark
  nixd

  ollama

  cloudflared
  go-task
  talosctl
  yq
  helmfile
  kubeconform
  kustomize
  minijinja
  moreutils
  talhelper
  stern
  kubecolor
  kubecm

  timg

  helix
  yazi
  yaml-language-server
  gopls
  intelephense
  nodePackages.vscode-json-languageserver
  nodePackages.dockerfile-language-server-nodejs
  taplo
  marksman
  markdown-oxide
  vscode-langservers-extracted
  nodePackages.typescript-language-server
  emmet-ls
  zls
  zig

  rustup
  lsd
]
