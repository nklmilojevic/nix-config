# Default user, home directory and hostname
USERNAME ?= $(shell whoami)
HOME_DIR ?= /Users/$(USERNAME)
HOSTNAME ?= $(shell scutil --get ComputerName 2>/dev/null || uname -n)
OS ?= $(shell uname -s)
# Default target: show help
.DEFAULT_GOAL := help

.PHONY: help
help: ## Show this help message
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'

.PHONY: build
build: ## Build the configuration
ifeq ($(OS), Darwin)
	@echo "Building Nix-Darwin configuration..."
	@nix build .#darwinConfigurations.${HOSTNAME}.system
else
	@echo "Building Nix Home Manager configuration for Linux..."
	@nix build .#homeConfigurations.linux.activationPackage
endif

.PHONY: switch
switch: ## Apply the new configuration
ifeq ($(OS), Darwin)
	@echo "Switching to the new Nix-Darwin configuration..."
	@./result/sw/bin/darwin-rebuild switch --flake .#${HOSTNAME}
else
	@echo "Activating the new Home Manager configuration for Linux..."
	@./result/activate
endif

.PHONY: update
update: ## Update the flake.lock file
	@echo "Updating flake.lock..."
	@nix flake update

.PHONY: clean
clean: ## Clean build artifacts
	@echo "Cleaning build artifacts..."
	@rm -rf result

.PHONY: edit
edit: ## Edit the configuration
	@echo "Opening configuration files for editing..."
	@$(EDITOR) flake.nix

.PHONY: status
status: ## Show the current status
	@echo "Showing current Nix-Darwin and Home Manager status..."
	@darwin-rebuild dry-run

.PHONY: darwin-refresh
darwin-refresh: ## Refresh Nix-Darwin configuration
	@echo "Refreshing Nix-Darwin configuration..."
	@darwin-rebuild switch --flake . --show-trace

.PHONY: universal-build
universal-build: build switch ## Build and apply the new configuration based on the OS

.PHONY: setup-nix
setup-nix: ## Install Nix package manager
	@echo "Installing Nix package manager..."
	@curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm
