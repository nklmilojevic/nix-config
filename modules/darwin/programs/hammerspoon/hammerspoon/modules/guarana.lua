-- Caffeinate menubar toggle (named after guarana, the caffeine bean).
--   Click   -> open menu (toggle is the first item, then timed presets)
--   Hyper+I -> direct toggle, no menu

local sf = require("modules/sf-symbols")

local hyper = { "ctrl", "alt", "cmd", "shift" }
local SLEEP_TYPE = "displayIdle"

local menubar = hs.menubar.new(true, "guarana")
local timedRevert = nil
local timedRevertEnd = nil
local syncTimer = nil

local cupAwake = sf.symbol("cup.and.saucer.fill")
local cupSleepy = sf.symbol("cup.and.saucer.fill", { color = "gray" })

local function setIcon(awake)
	if not menubar then
		return
	end
	local icon = awake and cupAwake or cupSleepy
	if icon then
		menubar:setTitle("")
		menubar:setIcon(icon, awake) -- template only when awake (so it stays gray when sleepy)
	else
		menubar:setIcon(nil)
		menubar:setTitle(hs.styledtext.new(awake and "◉" or "◌", {
			font = { size = 16 },
		}))
	end
end

local function isAwake()
	return hs.caffeinate.get(SLEEP_TYPE) == true
end

local function clearRevert()
	if timedRevert then
		timedRevert:stop()
		timedRevert = nil
	end
	timedRevertEnd = nil
end

local function setAwake(awake, durationSeconds)
	clearRevert()
	hs.caffeinate.set(SLEEP_TYPE, awake, true)
	if awake and durationSeconds then
		timedRevertEnd = os.time() + durationSeconds
		timedRevert = hs.timer.doAfter(durationSeconds, function()
			timedRevert = nil
			timedRevertEnd = nil
			hs.caffeinate.set(SLEEP_TYPE, false, true)
			setIcon(false)
		end)
	end
	setIcon(awake)
end

local function toggle()
	setAwake(not isAwake())
end

local function buildMenu()
	local items = {
		{ title = isAwake() and "Go to sleep" or "Wake up", fn = toggle },
		{ title = "-" },
		{ title = "Stay awake for 30 minutes", fn = function() setAwake(true, 30 * 60) end },
		{ title = "Stay awake for 1 hour",     fn = function() setAwake(true, 60 * 60) end },
		{ title = "Stay awake for 2 hours",    fn = function() setAwake(true, 2 * 60 * 60) end },
		{ title = "Stay awake indefinitely",   fn = function() setAwake(true) end },
	}
	if timedRevertEnd then
		local remaining = timedRevertEnd - os.time()
		if remaining > 0 then
			table.insert(items, { title = "-" })
			table.insert(items, {
				title = string.format("Auto-sleep in %d min", math.ceil(remaining / 60)),
				disabled = true,
			})
		end
	end
	return items
end

if menubar then
	menubar:setMenu(buildMenu)
	setIcon(isAwake())
	-- Periodic resync catches state drift if anything else (the system, another
	-- app) flips the caffeinate state out from under us.
	syncTimer = hs.timer.doEvery(5, function()
		setIcon(isAwake())
	end)
end

hs.hotkey.bind(hyper, "i", toggle)
