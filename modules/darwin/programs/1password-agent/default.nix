{ pkgs, ... }:
{
  # Point the launchd-provided SSH_AUTH_SOCK at the 1Password agent socket
  launchd.agents."com.1password.SSH_AUTH_SOCK" = {
    enable = true;
    config = {
      Label = "com.1password.SSH_AUTH_SOCK";
      ProgramArguments = [
        "/bin/sh"
        "-c"
        ''/bin/ln -sf "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock" "$SSH_AUTH_SOCK"''
      ];
      RunAtLoad = true;
    };
  };

  home.file.".config/1Password/ssh/agent.toml" = {
    source = ./agent.toml;
    recursive = true;
  };

  # 1Password shell plugins
  home.file.".config/op/plugins/local/restic" = {
    source = pkgs.fetchurl {
      url = "https://github.com/nklmilojevic/shell-plugins/releases/download/v20251125.132227/restic-darwin-arm64";
      sha256 = "1wdvbsbydll7hbvk413v8hhjib06hll8bfgf0bgy24ddma3f7yiw";
    };
    executable = true;
  };

  home.file.".config/op/plugins/local/llm" = {
    source = pkgs.fetchurl {
      url = "https://github.com/nklmilojevic/shell-plugins/releases/download/v20251125.132227/llm-darwin-arm64";
      sha256 = "0dbhvfqj3bf8i0knq2q66hvpwq8rzy5hz6pil1ba2b9qn7rfy85y";
    };
    executable = true;
  };
}
