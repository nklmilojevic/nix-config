#!/usr/bin/env -S just --justfile

set unstable := true
set quiet := true
set script-interpreter := ['bash', '-euo', 'pipefail']
set shell := ['bash', '-euo', 'pipefail', '-c']

hostname := `scutil --get ComputerName 2>/dev/null || uname -n`

[group: 'Bootstrap']
mod bootstrap '.just/bootstrap.just'
[group: 'Secrets']
mod secrets '.just/secrets.just'

[private]
default:
    @just --list

# Build the configuration for the current system
[group: 'Nix']
[script]
build:
    if [ "$(uname -s)" = "Darwin" ]; then
        echo "Building Nix-Darwin configuration..."
        nix build ".#darwinConfigurations.{{ hostname }}.system"
    else
        echo "Building Nix Home Manager configuration for Linux..."
        nix build ".#homeConfigurations.linux.activationPackage"
    fi

# Apply the new configuration
[group: 'Nix']
[script]
switch:
    if [ "$(uname -s)" = "Darwin" ]; then
        echo "Switching to the new Nix-Darwin configuration..."
        sudo ./result/sw/bin/darwin-rebuild switch --flake ".#{{ hostname }}"
    else
        echo "Activating the new Home Manager configuration for Linux..."
        ./result/activate
    fi

# Build and apply the new configuration
[group: 'Nix']
universal-build: build switch

# Refresh the Nix-Darwin configuration in one step
[group: 'Nix']
darwin-refresh:
    echo "Refreshing Nix-Darwin configuration..."
    sudo darwin-rebuild switch --flake . --show-trace

# Update the flake.lock file
[group: 'Nix']
update:
    echo "Updating flake.lock..."
    nix flake update

# Show the current Nix-Darwin and Home Manager status
[group: 'Nix']
status:
    echo "Showing current Nix-Darwin and Home Manager status..."
    darwin-rebuild dry-run

# Open the configuration for editing
[group: 'Nix']
edit:
    echo "Opening configuration files for editing..."
    $EDITOR flake.nix

# Clean build artifacts
[group: 'Nix']
clean:
    echo "Cleaning build artifacts..."
    rm -rf result
