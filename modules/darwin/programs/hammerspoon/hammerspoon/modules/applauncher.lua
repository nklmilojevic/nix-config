hs.loadSpoon("AppLauncher")

local hyper = { "ctrl", "alt", "cmd", "shift" }

spoon.AppLauncher.modifiers = hyper

hs.spoons.use("AppLauncher", {
    hotkeys = {
        c = "Slack",
        v = "Cursor",
        n = "NotePlan",
        m = "Mail",
        z = "Messages",
        f = "Brave Browser",
        i = "IntelliJ IDEA",
        r = "Ghostty",
        t = "Telegram",
        d = "Discord",
        s = "Spotify",
        l = "Linear",
        h = "Home Assistant",
    },
})
