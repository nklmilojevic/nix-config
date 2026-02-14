{
  config,
  lib,
  pkgs,
  ...
}: {
  home.activation.installSwiftBarPlugins = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p ${config.home.homeDirectory}/.swiftbar-plugins
    ${pkgs.rsync}/bin/rsync -avz --chmod=D2755,F755 ${./plugins}/ ${config.home.homeDirectory}/.swiftbar-plugins/
  '';
}
