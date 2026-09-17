# Kubernetes ecosystem
{ pkgs }:
with pkgs;
[
  kubectl
  kubernetes-helm
  helmfile
  kustomize
  kubeconform
  k9s
  sofka
  # CLIs required by sofka plugins (github.com/nklmilojevic/sofka-plugins)
  cmctl
  oha
  popeye
  stern
  kubecolor
  kubecm
  fluxcd
  skaffold
  talosctl
  vals
]
