set unstable
set quiet
set script-interpreter := ['bash', '-euo', 'pipefail']
set shell := ['bash', '-euo', 'pipefail', '-c']

home_dir := home_directory()
ssh_config_file := home_dir / '.ssh/config'
atuin_key_file := home_dir / '.local/share/atuin/key'
age_key_file := home_dir / '.config/sops/age/keys.txt'

op_vault := 'op://legemi4nfmddm5osivm3cmejem'
ssh_item := op_vault / 'eallxdl2umzqln63sb46m3w32a/notesPlain'
atuin_item := op_vault / '7sov5yg4zpikuz25m2itz6ndhi/password'
age_item := op_vault / 'rsguk7qmlg2pufvtc7xyd2h6gi/password'
fonts_item := op_vault / 'lcqj53otepp3bmxpswcr2wajyu/fonts.zip'

[private]
default:
    @just --list secrets

# Generate the SSH config from 1Password
[doc('Generate the SSH config from 1Password')]
[script]
ssh-config:
    echo "Generating SSH config..."
    mkdir -p "$(dirname "{{ ssh_config_file }}")"
    op read "{{ ssh_item }}" > "{{ ssh_config_file }}"
    echo "SSH config generated in {{ ssh_config_file }}"

# Generate the Atuin sync key from 1Password
[doc('Generate the Atuin sync key from 1Password')]
[script]
atuin-key:
    echo "Generating Atuin key..."
    mkdir -p "$(dirname "{{ atuin_key_file }}")"
    op read "{{ atuin_item }}" > "{{ atuin_key_file }}"
    echo "Atuin key generated in {{ atuin_key_file }}"

# Generate the Age encryption key from 1Password
[doc('Generate the Age encryption key from 1Password')]
[script]
age-key:
    echo "Generating Age key..."
    mkdir -p "$(dirname "{{ age_key_file }}")"
    op read "{{ age_item }}" > "{{ age_key_file }}"
    echo "Age key generated in {{ age_key_file }}"

# Install private fonts from 1Password (macOS only)
[doc('Install private fonts from 1Password (macOS only)')]
[script]
install-fonts:
    echo "Installing private fonts..."
    temp_dir="$(mktemp -d)"
    fonts_dir="{{ home_dir }}/Library/Fonts"
    mkdir -p "$fonts_dir"
    op read "{{ fonts_item }}" --out-file="$temp_dir/fonts.zip"
    unzip -q "$temp_dir/fonts.zip" -d "$temp_dir/fonts"
    cp "$temp_dir"/fonts/*.{ttf,otf,TTF,OTF} "$fonts_dir/" 2>/dev/null || true
    rm -rf "$temp_dir"
    echo "Fonts installed in $fonts_dir"

# Save the 1Password Service Account token for sefko on a remote Mac (0600)
[doc('Save the 1Password Service Account token for sefko (remote Mac)')]
[script]
op-service-token:
    token_file="{{ home_dir }}/.config/sefko/op-service-account-token"
    mkdir -p "$(dirname "$token_file")"
    chmod 700 "$(dirname "$token_file")"
    read -r -s -p "1Password Service Account token: " token
    echo ""
    if [ -z "$token" ]; then
        echo "Aborted: empty token." >&2
        exit 1
    fi
    umask 077
    printf '%s\n' "$token" > "$token_file"
    chmod 600 "$token_file"
    echo "Saved token to $token_file (0600)."
    if command -v sefko >/dev/null 2>&1; then
        if sefko status >/dev/null 2>&1; then
            sefko refresh github >/dev/null
        else
            sefko get github >/dev/null
        fi
        echo "Verified: sefko fetched github token via Service Account."
    fi
    if command -v enklava >/dev/null 2>&1 && [ -f "{{ home_dir }}/.ssh/id_enclave_github" ]; then
        host_title="$(scutil --get ComputerName 2>/dev/null || hostname -s)"
        echo "Registering Secure Enclave key on GitHub as '$host_title'..."
        enklava github add --key-file "{{ home_dir }}/.ssh/id_enclave_github" --title "$host_title" || true
    fi
