# Default user, home directory and hostname
USERNAME ?= $(shell whoami)
HOME_DIR ?= /Users/$(USERNAME)
HOSTNAME ?= $(shell scutil --get ComputerName 2>/dev/null || uname -n)
OS ?= $(shell uname -s)
SECRETS_FILE := $(HOME)/.config/fish/secrets.fish
OP := op
SSH_CONFIG_FILE := $(HOME)/.ssh/config
ATUIN_KEY_FILE := $(HOME)/.local/share/atuin/key
# Default target: show help
.DEFAULT_GOAL := help

# ... (previous targets remain unchanged)

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

.PHONY: all-secrets generate-secrets generate-ssh-config generate-atuin-key

all-secrets: generate-secrets generate-ssh-config generate-atuin-key

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