# Essential CLI tools
{ pkgs }:
let
  # Policy: no stored gh login. On macOS gh comes from the sefko module
  # (modules/darwin/programs/sefko). Elsewhere gh reads GH_TOKEN when the
  # caller already set it (CI, `op run`), or fetches it from 1Password for this
  # one call. A real executable, unlike a shell alias, is also used by just
  # recipes, vesnik and other tools that run gh themselves.
  gh-1password = pkgs.symlinkJoin {
    name = "gh-1password-${pkgs.gh.version}";
    paths = [ pkgs.gh ];
    postBuild = ''
      rm "$out/bin/gh"
      cat > "$out/bin/gh" <<'EOF'
      #!${pkgs.runtimeShell}
      if [ -z "''${GH_TOKEN:-}" ] && [ -z "''${GITHUB_TOKEN:-}" ]; then
        GH_TOKEN=$(${pkgs._1password-cli}/bin/op read --account my.1password.eu "op://Private/GitHub Personal Access Token/token") || exit 1
        export GH_TOKEN
      fi
      exec ${pkgs.gh}/bin/gh "$@"
      EOF
      chmod +x "$out/bin/gh"
    '';
  };
in
with pkgs;
[
  curl
  curlie
  wget
  fd
  fzf
  ripgrep
  git
  jq
  yq-go
  openssh
  mosh
  openssl
  tree
  watch
  moreutils
  sd
  gettext
  unixtools.ping
  tmux-sessionizer
  yazi
]
++ lib.optional (!stdenv.hostPlatform.isDarwin) gh-1password
