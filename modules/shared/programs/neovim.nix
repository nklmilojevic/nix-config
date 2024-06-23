{ config, pkgs, lib, ... }:

{
  home.file.".config/nvim" = {
    source = ../dots/nvim;
    recursive = true;
  };
}
