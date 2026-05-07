local macbook = {
	{ "Firefox Developer Edition", nil, nil, hs.layout.maximized, nil, nil },
	{ "Safari", nil, nil, hs.layout.maximized, nil, nil },
	{ "Brave Origin Beta", nil, nil, hs.layout.maximized, nil, nil },
	{ "Ghostty", nil, nil, hs.layout.maximized, nil, nil },
	{ "WezTerm", nil, nil, hs.layout.maximized, nil, nil },
	{ "Slack", nil, nil, hs.layout.maximized, nil, nil },
	{ "Telegram", nil, nil, hs.layout.right50, nil, nil },
	{ "Messages", nil, nil, hs.layout.right50, nil, nil },
	{ "TablePro", nil, nil, nil, nil, hs.geometry.rect(200, 44, 1400, 986) },
	{ "Fantastical", nil, nil, hs.layout.maximized, nil, nil },
	{ "Things", nil, nil, nil, nil, hs.geometry.rect(354, 338, 935, 700) },
	{ "Spotify", nil, nil, hs.layout.maximized, nil, nil },
	{ "Discord", nil, nil, hs.layout.maximized, nil, nil },
	{ "Anybox", nil, nil, hs.layout.maximized, nil, nil },
	{ "Visual Studio Code", nil, nil, hs.layout.maximized, nil, nil },
	{ "Cursor", nil, nil, hs.layout.maximized, nil, nil },
	{ "Zed", nil, nil, hs.layout.maximized, nil, nil },
}

local dell = {
	{ "Firefox Developer Edition", nil, nil, hs.layout.left50, nil, nil },
	{ "Safari", nil, nil, hs.layout.left50, nil, nil },
	{ "Brave Origin Beta", nil, nil, hs.layout.left50, nil, nil },
	{ "Ghostty", nil, nil, hs.layout.right50, nil, nil },
	{ "WezTerm", nil, nil, hs.layout.right50, nil, nil },
	{ "Slack", nil, nil, hs.layout.left50, nil, nil },
	{ "Telegram", "Telegram", nil, hs.layout.right30, nil, nil },
	{ "Messages", nil, nil, hs.layout.right30, nil, nil },
	{ "TablePro", nil, nil, nil, nil, hs.geometry.rect(200, 44, 1400, 986) },
	{ "Fantastical", nil, nil, nil, nil, hs.geometry.rect(1090, 129, 1608, 1102) },
	{ "Things", nil, nil, nil, nil, hs.geometry.rect(588, 555, 935, 700) },
	{ "Spotify", nil, nil, nil, nil, hs.geometry.rect(1518, 312, 1800, 986) },
	{ "Discord", nil, nil, hs.layout.right50, nil, nil },
	{ "Anybox", nil, nil, nil, nil, hs.geometry.rect(965, 313, 1430, 1079) },
	{ "Visual Studio Code", nil, nil, hs.layout.left50, nil, nil },
	{ "Cursor", nil, nil, hs.layout.left50, nil, nil },
	{ "Zed", nil, nil, hs.layout.left50, nil, nil },
}

local function hasExternalScreen()
	local names = {}
	local external = false
	for _, screen in ipairs(hs.screen.allScreens()) do
		local name = screen:name() or "(unnamed)"
		table.insert(names, name)
		if not name:match("Built%-in") then
			external = true
		end
	end
	print("[layout] Detected screens: " .. table.concat(names, ", "))
	return external
end

local function applyLayout()
	if hasExternalScreen() then
		hs.layout.apply(dell)
		print("[layout] Applied dell layout")
	else
		hs.layout.apply(macbook)
		print("[layout] Applied macbook layout")
	end
end

-- Debounce: hot-plug and wake events often fire several times in quick
-- succession, and apps need a beat to settle before windows can be moved.
local pendingTimer = nil
local function scheduleLayout(delay)
	if pendingTimer then
		pendingTimer:stop()
	end
	pendingTimer = hs.timer.doAfter(delay or 2, function()
		pendingTimer = nil
		applyLayout()
	end)
end

screenWatcher = hs.screen.watcher.new(function()
	scheduleLayout(2)
end)
screenWatcher:start()

scheduleLayout(1)
