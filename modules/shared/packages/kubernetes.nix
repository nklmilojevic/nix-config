# Kubernetes ecosystem
{pkgs}:
with pkgs; [
  kubectl
  kubernetes-helm
  helmfile
  kustomize
  kubeconform
  k9s
  stern
  kubecolor
  kubecm
  fluxcd
  skaffold
  talosctl
]
