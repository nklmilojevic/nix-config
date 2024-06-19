{ config, pkgs, ... }:

{
  home.stateVersion = "24.05";

  home.packages = with pkgs; [
    _1password
    bat
    bandwhich
    curl
    docker
    fd
    ffmpeg_7
    fish
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
    nix-your-shell
    bottom
    chezmoi
    nixpkgs-fmt
  ];
}
