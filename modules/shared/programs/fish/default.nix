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
    };
  };
}
