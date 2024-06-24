{ config, pkgs, ... }:

{
  programs.starship = {
    enable = true;
    enableTransience = true;
    settings = {
      add_newline = false;

      format = "$username$hostname$directory$git_branch$git_commit$git_state$git_status$git_metrics$character";

      right_format = "$nix_shell$kubernetes$python$cmd_duration$time";

      cmd_duration = {
        format = "[$duration]($style) ";
        style = "#f1fa8c";
      };

      git_branch = {
        format = "[$symbol$branch(:$remote_branch)]($style) ";
        style = "#00D900";
        symbol = " ";
      };

      git_status = {
        style = "#ff5555";
      };

      git_metrics = {
        added_style = "blue";
        deleted_style = "red";
        disabled = false;
        format = "[+$added]($added_style)/[-$deleted]($deleted_style) ";
      };

      time = {
        format = "[ $time]($style)";
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
        style_user = "#D69B6F";
      };

      directory = {
        before_repo_root_style = "#0078A2";
        style = "#0078A2";
        disabled = false;
        home_symbol = " ";
        read_only = " ";
        repo_root_style = "bold #1D98E8";
        truncate_to_repo = false;
        truncation_length = 8;
      };

      character = {
        error_symbol = "[✗](red)";
        success_symbol = "[❯](green)";
      };

      kubernetes = {
        disabled = false;
        # format = "[⎈ $context( \\($namespace\\))]($style) ";
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
