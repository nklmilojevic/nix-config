# Variables
USERNAME := $(shell whoami)
HOME_DIR := /Users/$(USERNAME)
HOSTNAME := $(shell scutil --get ComputerName 2>/dev/null || uname -n)
OS := $(shell uname -s)
OP := op
SSH_CONFIG_FILE := $(HOME)/.ssh/config
ATUIN_KEY_FILE := $(HOME)/.local/share/atuin/key
AGE_KEY_FILE := $(HOME)/.config/sops/age/keys.txt

# Default target
.PHONY: default
default: list

.PHONY: list
list:
	@echo "Available targets:"
	@echo "  build              - Build the configuration"
	@echo "  switch             - Apply the new configuration"
	@echo "  update             - Update the flake.lock file"
	@echo "  clean              - Clean build artifacts"
	@echo "  edit               - Edit the configuration"
	@echo "  status             - Show the current status"
	@echo "  darwin-refresh     - Refresh Nix-Darwin configuration"
	@echo "  universal-build    - Build and apply the new configuration based on the OS"
	@echo "  setup-nix          - Install Nix package manager"
	@echo "  generate-ssh-config - Generate SSH config"
	@echo "  generate-atuin-key - Generate Atuin key"
	@echo "  generate-age-key   - Generate Age key"
	@echo "  install-fonts      - Install private fonts from 1Password"

.PHONY: build
build:
	@if [ "$(OS)" = "Darwin" ]; then \
		echo "Building Nix-Darwin configuration..."; \
		nix build .#darwinConfigurations.$(HOSTNAME).system; \
	else \
		echo "Building Nix Home Manager configuration for Linux..."; \
		nix build .#homeConfigurations.linux.activationPackage; \
	fi

.PHONY: switch
switch:
	@if [ "$(OS)" = "Darwin" ]; then \
		echo "Switching to the new Nix-Darwin configuration..."; \
		./result/sw/bin/darwin-rebuild switch --flake .#$(HOSTNAME); \
	else \
		echo "Activating the new Home Manager configuration for Linux..."; \
		./result/activate; \
	fi

.PHONY: update
update:
	@echo "Updating flake.lock..."
	@nix flake update

.PHONY: clean
clean:
	@echo "Cleaning build artifacts..."
	@rm -rf result

.PHONY: edit
edit:
	@echo "Opening configuration files for editing..."
	@$$EDITOR flake.nix

.PHONY: status
status:
	@echo "Showing current Nix-Darwin and Home Manager status..."
	@darwin-rebuild dry-run

.PHONY: darwin-refresh
darwin-refresh:
	@echo "Refreshing Nix-Darwin configuration..."
	@sudo darwin-rebuild switch --flake . --show-trace

.PHONY: universal-build
universal-build: build switch

.PHONY: setup-nix
setup-nix:
	@echo "Installing Nix package manager..."
	@curl -sSf -L https://install.lix.systems/lix | sh -s -- install

.PHONY: generate-ssh-config
generate-ssh-config:
	@echo "Generating SSH config..."
	@mkdir -p $$(dirname $(SSH_CONFIG_FILE))
	@$(OP) read 'op://legemi4nfmddm5osivm3cmejem/eallxdl2umzqln63sb46m3w32a/notesPlain' > $(SSH_CONFIG_FILE)
	@echo "SSH config generated in $(SSH_CONFIG_FILE)"

.PHONY: generate-atuin-key
generate-atuin-key:
	@echo "Generating Atuin key..."
	@mkdir -p $$(dirname $(ATUIN_KEY_FILE))
	@$(OP) read 'op://legemi4nfmddm5osivm3cmejem/7sov5yg4zpikuz25m2itz6ndhi/password' > $(ATUIN_KEY_FILE)
	@echo "Atuin key generated in $(ATUIN_KEY_FILE)"

.PHONY: generate-age-key
generate-age-key:
	@echo "Generating Age key..."
	@mkdir -p $$(dirname $(AGE_KEY_FILE))
	@$(OP) read 'op://legemi4nfmddm5osivm3cmejem/rsguk7qmlg2pufvtc7xyd2h6gi/password' > $(AGE_KEY_FILE)
	@echo "Age key generated in $(AGE_KEY_FILE)"

.PHONY: install-fonts
install-fonts:
	@echo "Installing private fonts..."
	@TEMP_DIR=$$(mktemp -d); \
	FONTS_DIR="$(HOME_DIR)/Library/Fonts"; \
	mkdir -p "$$FONTS_DIR"; \
	$(OP) read "op://legemi4nfmddm5osivm3cmejem/lcqj53otepp3bmxpswcr2wajyu/fonts.zip" --out-file="$$TEMP_DIR/fonts.zip"; \
	unzip -q "$$TEMP_DIR/fonts.zip" -d "$$TEMP_DIR/fonts"; \
	cp "$$TEMP_DIR"/fonts/*.{ttf,otf,TTF,OTF} "$$FONTS_DIR/" 2>/dev/null || true; \
	rm -rf "$$TEMP_DIR"; \
	echo "Fonts installed in $$FONTS_DIR"