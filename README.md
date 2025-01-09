# Nix Configuration Repository

A comprehensive guide to set up and manage your system configuration using Nix, Taskfile, and 1Password.

---

## Installation

### Step 1: Install Taskfile
Run the following command to install Taskfile:
```sh
sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b ~/.local/bin
```

Ensure `~/.local/bin` is in your `PATH`:
```sh
export PATH="$HOME/.local/bin:$PATH"
```

### Requirements
- **Nix Package Manager**
- **1Password CLI**

---

## Setup

### 1. Clone the Repository
```sh
git clone https://github.com/nklmilojevic/nix-config
```

### 2. Install Nix (if not already installed)
```sh
task setup-nix
```

### 3. Sign in to 1Password CLI
```sh
op signin
```

---

## Available Tasks

### Basic Tasks
- **`task build`**: Build the configuration for your current system.
- **`task switch`**: Apply the new configuration.
- **`task universal-build`**: Build and apply configuration (combines `build` and `switch`).
- **`task update`**: Update the `flake.lock` file.
- **`task clean`**: Clean build artifacts.
- **`task edit`**: Open configuration files for editing.
- **`task status`**: Show the current Nix-Darwin and Home Manager status.

### Secret Management Tasks
- **`task check-op-signin`**: Verify 1Password CLI authentication.
- **`task all-secrets`**: Generate all secret files.
- **`task generate-secrets`**: Generate environment variables.
- **`task generate-ssh-config`**: Generate SSH configuration.
- **`task generate-atuin-key`**: Generate Atuin sync key.
- **`task generate-age-key`**: Generate Age encryption key.
- **`task install-fonts`**: Install private fonts from 1Password (macOS only).

---

## Secret Management

Secrets are securely managed through 1Password CLI and are automatically fetched during setup.

---


## System-Specific Configurations

### macOS (Darwin)
- Uses **nix-darwin** for system configuration.
- Automatically configures system preferences.
- Manages Homebrew packages.

### Linux
- Uses **Home Manager** for user environment.
- Configures user-specific packages and settings.

---

## Usage

1. Make changes to your configuration in `flake.nix`.
2. Build and switch to the new configuration:
   ```sh
   task universal-build
   ```

### Post-Installation
After switching configurations, the system will automatically:
1. Verify 1Password CLI authentication.
2. Generate all necessary secret files.
3. Install private fonts (macOS only).

---

## Maintenance

- **Update dependencies**: `task update`
- **Clean build artifacts**: `task clean`
- **Check configuration status**: `task status`

---

## License

MIT License

```
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
```

---

## Acknowledgments

This configuration is inspired by various Nix community members and configurations.
