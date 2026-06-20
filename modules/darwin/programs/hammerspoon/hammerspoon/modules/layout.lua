-- Applied when screens change (dock/undock, wake). Positioning is spread
-- across event-loop ticks with a capped accessibility timeout: a synchronous
-- hs.layout.apply sweep let one unresponsive app block the main thread for
-- its full AX timeout, which stalled SkyRocket's mouse eventtap and froze
-- clicking system-wide.

local rect = hs.geometry.rect

local macbook = {
	{ app = "Firefox Developer Edition", unit = hs.layout.maximized },
	{ app = "Safari", unit = hs.layout.maximized },
	{ app = "Brave Origin", unit = hs.layout.maximized },
	{ app = "Ghostty", unit = hs.layout.maximized },
	{ app = "WezTerm", unit = hs.layout.maximized },
	{ app = "Slack", unit = hs.layout.maximized },
	{ app = "Telegram", unit = hs.layout.right50 },
	{ app = "Messages", unit = hs.layout.right50 },
	{ app = "TablePro", frame = rect(200, 44, 1400, 986) },
	{ app = "Fantastical", unit = hs.layout.maximized },
	{ app = "Things", frame = rect(354, 338, 935, 700) },
	{ app = "Spotify", unit = hs.layout.maximized },
	{ app = "Discord", unit = hs.layout.maximized },
	{ app = "Anybox", unit = hs.layout.maximized },
	{ app = "Visual Studio Code", unit = hs.layout.maximized },
	{ app = "Cursor", unit = hs.layout.maximized },
	{ app = "Zed", unit = hs.layout.maximized },
}

local dell = {
	{ app = "Firefox Developer Edition", unit = hs.layout.left50 },
	{ app = "Safari", unit = hs.layout.left50 },
	{ app = "Brave Origin", unit = hs.layout.left50 },
	{ app = "Ghostty", unit = hs.layout.right50 },
	{ app = "WezTerm", unit = hs.layout.right50 },
	{ app = "Slack", unit = hs.layout.left50 },
	{ app = "Telegram", unit = hs.layout.right30 },
	{ app = "Messages", unit = hs.layout.right30 },
	{ app = "TablePro", frame = rect(200, 44, 1400, 986) },
	{ app = "Fantastical", frame = rect(1090, 129, 1608, 1102) },
	{ app = "Things", frame = rect(588, 555, 935, 700) },
	{ app = "Spotify", frame = rect(1518, 312, 1800, 986) },
	{ app = "Discord", unit = hs.layout.right50 },
	{ app = "Anybox", frame = rect(965, 313, 1430, 1079) },
	{ app = "Visual Studio Code", unit = hs.layout.left50 },
	{ app = "Cursor", unit = hs.layout.left50 },
	{ app = "Zed", unit = hs.layout.left50 },
}

local AX_TIMEOUT = 1 -- seconds; system default is ~6s per blocked AX call

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

local function positionApp(entry)
	local app = hs.application.get(entry.app)
	if not app then
		return
	end
	local ax = hs.axuielement.applicationElement(app)
	if ax then
		ax:setTimeout(AX_TIMEOUT)
	end
	local primary = hs.screen.primaryScreen()
	for _, win in ipairs(app:visibleWindows()) do
		if win:isStandard() then
			if entry.unit then
				win:move(entry.unit, primary, true, 0)
			elseif entry.frame then
				win:setFrame(entry.frame, 0)
			end
		end
	end
end

local queue = {}
local stepTimer = nil

local function step()
	local entry = table.remove(queue, 1)
	if not entry then
		stepTimer = nil
		print("[layout] Done")
		return
	end
	local ok, err = pcall(positionApp, entry)
	if not ok then
		print("[layout] Error positioning " .. entry.app .. ": " .. tostring(err))
	end
	stepTimer = hs.timer.doAfter(0.05, step)
end

local function applyLayout()
	local layout
	if hasExternalScreen() then
		layout = dell
		print("[layout] Applying dell layout")
	else
		layout = macbook
		print("[layout] Applying macbook layout")
	end
	if stepTimer then
		stepTimer:stop()
	end
	queue = {}
	for _, entry in ipairs(layout) do
		queue[#queue + 1] = entry
	end
	step()
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
