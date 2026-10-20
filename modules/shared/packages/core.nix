# Essential CLI tools
{ pkgs }:
let
  # Policy: no stored gh login. gh reads GH_TOKEN when the caller already set
  # it (CI, `sefko exec`); otherwise it fetches the token from sefko or
  # 1Password for this one call. A real executable, unlike a shell alias, is
  # also used by just recipes, vesnik and other tools that run gh themselves.
  gh-1password = pkgs.symlinkJoin {
    name = "gh-1password-${pkgs.gh.version}";
    paths = [ pkgs.gh ];
    postBuild = ''
      rm "$out/bin/gh"
      cat > "$out/bin/gh" <<'EOF'
      #!${pkgs.runtimeShell}
      # Token from the sefko agent where it is installed (macOS), otherwise
      # from 1Password for this one call.
      gh=${pkgs.gh}/bin/gh
      if [ -n "''${GH_TOKEN:-}" ] || [ -n "''${GITHUB_TOKEN:-}" ]; then
        exec "$gh" "$@"
      fi
      if ! command -v sefko >/dev/null 2>&1; then
        GH_TOKEN=$(${pkgs._1password-cli}/bin/op read --account my.1password.eu "op://Private/GitHub Personal Access Token/token") || exit 1
        export GH_TOKEN
        exec "$gh" "$@"
      fi
      GH_TOKEN=$(sefko get github) || exit 1
      export GH_TOKEN
      "$gh" "$@"
      rc=$?
      [ "$rc" -eq 0 ] && exit 0
      sefko validate github >/dev/null 2>&1
      if [ $? -eq 10 ]; then
        # A 401 changed nothing, so a retry is safe, unless piped stdin was consumed.
        if [ -t 0 ]; then
          GH_TOKEN=$(sefko get github) || exit "$rc"
          exec "$gh" "$@"
        fi
        echo "sefko: GitHub token was invalid and has been refreshed; re-run the command" >&2
      fi
      exit "$rc"
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
  gh-1password
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
