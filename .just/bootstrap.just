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
[script]
setup-darwin host="":
    # Back up stock /etc shell init files that Determinate Nix touches so
    # nix-darwin does not abort with "Unexpected files in /etc".
    for f in /etc/bashrc /etc/zshrc; do
        if [ -f "$f" ] && [ ! -L "$f" ] && [ ! -e "${f}.before-nix-darwin" ]; then
            echo "Backing up $f -> ${f}.before-nix-darwin..."
            sudo mv "$f" "${f}.before-nix-darwin"
        fi
    done

    echo "Activating nix-darwin for the first time..."
    flake="{{ repo_dir }}"
    if [ -n "{{ host }}" ]; then
        flake="${flake}#{{ host }}"
    fi
    sudo nix run github:nix-darwin/nix-darwin#darwin-rebuild -- switch --flake "$flake"

# One-time post-activation setup for a remote Mac (Tailscale, keychain, SSH include, Katamaran, enklava)
[doc('Post-activation setup for a remote Mac (Tailscale, keychain, SSH, Katamaran, enklava)')]
[script]
setup-remote:
    export PATH="$HOME/.nix-profile/bin:/etc/profiles/per-user/$USER/bin:/run/current-system/sw/bin:/opt/homebrew/bin:$HOME/.local/bin:$PATH"

    echo "Disabling login keychain auto-lock timeout..."
    security set-keychain-settings "$HOME/Library/Keychains/login.keychain-db"

    echo "Ensuring ~/.ssh/config includes ~/.ssh/enclave.conf..."
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    ssh_cfg="$HOME/.ssh/config"
    if [ ! -f "$ssh_cfg" ]; then
        printf 'Include ~/.ssh/enclave.conf\n' > "$ssh_cfg"
        chmod 600 "$ssh_cfg"
    elif ! grep -qF 'enclave.conf' "$ssh_cfg"; then
        tmp="$(mktemp)"
        { printf 'Include ~/.ssh/enclave.conf\n\n'; cat "$ssh_cfg"; } > "$tmp"
        mv "$tmp" "$ssh_cfg"
        chmod 600 "$ssh_cfg"
    fi

    if command -v tailscale >/dev/null 2>&1; then
        if ! tailscale status >/dev/null 2>&1; then
            echo "Connecting to Tailscale..."
            sudo tailscale up
        else
            echo "Tailscale already connected."
        fi
    fi

    if command -v kat >/dev/null 2>&1; then
        echo "Configuring Katamaran..."
        kat setup --default
    fi

    if command -v enklava >/dev/null 2>&1 && [ -f "$HOME/.ssh/id_enclave_github" ]; then
        if [ -r "$HOME/.config/sefko/op-service-account-token" ]; then
            host_title="$(scutil --get ComputerName 2>/dev/null || hostname -s)"
            echo "Registering Secure Enclave key on GitHub as '$host_title'..."
            enklava github add --key-file "$HOME/.ssh/id_enclave_github" --title "$host_title" || true
        else
            echo ""
            echo "1Password Service Account token not configured yet."
            echo "Run 'just secrets op-service-token' later, or add this SSH/signing key to GitHub manually:"
            cat "$HOME/.ssh/id_enclave_github.pub"
        fi
    fi

    echo ""
    echo "Remote Mac setup complete. From daedalus, run:"
    echo "  just bootstrap link-remote $(scutil --get ComputerName 2>/dev/null || hostname -s)"

# Full bootstrap on a fresh remote Mac (nix-darwin switch + remote post-setup)
[doc('Full bootstrap for a fresh remote Mac (nix-darwin + remote setup)')]
setup-remote-mac host="knossos": (setup-darwin host) setup-remote

# Install and verify Thurm on a remote host from this Mac (run on daedalus)
[doc('Install and check Thurm on a remote host from this Mac')]
[script]
link-remote host="knossos":
    echo "Installing matching Thurm binaries on {{ host }}..."
    thurm remote install "{{ host }}"
    echo "Running Thurm remote doctor on {{ host }}..."
    thurm remote doctor "{{ host }}"
    echo "Enabling thurmd LaunchAgent and Tailscale on {{ host }}..."
    ssh "{{ host }}" 'export PATH="$HOME/.local/bin:$HOME/.local/share/thurm/bin:$PATH"; thurm daemon install-launchd && thurm tailscale on'
