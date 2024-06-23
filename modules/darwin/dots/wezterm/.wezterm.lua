local wezterm = require("wezterm")

act = wezterm.action

local config = {
    font = wezterm.font_with_fallback({"PragmataProMonoLiga Nerd Font"}),
    -- font = wezterm.font_with_fallback({ "BerkeleyMono Nerd Font" }),
    window_decorations = "RESIZE",
    font_size = 16.0,
    color_scheme = "Dracula",
    enable_tab_bar = true,
    tab_bar_at_bottom = true,
    use_fancy_tab_bar = false,
    send_composed_key_when_left_alt_is_pressed = true,
    send_composed_key_when_right_alt_is_pressed = true,
    window_padding = {
        left = 10,
        right = 10,
        top = 10,
        bottom = 10
    },
    front_end = "WebGpu"
}

wezterm.on("update-right-status", function(window, pane)
    local name = window:active_key_table()
    if name then
        name = "TABLE: " .. name
    end
    window:set_right_status(name or "")
end)

config.leader = {
    key = "Space",
    mods = "CTRL",
    timeout_milliseconds = 1000
}
config.keys = {{
    key = "+",
    mods = "LEADER",
    action = wezterm.action.SplitHorizontal({
        domain = "CurrentPaneDomain"
    })
}, {
    key = "-",
    mods = "LEADER",
    action = wezterm.action.SplitVertical({
        domain = "CurrentPaneDomain"
    })
}, {
    key = "LeftArrow",
    mods = "LEADER",
    action = wezterm.action.ActivateTabRelative(-1)
}, {
    key = "RightArrow",
    mods = "LEADER",
    action = wezterm.action.ActivateTabRelative(1)
}, {
    key = "LeftArrow",
    mods = "OPT",
    action = wezterm.action({
        SendString = "\x1bb"
    })
}, -- Make Option-Right equivalent to Alt-f; forward-word
{
    key = "RightArrow",
    mods = "OPT",
    action = wezterm.action({
        SendString = "\x1bf"
    })
}, {
    key = "r",
    mods = "LEADER",
    action = act.ActivateKeyTable({
        name = "resize_pane",
        one_shot = false
    })
}, {
    key = "a",
    mods = "LEADER",
    action = act.ActivateKeyTable({
        name = "activate_pane",
        timeout_milliseconds = 1000
    })
}}

config.key_tables = {
    resize_pane = {{
        key = "LeftArrow",
        action = act.AdjustPaneSize({"Left", 1})
    }, {
        key = "h",
        action = act.AdjustPaneSize({"Left", 1})
    }, {
        key = "RightArrow",
        action = act.AdjustPaneSize({"Right", 1})
    }, {
        key = "l",
        action = act.AdjustPaneSize({"Right", 1})
    }, {
        key = "UpArrow",
        action = act.AdjustPaneSize({"Up", 1})
    }, {
        key = "k",
        action = act.AdjustPaneSize({"Up", 1})
    }, {
        key = "DownArrow",
        action = act.AdjustPaneSize({"Down", 1})
    }, {
        key = "j",
        action = act.AdjustPaneSize({"Down", 1})
    }, {
        key = "Escape",
        action = "PopKeyTable"
    }},
    activate_pane = {{
        key = "LeftArrow",
        action = act.ActivatePaneDirection("Left")
    }, {
        key = "h",
        action = act.ActivatePaneDirection("Left")
    }, {
        key = "RightArrow",
        action = act.ActivatePaneDirection("Right")
    }, {
        key = "l",
        action = act.ActivatePaneDirection("Right")
    }, {
        key = "UpArrow",
        action = act.ActivatePaneDirection("Up")
    }, {
        key = "k",
        action = act.ActivatePaneDirection("Up")
    }, {
        key = "DownArrow",
        action = act.ActivatePaneDirection("Down")
    }, {
        key = "j",
        action = act.ActivatePaneDirection("Down")
    }}
}

config.colors = {
    tab_bar = {
        background = "#171720",
        inactive_tab = {
            bg_color = "#2B2B41",
            fg_color = "#808080"
        },
        new_tab = {
            bg_color = "#171720",
            fg_color = "#808080"
        }
    }
}

config.unix_domains = {{
    name = "unix"
}}
config.default_gui_startup_args = {"connect", "unix"}

config.mux_env_remove = {"SSH_CLIENT", "SSH_CONNECTION"}

return config
