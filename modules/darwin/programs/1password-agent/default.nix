{...}: {
  home.file.".config/1Password/ssh/agent.toml" = {
    source = ./agent.toml;
    recursive = true;
  };
}
