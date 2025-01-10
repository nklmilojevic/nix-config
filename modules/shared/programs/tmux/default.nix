{pkgs, ...}: {
  catppuccin = {
    tmux = {
      enable = true;
      extraConfig = ''
        set -g @catppuccin_flavor "mocha"
        set -g @catppuccin_status_background "none"

        set -g @catppuccin_date_time_text " %H:%M"
        set -g @catppuccin_window_current_number_color "#{@thm_peach}"
        set -g @catppuccin_window_current_text " #W"
        set -g @catppuccin_window_current_text_color "#{@thm_bg}"
        set -g @catppuccin_window_number_color "#{@thm_blue}"
        set -g @catppuccin_window_text " #W"
        set -g @catppuccin_window_text_color "#{@thm_surface_0}"
        set -g @catppuccin_status_left_separator "█"

        set -g status-left ""
        set -g status-right "#{E:@catppuccin_status_application}#{E:@catppuccin_status_date_time}"
        set -agF status-right "#{E:@catppuccin_status_battery}"

      '';
    };
  };

  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    keyMode = "vi";
    baseIndex = 1;
    mouse = true;
    prefix = "C-Space";
    shell = "${pkgs.fish}/bin/fish";
    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank
      copycat
      battery
      {
        plugin = fuzzback;
        extraConfig = ''
          set -g @fuzzback-popup 1
          set -g @fuzzback-bind f
        '';
      }
      {
        plugin = mkTmuxPlugin {
          pluginName = "floax";
          version = "1.0.0";
          src = pkgs.fetchFromGitHub {
            owner = "omerxx";
            repo = "tmux-floax";
            rev = "main";
            sha256 = "sha256-DOwn7XEg/L95YieUAyZU0FJ49vm2xKGUclm8WCKDizU=";
          };
        };
        extraConfig = ''
          set -g @floax-bind '-n C-f'
          set -g @floax-width '60%'
          set -g @floax-height '60%'
        '';
      }
    ];
    extraConfig = ''
      setw -g pane-base-index 1
      set-option -g renumber-windows on
      set-option -sa terminal-overrides ",xterm*:Tc"
      set-option -g default-command ${pkgs.fish}/bin/fish

      set -g allow-passthrough on
      set -ga update-environment TERM
      set -ga update-environment TERM_PROGRAM
      bind -n C-g popup -d '#{pane_current_path}' -E -w 80% -h 80% lazygit
      bind -n C-e popup -Ed '#{pane_current_path}' -w85% -h85% yazi

      unbind -T copy-mode-vi MouseDragEnd1Pane

      set -g allow-passthrough on
      set -ga update-environment TERM
      set -ga update-environment TERM_PROGRAM

      bind -r g popup -d '#{pane_current_path}' -E -w 80% -h 80% lazygit
      bind -n C-e popup -Ed '#{pane_current_path}' -w85% -h85% yazi
      unbind -T copy-mode-vi MouseDragEnd1Pane
      # Split bindings
      bind + split-window -c "#{pane_current_path}"
      bind - split-window -h -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"

    '';
  };
}
