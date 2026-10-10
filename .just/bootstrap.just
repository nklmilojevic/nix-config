set unstable
set quiet
set script-interpreter := ['bash', '-euo', 'pipefail']
set shell := ['bash', '-euo', 'pipefail', '-c']

repo_dir := source_directory() / '..'

[private]
default:
    @just --list bootstrap

# Install the Nix package manager (Determinate Nix)
[doc('Install the Nix package manager (Determinate Nix)')]
setup-nix:
    echo "Installing Determinate Nix..."
    curl -fsSL https://install.determinate.systems/nix | sh -s -- install

# First nix-darwin activation, before darwin-rebuild is on PATH (macOS only)
[doc('First nix-darwin activation, before darwin-rebuild is on PATH (macOS only)')]
setup-darwin:
    echo "Activating nix-darwin for the first time..."
    sudo nix run github:nix-darwin/nix-darwin#darwin-rebuild -- switch --flake "{{ repo_dir }}"
