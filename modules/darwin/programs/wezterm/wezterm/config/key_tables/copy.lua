local wezterm = require 'wezterm'
local act = wezterm.action
local M = {}

function M.setup(config)
  config.key_tables = config.key_tables or {}

  config.key_tables['copy_mode'] = {
    -- Basic motions
    { mods = 'NONE',      key = 'h',     action = act.CopyMode 'MoveLeft' },
    { mods = 'NONE',      key = 'j',     action = act.CopyMode 'MoveDown' },
    { mods = 'NONE',      key = 'k',     action = act.CopyMode 'MoveUp' },
    { mods = 'NONE',      key = 'l',     action = act.CopyMode 'MoveRight' },

    -- Arrow keys
    { key = 'LeftArrow',  mods = 'NONE', action = act.CopyMode 'MoveLeft' },
    { key = 'RightArrow', mods = 'NONE', action = act.CopyMode 'MoveRight' },
    { key = 'UpArrow',    mods = 'NONE', action = act.CopyMode 'MoveUp' },
    { key = 'DownArrow',  mods = 'NONE', action = act.CopyMode 'MoveDown' },
    { key = 'LeftArrow',  mods = 'ALT',  action = act.CopyMode 'MoveBackwardWord' },
    { key = 'RightArrow', mods = 'ALT',  action = act.CopyMode 'MoveForwardWord' },

    -- Word motions
    { mods = 'NONE',      key = 'w',     action = act.CopyMode 'MoveForwardWord' },
    { mods = 'NONE',      key = 'b',     action = act.CopyMode 'MoveBackwardWord' },
    { mods = 'NONE',      key = 'e',     action = act.CopyMode 'MoveForwardWordEnd' },

    -- Line motions
    { mods = 'NONE',      key = '0',     action = act.CopyMode 'MoveToStartOfLine' },
    { mods = 'NONE',      key = '^',     action = act.CopyMode 'MoveToStartOfLineContent' },
    { mods = 'NONE',      key = '$',     action = act.CopyMode 'MoveToEndOfLineContent' },

    -- Buffer motions
    { mods = 'NONE',      key = 'g',     action = act.CopyMode 'MoveToScrollbackTop' },
    { mods = 'NONE',      key = 'G',     action = act.CopyMode 'MoveToScrollbackBottom' },

    -- Find char motions
    {
      mods = 'NONE',
      key = 'f',
      action = act.CopyMode { JumpForward = { prev_char = false } },
    },
    {
      mods = 'SHIFT',
      key = 'F',
      action = act.CopyMode { JumpBackward = { prev_char = false } },
    },
    {
      mods = 'NONE',
      key = 't',
      action = act.CopyMode { JumpForward = { prev_char = true } },
    },
    {
      mods = 'SHIFT',
      key = 'T',
      action = act.CopyMode { JumpBackward = { prev_char = true } },
    },
    { mods = 'NONE',  key = ';', action = act.CopyMode 'JumpAgain' },
    { mods = 'NONE',  key = ',', action = act.CopyMode 'JumpReverse' },

    -- Visual mode selections
    { mods = 'NONE',  key = 'v', action = act.CopyMode { SetSelectionMode = 'Cell' } },
    { mods = 'SHIFT', key = 'V', action = act.CopyMode { SetSelectionMode = 'Line' } },
    { mods = 'CTRL',  key = 'v', action = act.CopyMode { SetSelectionMode = 'Block' } },

    -- Selection manipulation
    { mods = 'NONE',  key = 'o', action = act.CopyMode 'MoveToSelectionOtherEnd' },
    { mods = 'SHIFT', key = 'O', action = act.CopyMode 'MoveToSelectionOtherEndHoriz' },

    -- Yanking
    {
      mods = 'NONE',
      key = 'y',
      action = act.Multiple {
        { CopyTo = 'ClipboardAndPrimarySelection' },
        { CopyMode = 'Close' },
      },
    },

    -- Scrolling
    { mods = 'CTRL',  key = 'b',     action = act.CopyMode 'PageUp' },
    { mods = 'CTRL',  key = 'f',     action = act.CopyMode 'PageDown' },
    { mods = 'CTRL',  key = 'd',     action = act.CopyMode { MoveByPage = 0.5 } },
    { mods = 'CTRL',  key = 'u',     action = act.CopyMode { MoveByPage = -0.5 } },

    -- Mode exit
    { mods = 'NONE',  key = 'q',     action = act.CopyMode 'Close' },

    -- Viewport motions
    { mods = 'NONE',  key = 'Enter', action = act.CopyMode 'MoveToStartOfNextLine' },
    { mods = 'SHIFT', key = 'H',     action = act.CopyMode 'MoveToViewportTop' },
    { mods = 'SHIFT', key = 'M',     action = act.CopyMode 'MoveToViewportMiddle' },
    { mods = 'SHIFT', key = 'L',     action = act.CopyMode 'MoveToViewportBottom' },
  }
end

return M
