# A Secure Enclave SSH key (enklava) for github.com and all Git signing on
# this Mac; the 1Password agent still serves other SSH hosts.
{
  inputs,
  lib,
  pkgs,
  ...
}:
{
  imports = [ inputs.enklava.homeManagerModules.default ];

  programs.enklava = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    enable = true;
    # Created before enklava existed, so keep its label and path.
    identities.github = {
      keyFile = "~/.ssh/id_enclave_github";
      label = "github-enclave";
      hosts = [ "github.com" ];
    };
    # ~/.ssh/config is not managed here; it includes this file before `Host *`.
    ssh.configFile = ".ssh/enclave.conf";
    git = {
      signingIdentity = "github";
      principals = [
        "nikola@milojevic.me"
        "nikola@mailerlite.com"
      ];
      # The 1Password signing key, so older commits keep verifying.
      extraAllowedSigners = [
        "nikola@milojevic.me,nikola@mailerlite.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICrYywYsK/kocVOa48LjaOR2X10g7lwsB1PtkyBJX800"
      ];
    };
  };
}
