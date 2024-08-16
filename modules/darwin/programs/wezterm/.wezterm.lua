local wezterm = require("wezterm")
local act = wezterm.action

local function create_keybind(key, mods, action)
    return { key = key, mods = mods, action = action }
end

local config = {
    font = wezterm.font_with_fallback({ "PragmataProMonoLiga Nerd Font" }),
    font_size = 16.0,
    color_scheme = "Dracula",
    window_decorations = "RESIZE",
    window_padding = {
        left = 10,
        right = 10,
        top = 10,
        bottom = 10,
    },

    enable_tab_bar = true,
    tab_bar_at_bottom = true,
    use_fancy_tab_bar = false,
    show_new_tab_button_in_tab_bar = false,

    send_composed_key_when_left_alt_is_pressed = true,
    send_composed_key_when_right_alt_is_pressed = true,
    front_end = "WebGpu",

    leader = { key = "Space", mods = "CTRL", timeout_milliseconds = 1000 },

    colors = {
        tab_bar = {
            background = "#1E1F29",
            inactive_tab = { bg_color = "#1E1F29", fg_color = "#808080" },
            new_tab = { bg_color = "#1E1F29", fg_color = "#808080" },
        },
    },

    unix_domains = { { name = "unix" } },
    default_gui_startup_args = { "connect", "unix" },
    mux_env_remove = { "SSH_CLIENT", "SSH_CONNECTION" },
}

config.keys = {
    create_keybind("+", "LEADER", act.SplitHorizontal({ domain = "CurrentPaneDomain" })),
    create_keybind("-", "LEADER", act.SplitVertical({ domain = "CurrentPaneDomain" })),
    create_keybind("LeftArrow", "LEADER", act.ActivateTabRelative(-1)),
    create_keybind("RightArrow", "LEADER", act.ActivateTabRelative(1)),
    create_keybind("LeftArrow", "OPT", act.SendString("\x1bb")),
    create_keybind("RightArrow", "OPT", act.SendString("\x1bf")),
    create_keybind("r", "LEADER", act.ActivateKeyTable({ name = "resize_pane", one_shot = false })),
    create_keybind("k", "CMD", act.ClearScrollback("ScrollbackAndViewport")),
    create_keybind("a", "LEADER", act.ActivateKeyTable({ name = "activate_pane", timeout_milliseconds = 1000 })),
}

config.key_tables = {
    resize_pane = {
        create_keybind("LeftArrow", "", act.AdjustPaneSize({ "Left", 1 })),
        create_keybind("h", "", act.AdjustPaneSize({ "Left", 1 })),
        create_keybind("RightArrow", "", act.AdjustPaneSize({ "Right", 1 })),
        create_keybind("l", "", act.AdjustPaneSize({ "Right", 1 })),
        create_keybind("UpArrow", "", act.AdjustPaneSize({ "Up", 1 })),
        create_keybind("k", "", act.AdjustPaneSize({ "Up", 1 })),
        create_keybind("DownArrow", "", act.AdjustPaneSize({ "Down", 1 })),
        create_keybind("j", "", act.AdjustPaneSize({ "Down", 1 })),
        create_keybind("Escape", "", "PopKeyTable"),
    },
    activate_pane = {
        create_keybind("LeftArrow", "", act.ActivatePaneDirection("Left")),
        create_keybind("h", "", act.ActivatePaneDirection("Left")),
        create_keybind("RightArrow", "", act.ActivatePaneDirection("Right")),
        create_keybind("l", "", act.ActivatePaneDirection("Right")),
        create_keybind("UpArrow", "", act.ActivatePaneDirection("Up")),
        create_keybind("k", "", act.ActivatePaneDirection("Up")),
        create_keybind("DownArrow", "", act.ActivatePaneDirection("Down")),
        create_keybind("j", "", act.ActivatePaneDirection("Down")),
    },
}

wezterm.on("update-right-status", function(window, pane)
    local name = window:active_key_table()
    window:set_right_status(name and ("TABLE: " .. name) or "")
end)

return config
