# Default user, home directory and hostname
USERNAME ?= $(shell whoami)
HOME_DIR ?= /Users/$(USERNAME)
HOSTNAME ?= $(shell scutil --get ComputerName 2>/dev/null || uname -n)
OS ?= $(shell uname -s)
SECRETS_FILE := $(HOME)/.config/fish/secrets.fish
OP := op
SSH_CONFIG_FILE := $(HOME)/.ssh/config
ATUIN_KEY_FILE := $(HOME)/.local/share/atuin/key
AGE_KEY_FILE := $(HOME)/.config/sops/age/keys.txt

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
switch: ## Apply the new configuration and generate secrets
ifeq ($(OS), Darwin)
	@echo "Switching to the new Nix-Darwin configuration..."
	@./result/sw/bin/darwin-rebuild switch --flake .#${HOSTNAME}
	@$(MAKE) post-switch
	@echo "Secrets rewritten."
else
	@echo "Activating the new Home Manager configuration for Linux..."
	@./result/activate
endif

.PHONY: post-switch
post-switch: ## Run post-switch tasks (generate secrets)
	@echo "Running post-switch tasks..."
	@$(MAKE) check-op-signin
	@$(MAKE) all-secrets

.PHONY: check-op-signin
check-op-signin:
	@if ! $(OP) account get --format=json >/dev/null 2>&1; then \
		echo "1Password is not signed in. Please sign in:"; \
		eval $$($(OP) signin); \
	else \
		echo "1Password is already signed in."; \
	fi

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

.PHONY: all-secrets generate-secrets generate-ssh-config generate-atuin-key generate-age-key

all-secrets: generate-secrets generate-ssh-config generate-atuin-key generate-age-key

generate-secrets:
	@echo "Generating secrets..."
	@mkdir -p $(dir $(SECRETS_FILE))
	@echo "# Generated secrets - Do not edit manually" > $(SECRETS_FILE)
	@echo "" >> $(SECRETS_FILE)
	@echo "set -gx GITHUB_TOKEN \"$(shell $(OP) read 'op://Private/Github Personal Access Token/token')\"" >> $(SECRETS_FILE)
	@echo "set -gx OPENAI_API_KEY \"$(shell $(OP) read 'op://Private/OpenAI key/apikey')\"" >> $(SECRETS_FILE)
	@echo "Secrets generated in $(SECRETS_FILE)"

generate-ssh-config:
	@echo "Generating SSH config..."
	@mkdir -p $(dir $(SSH_CONFIG_FILE))
	@$(OP) read 'op://Private/SSH Config/notesPlain' > $(SSH_CONFIG_FILE)
	@echo "SSH config generated in $(SSH_CONFIG_FILE)"

generate-atuin-key:
	@echo "Generating Atuin key..."
	@mkdir -p $(dir $(ATUIN_KEY_FILE))
	@$(OP) read 'op://Private/atuin key/password' > $(ATUIN_KEY_FILE)
	@echo "Atuin key generated in $(ATUIN_KEY_FILE)"

generate-age-key:
	@echo "Generating Age key..."
	@mkdir -p $(dir $(AGE_KEY_FILE))
	@$(OP) read 'op://Private/age key/password' > $(AGE_KEY_FILE)
	@echo "Age key generated in $(AGE_KEY_FILE)"