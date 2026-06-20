set unstable := true
set quiet := true
set script-interpreter := ['bash', '-euo', 'pipefail']
set shell := ['bash', '-euo', 'pipefail', '-c']

[private]
default:
    @just --list bootstrap

# Install the Nix package manager (Lix)
[doc('Install the Nix package manager (Lix)')]
setup-nix:
    echo "Installing Nix package manager..."
    curl -sSf -L https://install.lix.systems/lix | sh -s -- install
