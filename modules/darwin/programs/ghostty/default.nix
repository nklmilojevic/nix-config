{
  config,
  lib,
  pkgs,
  ...
}:
{
  home.activation.installGhosttyConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p ${config.xdg.configHome}/ghostty
    cp ${./config} ${config.xdg.configHome}/ghostty/config
    chmod 744 ${config.xdg.configHome}/ghostty/config
  '';
}
