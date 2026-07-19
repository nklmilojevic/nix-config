{ pkgs, lib, ... }:
{
  catppuccin = {
    starship = {
      enable = true;
    };
  };

  # Repaint the prompt when the first word of the command line changes, so
  # modules using the patched `detect_input` option can appear while typing.
  # The function is defined by the patched `starship init fish`.
  programs.fish.interactiveShellInit = lib.mkAfter "enable_input_detection";

  programs.starship = {
    enable = true;

    # detect_input ("show on command", starship/starship#5509): reveal modules
    # based on the command being typed. Patch generated from a local checkout;
    # if it stops applying after a starship bump, regenerate it from
    # https://github.com/starship/starship against the new tag.
    package = pkgs.starship.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [ ./detect-input.patch ];
    });

    enableTransience = true;
    enableFishIntegration = true;
    settings = {
      add_newline = false;

      format = "$username$hostname$directory$git_branch$git_commit$git_state$git_metrics$character";

      right_format = "$nix_shell$kubernetes$python$cmd_duration$time";

      cmd_duration = {
        format = "[$duration]($style) ";
        style = "dimmed yellow";
      };

      git_branch = {
        format = "[$symbol$branch(:$remote_branch)]($style) ";
        style = "red";
      };

      git_status = {
        style = "red";
      };

      git_metrics = {
        added_style = "green";
        deleted_style = "red";
        disabled = false;
        format = "[+$added]($added_style)/[-$deleted]($deleted_style) ";
      };

      time = {
        style = "dimmed yellow";
        disabled = false;
      };

      hostname = {
        format = "[$hostname]($style) ";
        ssh_only = true;
        # style = "#D69B6F";
      };

      username = {
        format = "[$user@]($style)";
        show_always = false;
      };

      directory = {
        before_repo_root_style = "lavender";
        style = "lavender";
        disabled = false;
        repo_root_style = "bold teal";
        truncate_to_repo = false;
        truncation_length = 8;
      };

      character = {
        error_symbol = "[✗](red)";
        success_symbol = "[❯](green)";
      };

      kubernetes = {
        disabled = false;
        detect_input = [ ''^(k|kubectl|helm|k9s|kustomize|stern|flux)\b'' ];
        format = "[󱃾 $context( \\($namespace\\))]($style) ";
        style = "dimmed blue";
      };

      python = {
        disabled = false;
        format = "[$symbol\$pyenv_prefix\(\$version\ )(\($virtualenv\) )]($style)";
        style = "dimmed yellow";
      };

      nix_shell = {
        format = "[$symbol(\($name\))]($style) ";
        style = "dimmed green";
        symbol = "❄️ ";
      };
    };
  };
}
