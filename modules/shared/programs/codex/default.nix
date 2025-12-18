{
  pkgs,
  config,
  lib,
  ...
}: let
  tomlFormat = pkgs.formats.toml {};
  homeDir = config.home.homeDirectory;
  isDarwin = pkgs.stdenv.isDarwin;

  writableRoots = [
    "${homeDir}/.cache"
    "${homeDir}/.cache/pip"
    "${homeDir}/.cache/uv"
    "${homeDir}/.cargo"
    "${homeDir}/.rustup"
    "${homeDir}/.yarn"
    "${homeDir}/.npm"
    "${homeDir}/.local/share/pnpm"
  ];

  codexConfigAttrs = {
    model_reasoning_effort = "high";
    model_reasoning_summary = "auto";
    model = "gpt-5.2";
    file_opener = "none";
    show_raw_agent_reasoning = true;
    features = {
      web_search_request = true;
    };
    sandbox_mode = "workspace-write";
    approval_policy = "on-request";
    sandbox_workspace_write = {
      network_access = true;
      writable_roots = writableRoots;
    };
    shell_environment_policy = {
      "inherit" = "all";
      ignore_default_excludes = true;
    };
    mcp_servers = {
      context7 = {
        command = "npx";
        args = ["-y" "@upstash/context7-mcp"];
      };
    };
  };

  codexConfig = tomlFormat.generate "codex-config.toml" codexConfigAttrs;
in {
  home.file.".codex/config.toml".source = codexConfig;
}
