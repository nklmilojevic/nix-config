local wezterm = require 'wezterm'

wezterm.on('trigger-lazygit', function(window, pane)
  window:perform_action(
    pane:split {
      direction = 'Right',
      label = 'Open Lazygit',
      args = { '/Users/nkl/.nix-profile/bin/lazygit' },
      size = 0.75,
    },
    pane
  )
end)
