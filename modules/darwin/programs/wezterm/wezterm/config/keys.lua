local wezterm = require 'wezterm'

local act = wezterm.action
local M = {}

M.cmd_mode = 'CMD'
M.leader = 'LEADER'

function M.setup(config)
  config.send_composed_key_when_left_alt_is_pressed = true
  config.send_composed_key_when_right_alt_is_pressed = true
  config.use_dead_keys = false

  config.leader = { key = 'Space', mods = 'CTRL', timeout_milliseconds = 1000 }

  config.keys = {
    -- Splits
    {
      mods = M.leader,
      key = '+',
      action = act.SplitHorizontal { domain = 'CurrentPaneDomain' },
    },
    {
      mods = "CMD",
      key = 'd',
      action = act.SplitVertical { domain = 'CurrentPaneDomain' },
    },
    {
      mods = "CMD|SHIFT",
      key = 'd',
      action = act.SplitHorizontal { domain = 'CurrentPaneDomain' },
    },
    {
      mods = M.leader,
      key = '-',
      action = act.SplitVertical { domain = 'CurrentPaneDomain' },
    },

    -- Close pane
    { mods = M.leader, key = 'x', action = act.CloseCurrentPane { confirm = false } },

    -- Modes
    {
      mods = M.leader,
      key = 'r',
      action = act.ActivateKeyTable {
        name = 'resize_mode',
        one_shot = false,
      },
    },
    {
      mods = M.leader,
      key = 'a',
      action = act.ActivateKeyTable {
        name = 'execute_mode',
        timeout_milliseconds = 1000,
      },
    },
    { key = "c", mods = "LEADER", action = act.ActivateCopyMode },
    -- Tab navigation
    { mods = M.leader, key = 'LeftArrow', action = act.ActivateTabRelative(-1) },
    { mods = M.leader, key = 'RightArrow', action = act.ActivateTabRelative(1) },
    { mods = M.leader,  key = "l", action = act.EmitEvent('trigger-lazygit') },
    -- Alt arrow navigation
    { mods = 'OPT', key = 'LeftArrow', action = act.SendString('\x1bb') },
    { mods = 'OPT', key = 'RightArrow', action = act.SendString('\x1bf') },

    -- Clear scrollback
    { mods = M.cmd_mode, key = 'k', action = act.ClearScrollback 'ScrollbackAndViewport' },
    { mods = M.cmd_mode, key = 't', action = act.SpawnTab 'CurrentPaneDomain' },
  }
end

return M
