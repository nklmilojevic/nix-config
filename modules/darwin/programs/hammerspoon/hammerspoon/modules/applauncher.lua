-- Launch or focus apps with single-letter hotkeys.
-- Adapted from the AppLauncher Spoon by Mathias Jean Johansen (ISC).

local hyper = { "ctrl", "alt", "cmd", "shift" }

local hotkeys = {
	c = "Slack",
	v = "Visual Studio Code",
	n = "FSNotes",
	m = "Mail",
	z = "Messages",
	f = "Brave Origin",
	r = "Ghostty",
	t = "Telegram",
	d = "Discord",
	s = "Spotify",
	l = "Linear",
	h = "Home Assistant",
	w = "WhatsApp",
}

for key, app in pairs(hotkeys) do
	hs.hotkey.bind(hyper, key, function()
		hs.application.launchOrFocus(app)
	end)
end
