-- Cmd+Shift+<key>: focus Ghostty, open a split, run a command.
-- Right split (cmd+d) for full-height tools, bottom split (cmd+shift+d) for yazi.

local function launchInGhosttySplit(splitMods, command)
	return function()
		local ghostty = hs.application.find("Ghostty")
		if not ghostty then
			return
		end
		ghostty:activate()
		hs.timer.doAfter(0.1, function()
			hs.eventtap.keyStroke(splitMods, "d")
			hs.timer.doAfter(0.3, function()
				hs.eventtap.keyStrokes(command)
				hs.eventtap.keyStroke({}, "return")
			end)
		end)
	end
end

local launchers = {
	{ key = "c", splitMods = { "cmd" },            command = "ccc" },
	{ key = "g", splitMods = { "cmd" },            command = "lg" },
	{ key = "y", splitMods = { "cmd", "shift" },   command = "yazi" },
}

for _, l in ipairs(launchers) do
	hs.hotkey.bind({ "cmd", "shift" }, l.key, launchInGhosttySplit(l.splitMods, l.command))
end
