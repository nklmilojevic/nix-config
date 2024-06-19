# Nix Config

This repository contains Nix configurations for managing my development environment and system settings.

## Repository Structure

- **home/**: User-specific configurations using home-manager.
- **hosts/**: Host-specific NixOS configurations.
- **Makefile**: Automates common tasks.

## Getting Started

1. **Clone the Repository**
   ```sh
   git clone https://github.com/nklmilojevic/nix-config.git
   cd nix-config
   ```

2. **Run Makefile Commands**
   - **Setup nix**: Installs nix
     ```sh
     make setup-nix
     ```
   - **Build**: Build the inital config
     ```sh
     make build
     ```
   - **Switch**: Switch to the config
     ```sh
     make switch
     ```
   - **Update**: Update all flake inputs.
     ```sh
     make update
     ```
3. **Apply dotfiles**
     ```sh
     make dotfiles
     ```

## License

This project is licensed under the MIT License.