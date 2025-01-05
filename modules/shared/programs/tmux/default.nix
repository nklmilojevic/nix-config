{pkgs, ...}: {
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
      {
        plugin = fuzzback;
        extraConfig = ''
          set -g @fuzzback-popup 1
          set -g @fuzzback-bind f
        '';
      }
      {
        plugin = mkTmuxPlugin {
          pluginName = "dracula";
          version = "v3.0.0";
          src = pkgs.fetchFromGitHub {
            owner = "dracula";
            repo = "tmux";
            rev = "v3.0.0";
            sha256 = "sha256-VY4PyaQRwTc6LWhPJg4inrQf5K8+bp0+eqRhR7+Iexk=";
          };
        };
        extraConfig = ''
          set -g @dracula-battery-label "󰁹"
          set -g @dracula-show-left-icon session
          set -g @dracula-kubernetes-context-colors "light_purple gray"
          set -g @dracula-battery-colors "pink gray"
          set -g @dracula-plugins "battery time kubernetes-context"

          set -g @dracula-time-format "%R"
          set -g @dracula-show-powerline true

          set -g @dracula-kubernetes-hide-user true
          set -g @dracula-kubernetes-context-label "󱃾 "
          set -g @dracula-colors "

          white='#f8f8f2'
          gray='#1e1f29'
          dark_gray='#282a36'
          light_purple='#bd93f9'
          dark_purple='#303242'
          cyan='#8be9fd'
          green='#50fa7b'
          orange='#ffb86c'
          red='#ff5555'
          pink='#ff79c6'
          yellow='#f1fa8c'

          "
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

      # Split bindings
      bind + split-window -c "#{pane_current_path}"
      bind - split-window -h -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"
    '';
  };
}
