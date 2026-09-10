-- Guarana: menubar cup that keeps the Mac awake.
-- Click to prevent display + idle sleep; click again to allow sleep.

local sf = require("modules/sf-symbols")

local SLEEP_TYPE = "displayIdle"
local SETTINGS_KEY = "guarana.awake"

local menubar = hs.menubar.new(true, "guarana")
local cupAwake = sf.symbol("cup.and.saucer.fill")
local cupSleepy = sf.symbol("cup.and.saucer.fill", { color = "gray" })

local function isAwake()
	return hs.caffeinate.get(SLEEP_TYPE) == true
end

local function setIcon(awake)
	if not menubar then
		return
	end
	local icon = awake and cupAwake or cupSleepy
	if icon then
		menubar:setTitle("")
		menubar:setIcon(icon, awake)
	else
		menubar:setIcon(nil)
		menubar:setTitle(hs.styledtext.new(awake and "◉" or "◌", {
			font = { size = 16 },
		}))
	end
	menubar:setTooltip(awake and "Guarana: keeping awake" or "Guarana: allowing sleep")
end

local function setAwake(awake)
	hs.caffeinate.set(SLEEP_TYPE, awake, true)
	hs.settings.set(SETTINGS_KEY, awake)
	setIcon(awake)
end

local function toggle()
	setAwake(not isAwake())
end

if menubar then
	menubar:setClickCallback(function()
		toggle()
	end)
	-- hs.reload() drops caffeinate assertions; restore the last requested state.
	if hs.settings.get(SETTINGS_KEY) == true then
		setAwake(true)
	else
		setIcon(false)
	end
end
