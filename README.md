# Nix Configuration Repository

A comprehensive guide to set up and manage your system configuration using Nix, just, and 1Password.

---

## Requirements

- **Nix Package Manager** (installed in step 2 below)
- **1Password CLI**

This repo uses [`just`](https://github.com/casey/just) as its command runner.
You do **not** need to install `just` yourself — it is provided by the flake's
dev shell, so a freshly-Nix'd machine can run it via `nix develop` (see below).
`just` is also installed system-wide once you apply the configuration.

Recipes are organized into modules (`just <module> <recipe>`). Run `just` on its
own to see everything that is available.

---

## Setup

### 1. Clone the Repository

```sh
git clone https://github.com/nklmilojevic/nix-config
cd nix-config
```

### 2. Install Nix (if not already installed)

This is the one bootstrap step that cannot use `just` (you need Nix before you
have `just`). Run the installer directly:

```sh
curl -sSf -L https://install.lix.systems/lix | sh -s -- install
```

Open a new shell afterwards so `nix` is on your `PATH`.

> The same command is also exposed as `just bootstrap setup-nix` for convenience
> once you already have `just` available.

### 3. Enter the dev shell (gives you `just`)

```sh
nix develop
```

This drops you into a shell with `just` available, so you can run the recipes
below before the system configuration has ever been applied. (If you use
`direnv`, `direnv allow` does the same thing.)

### 4. Sign in to 1Password CLI

```sh
op signin
```

---

## Available Recipes

### Nix

- **`just build`**: Build the configuration for your current system.
- **`just switch`**: Apply the new configuration.
- **`just universal-build`**: Build and apply configuration (combines `build` and `switch`).
- **`just darwin-refresh`**: Refresh the Nix-Darwin configuration in one step.
- **`just update`**: Update the `flake.lock` file.
- **`just clean`**: Clean build artifacts.
- **`just edit`**: Open configuration files for editing.
- **`just status`**: Show the current Nix-Darwin and Home Manager status.

### Bootstrap

- **`just bootstrap setup-nix`**: Install the Nix package manager (Lix).

### Secrets

- **`just secrets ssh-config`**: Generate SSH configuration.
- **`just secrets atuin-key`**: Generate Atuin sync key.
- **`just secrets age-key`**: Generate Age encryption key.
- **`just secrets install-fonts`**: Install private fonts from 1Password (macOS only).

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
   just universal-build
   ```

### Post-Installation

After switching configurations, the system will automatically:

1. Verify 1Password CLI authentication.
2. Generate all necessary secret files.
3. Install private fonts (macOS only).

---

## Maintenance

- **Update dependencies**: `just update`
- **Clean build artifacts**: `just clean`
- **Check configuration status**: `just status`

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
