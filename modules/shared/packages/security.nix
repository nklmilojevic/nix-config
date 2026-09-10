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
  tshark
  zizmor
]
