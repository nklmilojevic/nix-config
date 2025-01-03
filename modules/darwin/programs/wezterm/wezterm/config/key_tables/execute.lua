local wezterm = require 'wezterm'
local act = wezterm.action
local M = {}

function M.setup(config)
  config.key_tables = config.key_tables or {}

  -- Command mode key table
  config.key_tables['execute_mode'] = {
    {
      mods = 'NONE',
      key = 'l',
      action = act.EmitEvent 'trigger-lazygit',
    },
    -- Cancel the mode by pressing escape
    { key = 'q', action = 'PopKeyTable' },
  }
end

return M
