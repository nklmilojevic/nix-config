{pkgs, ...}: {
  catppuccin = {
    fish = {
      enable = true;
    };
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -g fish_greeting

      fish_add_path "$HOME/.nix-profile/bin"
      fish_add_path "$HOME/.local/bin"
      fish_add_path "$HOME/bin"
      fish_add_path "$HOME/.npm-global/bin"

      set -gx SOPS_AGE_KEY_FILE $HOME/.config/sops/age/keys.txt
      set -gx EDITOR vim
      set -gx VISUAL vim
      set -gx LANG en_US.UTF-8
      set -gx LC_ALL en_US.UTF-8
      set -gx HOMEBREW_NO_ANALYTICS 1
      set -gx NPM_CONFIG_PREFIX $HOME/.npm-global
      set -gx SSH_AUTH_SOCK $HOME/.1password/agent.sock

      set -U __done_allow_nongraphical 1
      set -U --append __done_exclude '^htop'
      set -U --append __done_exclude '^btop'
      set -U --append __done_exclude '^vim'
      set -U --append __done_exclude '^nvim'

      nix-your-shell fish | source
      # Atuin hex wrapper (PTY terminal emulator) + regular init with --disable-up-arrow
      if status is-interactive; and test -t 0; and test -t 1
        set -l _atuin_hex_tmux_current ""
        if set -q TMUX
          set _atuin_hex_tmux_current "$TMUX"
        end

        set -l _atuin_hex_tmux_previous ""
        if set -q ATUIN_HEX_TMUX
          set _atuin_hex_tmux_previous "$ATUIN_HEX_TMUX"
        end

        if not set -q ATUIN_HEX_ACTIVE
          set -gx ATUIN_HEX_ACTIVE 1
          set -gx ATUIN_HEX_TMUX "$_atuin_hex_tmux_current"
          exec atuin hex
        else if test "$_atuin_hex_tmux_current" != "$_atuin_hex_tmux_previous"
          set -gx ATUIN_HEX_ACTIVE 1
          set -gx ATUIN_HEX_TMUX "$_atuin_hex_tmux_current"
          exec atuin hex
        end
      end
      atuin init fish --disable-up-arrow | source
    '';

    plugins = [
      {
        name = "puffer";
        src = pkgs.fishPlugins.puffer.src;
      }
      {
        name = "done";
        src = pkgs.fishPlugins.done.src;
      }
      {
        name = "fisher-plugin-macos";
        src = pkgs.fetchFromGitHub {
          owner = "edheltzel";
          repo = "fisher-plugin-macos";
          rev = "5b4c5815040eca670c4f552b575a60d3f05af2ea";
          sha256 = "sha256-TiAo6YzN4aRaMlZEvXlIR9xhYkEiGMSdKYnomEnfGCk=";
        };
      }
      {
        name = "fzf-fish";
        src = pkgs.fetchFromGitHub {
          owner = "PatrickF1";
          repo = "fzf.fish";
          rev = "8920367cf85eee5218cc25a11e209d46e2591e7a";
          sha256 = "sha256-T8KYLA/r/gOKvAivKRoeqIwE2pINlxFQtZJHpOy9GMM=";
        };
      }
    ];

    shellAliases = {
      kubectl = "kubecolor";
      k = "kubectl";
      kns = "kubectl ns";
      kctx = "kubectl ctx";
      df = "df -h";
      mkdir = "mkdir -p -v";
      ccc = "claude";
      lg = "lazygit";
      grep = "rg";

      # 1Password plugin wrappers
      restic = "op plugin run -- restic";
      gh = "op plugin run -- gh";
      openai = "op plugin run -- openai";
      llm = "op plugin run -- llm";
    };

    functions = {
      psgrep = {
        argumentNames = ["process"];
        description = "greps for processes";
        body = "ps aux | rg $process | rg -v rg";
      };
      y = {
        argumentNames = ["argv"];
        description = "opens yazi file manager and changes directory on exit";
        body = ''
          set tmp (mktemp -t "yazi-cwd.XXXXXX")
          yazi $argv --cwd-file="$tmp"
          if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
            builtin cd -- "$cwd"
          end
          rm -f -- "$tmp"
        '';
      };
      watch = {
        description = "watch with fish alias support";
        body = ''
          if test (count $argv) -gt 0
            if type -q viddy
              command viddy --disable_auto_save --differences --interval 2 --shell fish $argv[1..-1]
            else
              command watch -x fish -c "$argv"
            end
          end
        '';
      };
      ghr = {
        description = "bump and create a GitHub release";
        body = ''
          set -l bump_type ""
          set -l extra_args

          for arg in $argv
            switch $arg
              case --major
                set bump_type major
              case --minor
                set bump_type minor
              case --patch
                set bump_type patch
              case '*'
                set -a extra_args $arg
            end
          end

          if test -z "$bump_type"
            echo "Usage: ghr --major|--minor|--patch [extra gh release args]"
            return 1
          end

          set -l latest (gh release view --json tagName -q '.tagName' 2>/dev/null)
          if test $status -ne 0; or test -z "$latest"
            echo "No existing release found, starting from v0.0.0"
            set latest "v0.0.0"
          end

          set -l ver (string replace -r '^v' "" $latest)
          set -l parts (string split '.' $ver)
          if test (count $parts) -ne 3
            echo "Error: cannot parse version '$latest'"
            return 1
          end

          set -l major $parts[1]
          set -l minor $parts[2]
          set -l patch $parts[3]

          switch $bump_type
            case major
              set major (math $major + 1)
              set minor 0
              set patch 0
            case minor
              set minor (math $minor + 1)
              set patch 0
            case patch
              set patch (math $patch + 1)
          end

          set -l new_tag "v$major.$minor.$patch"
          echo "$latest → $new_tag"
          gh release create $new_tag --generate-notes $extra_args
        '';
      };
    };
  };
}
