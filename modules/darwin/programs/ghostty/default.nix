{
  pkgs,
  lib,
  ...
}: {
  home.activation.ghosttyConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
   ${pkgs.rsync}/bin/rsync -avz --chmod=D2755,F744 ${./config} $HOME/.config/ghostty/config
  '';
}
