# A Secure Enclave SSH key (enklava) for github.com and all Git signing on
# this Mac; the 1Password agent still serves other SSH hosts.
{
  inputs,
  isRemote ? false,
  lib,
  pkgs,
  ...
}:
let
  principals = [
    "nikola@milojevic.me"
    "nikola@mailerlite.com"
  ];
  principalList = lib.concatStringsSep "," principals;
  daedalusPubKey = "sk-ecdsa-sha2-nistp256@openssh.com AAAAInNrLWVjZHNhLXNoYTItbmlzdHAyNTZAb3BlbnNzaC5jb20AAAAIbmlzdHAyNTYAAABBBAm/ce3XSBKs/qyZh3Kbm1dIBgQ9MW3sTtk4+xgIEOIEl8fhRTQYrOgeZ07mqHeLzNATAcS3/6Xu8wrkoqUuEmsAAAAEc3NoOg==";
  knossosPubKey = "sk-ecdsa-sha2-nistp256@openssh.com AAAAInNrLWVjZHNhLXNoYTItbmlzdHAyNTZAb3BlbnNzaC5jb20AAAAIbmlzdHAyNTYAAABBBG+G+qhyRDd6FgkK8/s4mO97GcnMGVbEqXtIyM18QkHjiZ0+4J6elyWXHVcheaxSnoxfUk78TOJUpYsnrQBIH4sAAAAEc3NoOg==";
in
{
  imports = [ inputs.enklava.homeManagerModules.default ];

  programs.enklava = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    enable = true;
    # Created before enklava existed, so keep its label and path.
    identities.github = {
      keyFile = "~/.ssh/id_enclave_github";
      label = "github-enclave";
      hosts = [ "github.com" ] ++ lib.optionals (!isRemote) [ "knossos" ];
    };
    # ~/.ssh/config is not managed here; it includes this file before `Host *`.
    ssh.configFile = ".ssh/enclave.conf";
    git = {
      signingIdentity = "github";
      inherit principals;
      # Keep older 1Password-signed commits and commits signed on the other Mac verifying.
      extraAllowedSigners = [
        "${principalList} ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICrYywYsK/kocVOa48LjaOR2X10g7lwsB1PtkyBJX800"
        "${principalList} ${if isRemote then daedalusPubKey else knossosPubKey}"
      ];
    };
  };
}
