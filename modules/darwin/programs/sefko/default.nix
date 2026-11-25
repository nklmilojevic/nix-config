{
  config,
  inputs,
  isRemote,
  lib,
  pkgs,
  ...
}:
{
  imports = [ inputs.sefko.homeManagerModules.default ];

  # In-memory agent for 1Password secrets; gh, the agent fish functions and
  # scripts ask it instead of prompting 1Password on every call.
  programs.sefko = {
    enable = true;
    # On remote hosts, authenticate headlessly with a scoped 1Password Service
    # Account instead of the 1Password desktop app approval dialog.
    serviceAccountTokenFile = lib.mkIf isRemote "${config.home.homeDirectory}/.config/sefko/op-service-account-token";
    secrets.github = {
      # 1Password Service Accounts cannot access the built-in Private vault;
      # remote hosts read from a dedicated read-only Knossos vault instead.
      ref =
        if isRemote then
          "op://Knossos/GitHub Personal Access Token/token"
        else
          "op://Private/GitHub Personal Access Token/token";
      account = lib.mkIf (!isRemote) "my.1password.eu";
      env = "GH_TOKEN";
      validate.url = "https://api.github.com/user";
    };
    # gh with GH_TOKEN from the agent, refreshed and retried once after a 401.
    # GH_TOKEN or GITHUB_TOKEN set by the caller (CI, `sefko exec`) wins.
    wrappers.gh = {
      package = pkgs.gh;
      secret = "github";
      bypassEnv = [ "GITHUB_TOKEN" ];
    };
  };
}
