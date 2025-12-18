{pkgs, ...}: {
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
