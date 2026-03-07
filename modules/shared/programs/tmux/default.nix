{pkgs, ...}: let
  kubePlugin = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "kube";
    version = "1.0.0";
    src = pkgs.fetchFromGitHub {
      owner = "jonmosco";
      repo = "kube-tmux";
      rev = "da04ab6b38e5dcb80e0edfc2c6895f8b0f52498e";
      sha256 = "sha256-Z71zsEj4nGptaosDPRVFEp8QwSsawPh1qFMSoRnF2nE=";
    };
  };

  catppuccinPlugin = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "catppuccin";
    version = "2.1.3";
    src = pkgs.fetchFromGitHub {
      owner = "catppuccin";
      repo = "tmux";
      rev = "v2.1.3";
      sha256 = "sha256-Is0CQ1ZJMXIwpDjrI5MDNHJtq+R3jlNcd9NXQESUe2w=";
    };
  };

  floaxPlugin = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "floax";
    version = "1.0.0";
    src = pkgs.fetchFromGitHub {
      owner = "omerxx";
      repo = "tmux-floax";
      rev = "133f526793d90d2caa323c47687dd5544a2c704b";
      sha256 = "sha256-9Hb9dn2qHF6KcIhtogvycX3Z0MoQrLPLCzZXtjGlPHw=";
    };
  };
in {
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

      battery
      kubePlugin
      {
        plugin = catppuccinPlugin;
        extraConfig = ''
          set -g @catppuccin_flavor "mocha"
          set -g @catppuccin_status_background "#1e1e2e"

          set -g @catppuccin_date_time_text " %H:%M"
          set -g @catppuccin_window_current_number_color "#{@thm_peach}"
          set -g @catppuccin_window_current_text " #W"
          set -g @catppuccin_window_current_text_color "#{@thm_bg}"
          set -g @catppuccin_window_number_color "#{@thm_blue}"
          set -g @catppuccin_window_text " #W"
          set -g @catppuccin_window_text_color "#{@thm_surface_0}"
          set -g @catppuccin_status_left_separator "█"
          set -g @catppuccin_directory_icon "⌹ "
          set -g @catppuccin_date_time_icon  "⏲ "
          set -g @catppuccin_kube_icon "⎈ "
          set -g @catppuccin_kube_text " #(${kubePlugin}/share/tmux-plugins/kube/kube.tmux 250 #{@catppuccin_kube_context_color} #{@catppuccin_kube_namespace_color})"
        '';
      }
      {
        plugin = fuzzback;
        extraConfig = ''
          set -g @fuzzback-popup 1
          set -g @fuzzback-bind f
        '';
      }
      {
        plugin = floaxPlugin;
        extraConfig = ''
          set -g @floax-bind '-n C-f'
          set -g @floax-width '60%'
          set -g @floax-height '60%'
        '';
      }
      extrakto
      {
        plugin = resurrect;
        extraConfig = ''
          set -g @resurrect-capture-pane-contents 'on'
          set -g @resurrect-strategy-nvim 'session'
        '';
      }
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '10'
        '';
      }
      vim-tmux-navigator
    ];
    extraConfig = ''
      setw -g pane-base-index 1
      set-option -g renumber-windows on
      set-option -sa terminal-overrides ",xterm-ghostty:Tc"
      set-option -g default-command ${pkgs.fish}/bin/fish

      set-environment -g KUBE_TMUX_SYMBOL_ENABLE "false"
      set -g status-right-length 200
      set -g status-left-length 100
      set -g status-left ""
      set -g status-right "#{E:@catppuccin_status_directory}"
      set -agF status-right "#{E:@catppuccin_status_battery}"
      set -ag status-right "#{E:@catppuccin_status_kube}"

      set -g allow-passthrough on
      set -ga update-environment TERM
      set -ga update-environment TERM_PROGRAM
      bind -n C-g popup -d '#{pane_current_path}' -E -w 80% -h 80% lazygit
      bind g popup -d '#{pane_current_path}' -E -w 80% -h 80% lazygit

      bind v copy-mode
      unbind -T copy-mode-vi MouseDragEnd1Pane

      # tms - tmux sessionizer
      bind O display-popup -E "tms"
      bind S display-popup -E "tms switch"

      # Split bindings
      bind - split-window -c "#{pane_current_path}"
      bind + split-window -h -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"

      run-shell ${pkgs.tmuxPlugins.battery}/share/tmux-plugins/battery/battery.tmux
    '';
  };
}
