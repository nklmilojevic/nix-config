{
  config,
  lib,
  ...
}: {
  home.activation.installCodexConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p ${config.home.homeDirectory}/.codex
    cp ${./config.toml} ${config.home.homeDirectory}/.codex/config.toml
    chmod 644 ${config.home.homeDirectory}/.codex/config.toml
  '';
}
