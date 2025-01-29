local wezterm = require 'wezterm'

local M = {}

function M.setup(config)
  -- Terminal Fonts
  config.font = wezterm.font 'TX-02 Retina ExtraCondensed'
  config.font_size = 16
  config.bold_brightens_ansi_colors = 'BrightAndBold'

  -- Tab Fonts
  config.window_frame = {
    font = wezterm.font 'TX-02 Retina ExtraCondensed',
    font_size = 16,
  }

  config.font_rules = {
    {
      intensity = 'Bold',
      font = wezterm.font {
        family = 'TX-02',
        stretch = "Condensed",
        weight = "DemiBold",
      },
    },
    {
      intensity = 'Half',
      font = wezterm.font {
        family = 'TX-02',
        stretch = "Condensed",
        weight = "DemiBold",
      },
    },
    {
      intensity = 'Normal',
      italic = true,
      font = wezterm.font_with_fallback {
        family = 'TX-02',
        style = "Oblique",
        stretch = "Condensed",
        italic = true,
      },
    },

  }
end

return M
