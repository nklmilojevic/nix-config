set unstable := true
set quiet := true
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
