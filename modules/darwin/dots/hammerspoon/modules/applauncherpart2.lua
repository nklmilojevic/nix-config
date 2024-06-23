hs.loadSpoon("AppLauncher")

local hyper = { "ctrl", "alt", "cmd", "shift" }

spoon.AppLauncher.modifiers = hyper

hs.spoons.use("AppLauncher", {
    hotkeys = {
        c = "Slack",
        v = "Visual Studio Code",
        n = "NotePlan",
        m = "Mail",
        z = "Messages",
        f = "Brave Browser",
        i = "IntelliJ IDEA",
        r = "WezTerm",
        s = "Spotify",
        t = "Telegram",
        d = "Discord",
    },
})
