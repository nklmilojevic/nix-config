{ inputs, pkgs, ... }:
{
  imports = [ inputs.sefko.homeManagerModules.default ];

  # In-memory agent for 1Password secrets; gh, the agent fish functions and
  # scripts ask it instead of prompting 1Password on every call.
  programs.sefko = {
    enable = true;
    secrets.github = {
      ref = "op://Private/GitHub Personal Access Token/token";
      account = "my.1password.eu";
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
