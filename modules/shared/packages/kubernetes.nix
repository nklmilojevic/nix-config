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
  stern
  kubecolor
  kubecm
  fluxcd
  skaffold
  talosctl
  vals
]
