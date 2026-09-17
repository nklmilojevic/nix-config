# Security and encryption tools
{ pkgs }:
with pkgs;
[
  _1password-cli
  age
  sops
  varlock
  nmap
  rustscan
  # Required by the sofka trivy plugin
  trivy
  tshark
  zizmor
]
