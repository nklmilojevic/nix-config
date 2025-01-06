{
  programs.starship = {
    enable = true;
    enableTransience = true;
    enableFishIntegration = true;
    settings = {
      palette = "dracula";

      palettes.dracula = {
        background = "#1e1f29";
        current_line = "#44475a";
        foreground = "#f8f8f2";
        comment = "#6272a4";
        cyan = "#8be9fd";
        green = "#50fa7b";
        orange = "#ffb86c";
        pink = "#ff79c6";
        purple = "#bd93f9";
        red = "#ff5555";
        yellow = "#f1fa8c";
      };

      add_newline = false;

      format = "$username$hostname$directory$git_branch$git_commit$git_state$git_status$git_metrics$character";

      right_format = "$nix_shell$kubernetes$python$cmd_duration$time";

      cmd_duration = {
        format = "[$duration]($style) ";
        style = "#f1fa8c";
      };

      git_branch = {
        format = "[$symbol$branch(:$remote_branch)]($style) ";
        # style = "#00D900";
        # style = "bold #50fa7b";
        style = "bold #ff79c6";
        symbol = " ";
      };

      git_status = {
        style = "bold #ff5555";
      };

      git_metrics = {
        added_style = "blue";
        deleted_style = "red";
        disabled = false;
        format = "[+$added]($added_style)/[-$deleted]($deleted_style) ";
      };

      time = {
        format = "[  $time]($style)";
        style = "#437675";
        disabled = false;
      };

      hostname = {
        format = "[$hostname]($style) ";
        ssh_only = true;
        style = "#D69B6F";
      };

      username = {
        format = "[$user@]($style)";
        show_always = false;
        # style_user = "#D69B6F";
        style_user = "bold #bd93f9";
      };

      directory = {
        before_repo_root_style = "#0078A2";
        style = "#0078A2";
        disabled = false;
        home_symbol = "~";
        read_only = "🔒";
        repo_root_style = "bold #1D98E8";
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
        style = "dimmed yellow";
        symbol = " ";
      };

      docker_context = {
        symbol = " ";
      };

      elixir = {
        symbol = " ";
      };

      golang = {
        symbol = " ";
      };

      lua = {
        symbol = " ";
      };

      nix_shell = {
        symbol = " ";
        style = "dimmed green";
      };

      nodejs = {
        symbol = " ";
      };

      package = {
        symbol = "󰏗 ";
      };

      php = {
        symbol = " ";
      };

      ruby = {
        symbol = " ";
      };

      rust = {
        symbol = " ";
      };
    };
  };
}
