{ pkgs, lib, config, ... }:

{
    home.activation.weztermConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
        ${pkgs.rsync}/bin/rsync -avz --chmod=D2755,F744 ${./.wezterm.lua} $HOME/.wezterm.lua
    '';
}