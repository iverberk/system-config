{ pkgs }:

with pkgs;
let shared-packages = import ../shared/packages.nix { inherit pkgs; }; in
shared-packages ++ [
  minikube
  bat
  fd
  fzf
  jq
  ripgrep
  tree
  watch
  nodejs
  firefox
  openvpn
  mutagen
  kubectl
  k9s
  unstable.kind
  tektoncd-cli
  kubernetes-helm
  helmfile
  kubernetes-helmPlugins.helm-diff
  terraform
  kustomize
  shell-gpt
  vale
  yamllint
  wget
  stern
]
