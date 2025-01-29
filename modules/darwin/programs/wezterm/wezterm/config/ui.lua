local M = {}

function M.setup(config)
  config.audible_bell = 'Disabled'
  config.window_decorations = 'RESIZE'
  config.enable_kitty_graphics = true
  config.cursor_blink_ease_in = 'Constant'
  config.cursor_blink_ease_out = 'Constant'

  config.color_scheme = 'Catppuccin Mocha'
  config.scrollback_lines = 10000
  config.tab_bar_at_bottom = true
  config.window_padding = {
    left = '10',
    right = '10',
    top = '10',
    bottom = '10',
  }
end

return M
