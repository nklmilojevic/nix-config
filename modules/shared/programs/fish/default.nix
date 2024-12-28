{ pkgs, ... }:

{
  programs.fish = {
    enable = true;
    interactiveShellInit =
      let
        # generate tide config into a file containing key-value pairs
        # example output:
        # tide_aws_bg_color normal
        # tide_aws_color yellow
        # ...
        tidecfg =
          let
            script = pkgs.writeText "tide-configure-fish.fish" ''
              set fish_function_path ${pkgs.fishPlugins.tide}/share/fish/vendor_functions.d $fish_function_path

              tide configure --auto --style='Lean' --prompt_colors='True color' --show_time='24-hour format' --prompt_spacing='Compact' --icons='Many icons' --transient='Yes' --lean_prompt_height='One line'
            '';
          in
          pkgs.runCommandNoCC "tidecfg" { } ''
            HOME=$(mktemp -d)
            ${pkgs.fish}/bin/fish ${script}
            ${pkgs.fish}/bin/fish -c "set -U --long" > $out
          '';
      in
      ''
          # Check if tide is configured by checking one of the variables
          if not set -q tide_aws_bg_color
            # Load the tide configuration from the generated file
            echo "Loading tide configuration (only once)" >&2
            for line in (cat ${tidecfg})
              # tide only works with universal variables
              eval "set -U $line"
            end
          end

        # Load secrets
        test -f ~/.config/fish/secrets.fish && source ~/.config/fish/secrets.fish

        set -g fish_greeting

        fish_add_path "$HOME/.nix-profile/bin"
        fish_add_path "$HOME/.local/bin"
        fish_add_path "$HOME/bin"
        fish_add_path "$HOME/.npm-global/bin"

        set -gx SOPS_AGE_KEY_FILE $HOME/.config/sops/age/keys.txt
        set -gx EDITOR vim
        set -gx LANG en_US.UTF-8
        set -gx LC_ALL en_US.UTF-8
        set -gx HOMEBREW_NO_ANALYTICS 1
        set -gx NPM_CONFIG_PREFIX $HOME/.npm-global
        set -gx SSH_AUTH_SOCK $HOME/.1password/agent.sock

        # theme setup
        set -gx tide_pwd_icon " "
        set -gx tide_pwd_icon_home " "
        set -gx tide_character_icon "❯"
        set -gx tide_left_prompt_items context pwd git character
        set -gx tide_right_prompt_items status cmd_duration jobs direnv nix_shell python ruby go gcloud kubectl terraform elixir time
        set -gx tide_kubectl_icon "󱃾 "
        set -gx tide_kubectl_color "blue"
        set -gx tide_git_icon " "
        set -gx tide_cmd_duration_icon ""

        if status is-interactive
            if type -q zellij
                # Update the zellij tab name with the current process name or pwd.
                function zellij_tab_name_update_pre --on-event fish_preexec
                    if set -q ZELLIJ
                        set -l cmd_line (string split " " -- $argv)
                        set -l process_name $cmd_line[1]
                        if test -n "$process_name" -a "$process_name" != "z"
                            command nohup zellij action rename-tab $process_name >/dev/null 2>&1
                        end
                    end
                end

                function zellij_tab_name_update_post --on-event fish_postexec
                    if set -q ZELLIJ
                        set -l cmd_line (string split " " -- $argv)
                        set -l process_name $cmd_line[1]
                        if test "$process_name" = "z"
                            command nohup zellij action rename-tab (prompt_pwd) >/dev/null 2>&1
                        end
                    end
                end
            end
        end

        if test (uname) = "Darwin"
            # Set Tide variables for kubectl and related tools
            set -gx tide_show_kubectl_on kubectl helm kubens k kubectx stern

            # Set Tide variable for gcloud
            set -gx tide_show_gcloud_on gcloud
        end

        nix-your-shell fish | source
        task --completion fish | source
      '';

    plugins = [
      { name = "puffer"; src = pkgs.fishPlugins.puffer.src; }
      { name = "done"; src = pkgs.fishPlugins.done.src; }
      { name = "tide"; src = pkgs.fishPlugins.tide.src; }
      {
        name = "zoxide";
        src = pkgs.fetchFromGitHub {
          owner = "kidonng";
          repo = "zoxide.fish";
          rev = "bfd5947bcc7cd01beb23c6a40ca9807c174bba0e";
          sha256 = "Hq9UXB99kmbWKUVFDeJL790P8ek+xZR5LDvS+Qih+N4=";
        };
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
        name = "dracula";
        src = pkgs.fetchFromGitHub {
          owner = "dracula";
          repo = "fish";
          rev = "269cd7d76d5104fdc2721db7b8848f6224bdf554";
          sha256 = "sha256-Hyq4EfSmWmxwCYhp3O8agr7VWFAflcUe8BUKh50fNfY=";
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
      {
        name = "tide-show-on-cmd";
        src = pkgs.fetchFromGitHub {
          owner = "branchvincent";
          repo = "tide-show-on-cmd";
          rev = "fb36b09e1d8d934d82ea90d99384d24d4b67db25";
          sha256 = "sha256-p+y4MBe/13JpK/b6HCVT3VRQ05H6RCz5CW4wG9NN2HY=";
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
      ll = "ls -lha";
      lg = "lazygit";
      grep = "rg";
    };

    functions = {
      psgrep = {
        argumentNames = [ "process" ];
        description = "greps for processes";
        body = "ps aux | rg $process | rg -v rg";
      };
    };
  };
}
