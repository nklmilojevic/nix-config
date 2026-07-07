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

-- Fingerprint of the current display arrangement, used both to wait for the
-- configuration to stop changing and to skip redundant re-applies on wake.
local function screenSignature()
	local parts = {}
	for _, screen in ipairs(hs.screen.allScreens()) do
		local f = screen:fullFrame()
		parts[#parts + 1] = string.format("%s:%d,%d,%d,%d", screen:name() or "?", f.x, f.y, f.w, f.h)
	end
	table.sort(parts)
	local primary = hs.screen.primaryScreen()
	return table.concat(parts, "|") .. "#" .. (primary and primary:name() or "?")
end

local lastAppliedSig = nil

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
	lastAppliedSig = screenSignature()
	step()
end

-- A layout applied while the session is locked is wasted: macOS restores
-- its own remembered window positions at unlock and clobbers ours (observed
-- when plugging in the dock wakes the machine). Defer until unlock instead.
local function sessionLocked()
	local props = hs.caffeinate.sessionProperties()
	-- Key is absent while unlocked; bridges as true (or 1) while locked.
	return not not (props and props["CGSSessionScreenIsLocked"])
end

local deferred = false
local deferredForce = false

-- Wait until the display arrangement is identical across two consecutive
-- polls before applying: wake and hot-plug events fire while macOS is still
-- bringing screens online, and a debounce timer armed before sleep fires
-- immediately on wake, when the screen list is stale. Without the force
-- flag, skip if the settled arrangement already matches the last apply —
-- wake events also fire on plain display sleep where nothing changed.
local SETTLE_INTERVAL = 1
local SETTLE_MAX_POLLS = 15

local settleTimer = nil
local function applyWhenSettled(force)
	if settleTimer then
		settleTimer:stop()
	end
	local lastSig = screenSignature()
	local polls = 0
	settleTimer = hs.timer.doEvery(SETTLE_INTERVAL, function()
		polls = polls + 1
		local sig = screenSignature()
		if sig ~= lastSig and polls < SETTLE_MAX_POLLS then
			lastSig = sig
			return
		end
		settleTimer:stop()
		settleTimer = nil
		if sig ~= lastSig then
			print("[layout] Screens never settled, applying anyway")
		end
		if sessionLocked() then
			deferred = true
			deferredForce = deferredForce or force
			print("[layout] Session locked, deferring until unlock")
			return
		end
		if not force and sig == lastAppliedSig then
			print("[layout] Screens unchanged since last apply, skipping")
			return
		end
		applyLayout()
	end)
end

-- Debounce: hot-plug and wake events often fire several times in quick
-- succession, and apps need a beat to settle before windows can be moved.
local pendingTimer = nil
local pendingForce = false
local function scheduleLayout(delay, force)
	pendingForce = pendingForce or force or false
	if pendingTimer then
		pendingTimer:stop()
	end
	pendingTimer = hs.timer.doAfter(delay or 2, function()
		pendingTimer = nil
		local f = pendingForce
		pendingForce = false
		applyWhenSettled(f)
	end)
end

-- Screen watcher events mean the arrangement really changed (or bounced),
-- so always re-apply even if the settled arrangement matches the last one:
-- macOS may have shuffled windows during a disconnect/reconnect bounce.
screenWatcher = hs.screen.watcher.new(function()
	scheduleLayout(2, true)
end)
screenWatcher:start()

-- Screen-parameter notifications can be dropped entirely when the display
-- hot-plug is what wakes the machine, so wake/unlock events also trigger a
-- (non-forced) apply. Unlock runs after macOS has finished restoring its
-- own remembered window positions, so a deferred apply lands last and wins.
layoutCaffeinateWatcher = hs.caffeinate.watcher.new(function(event)
	if event == hs.caffeinate.watcher.screensDidUnlock and deferred then
		deferred = false
		local force = deferredForce
		deferredForce = false
		scheduleLayout(2, force)
	elseif
		event == hs.caffeinate.watcher.systemDidWake
		or event == hs.caffeinate.watcher.screensDidWake
		or event == hs.caffeinate.watcher.screensDidUnlock
	then
		scheduleLayout(2, false)
	end
end)
layoutCaffeinateWatcher:start()

scheduleLayout(1, true)
