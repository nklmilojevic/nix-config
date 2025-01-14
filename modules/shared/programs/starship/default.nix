{
  catppuccin = {
    starship = {
      enable = true;
    };
  };

  programs.starship = {
    enable = true;

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
        disabled = true;
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
