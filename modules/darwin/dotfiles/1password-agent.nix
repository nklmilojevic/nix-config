{ pkgs, ... }:

{
  home.file.".config/1Password/ssh/agent.toml" = {
    source = ../dots/1password-agent/agent.toml;
    recursive = true;
  };
}
