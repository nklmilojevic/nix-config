-- incident.io incidents in the macOS menubar.
--   API key: macOS Keychain (service "swiftbar-incident-io", account "api-key")
--            shared with the SwiftBar plugin during the pilot.
--   Click menubar -> menu of active + recent incidents.
--   Click an incident -> opens the Slack channel (deep-link) if available,
--                        otherwise the incident.io permalink.
--   Native notification fires for new incidents (after the first poll primes
--   the seen-ids set).

local sf = require("modules/sf-symbols")
local Keychain = require("modules/keychain")
local Seen = require("modules/seen")

local KEYCHAIN_SERVICE = "swiftbar-incident-io"
local KEYCHAIN_ACCOUNT = "api-key"
local POLL_SECONDS = 60
local INITIAL_REFRESH_DELAY_SECONDS = 50
local API_BASE = "https://api.incident.io"

local menubar = hs.menubar.new(true, "incident-io")
local activeIncidents = {}
local pastIncidents = {}
local dashboardURL = "https://app.incident.io"
local seen = Seen.new("incidentIoSeenIDs")
local lastBadgeState = nil
local pollTimer = nil
local initialRefreshTimer = nil
local refresh -- forward decl

local iconActive = sf.symbol("dot.radiowaves.left.and.right")
local iconIdle = sf.symbol("dot.radiowaves.left.and.right", { color = "gray" })
local iconMissing = sf.symbol("exclamationmark.triangle", { color = "gray" })

local function getToken()
	return Keychain.get(KEYCHAIN_SERVICE, KEYCHAIN_ACCOUNT)
end

local function setToken(token)
	return Keychain.set(KEYCHAIN_SERVICE, KEYCHAIN_ACCOUNT, token)
end

local function deleteToken()
	return Keychain.delete(KEYCHAIN_SERVICE, KEYCHAIN_ACCOUNT)
end

local function authHeaders()
	local token = getToken()
	if not token then
		return nil
	end
	return {
		["Accept"] = "application/json",
		["Authorization"] = "Bearer " .. token,
	}
end

local function setBadge()
	if not menubar then
		return
	end
	local hasToken = getToken() ~= nil
	local count = #activeIncidents
	local state = string.format("%s:%d", hasToken and "token" or "missing", count)
	if state == lastBadgeState then
		return
	end
	lastBadgeState = state

	local icon, isTemplate
	if not hasToken then
		icon, isTemplate = iconMissing, false
	elseif count > 0 then
		icon, isTemplate = iconActive, true
	else
		icon, isTemplate = iconIdle, false
	end

	if icon then
		menubar:setIcon(icon, isTemplate)
	else
		menubar:setIcon(nil)
	end

	if not hasToken then
		menubar:setTitle("")
	elseif count > 0 then
		menubar:setTitle(hs.styledtext.new(" " .. count, { font = { size = 13 } }))
	else
		menubar:setTitle("")
	end
end

local function slackOrPermalink(incident)
	local team = incident.slack_team_id
	local channel = incident.slack_channel_id
	if team and team ~= "" and channel and channel ~= "" then
		return string.format("slack://channel?team=%s&id=%s", team, channel)
	end
	return incident.permalink or dashboardURL
end

local function notifyOne(incident)
	local ref = incident.reference or ""
	local name = incident.name or "New incident"
	local status = incident.incident_status and incident.incident_status.name or ""
	local title = ref ~= "" and ("Incident " .. ref) or "New incident"
	if status ~= "" then
		title = title .. " (" .. status .. ")"
	end
	local url = slackOrPermalink(incident)

	hs.notify
		.new(function()
			hs.urlevent.openURL(url)
		end, {
			title = title,
			informativeText = name,
			autoWithdraw = true,
			hasActionButton = true,
			actionButtonTitle = "Open",
		})
		:send()
end

local function urlEncode(s)
	return (tostring(s or ""):gsub("([^%w%-_%.~])", function(c)
		return string.format("%%%02X", string.byte(c))
	end))
end

local function fetchDashboardURL(callback)
	local headers = authHeaders()
	if not headers then
		if callback then
			callback()
		end
		return
	end
	hs.http.doAsyncRequest(API_BASE .. "/v1/identity", "GET", nil, headers, function(status, body)
		if status == 200 and body then
			local ok, data = pcall(hs.json.decode, body)
			if ok and data and data.identity and data.identity.dashboard_url then
				dashboardURL = data.identity.dashboard_url
			end
		end
		if callback then
			callback()
		end
	end)
end

local function fetchIncidents(statusCategories, pageSize, callback)
	local headers = authHeaders()
	if not headers then
		callback({})
		return
	end
	local query = "?page_size=" .. pageSize
	for _, cat in ipairs(statusCategories) do
		query = query .. "&status_category[one_of]=" .. urlEncode(cat)
	end
	hs.http.doAsyncRequest(API_BASE .. "/v2/incidents" .. query, "GET", nil, headers, function(status, body)
		if status ~= 200 or not body then
			callback({})
			return
		end
		local ok, data = pcall(hs.json.decode, body)
		if not ok or not data or not data.incidents then
			callback({})
			return
		end
		callback(data.incidents)
	end)
end

local function buildIncidentItem(incident)
	local ref = incident.reference or ""
	local name = incident.name or "Untitled incident"
	local status = incident.incident_status and incident.incident_status.name
	local category = incident.incident_status and incident.incident_status.category
	local severity = incident.severity and incident.severity.name
	local short = #name > 50 and (name:sub(1, 47) .. "…") or name
	local label = ref ~= "" and (ref .. " " .. short) or short

	local style = nil
	if category == "live" then
		style = { color = { red = 0.9, green = 0.2, blue = 0.2, alpha = 1 } }
	elseif category == "triage" then
		style = { color = { red = 1.0, green = 0.6, blue = 0.0, alpha = 1 } }
	end

	local titleAttr = label
	if style then
		titleAttr = hs.styledtext.new(label, style)
	end

	local subParts = {}
	if severity then
		table.insert(subParts, "Severity: " .. severity)
	end
	if status then
		table.insert(subParts, "Status: " .. status)
	end

	local submenu = {}
	if #subParts > 0 then
		table.insert(submenu, { title = table.concat(subParts, " • "), disabled = true })
	end
	if incident.permalink and incident.permalink ~= "" then
		table.insert(submenu, {
			title = "Open in incident.io",
			fn = function()
				hs.urlevent.openURL(incident.permalink)
			end,
		})
	end
	local team = incident.slack_team_id
	local channel = incident.slack_channel_id
	if team and team ~= "" and channel and channel ~= "" then
		table.insert(submenu, {
			title = "Open Slack channel",
			fn = function()
				hs.urlevent.openURL(string.format("slack://channel?team=%s&id=%s", team, channel))
			end,
		})
	end
	if incident.call_url and incident.call_url ~= "" then
		table.insert(submenu, {
			title = "Join call",
			fn = function()
				hs.urlevent.openURL(incident.call_url)
			end,
		})
	end

	return {
		title = titleAttr,
		fn = function()
			hs.urlevent.openURL(slackOrPermalink(incident))
		end,
		menu = #submenu > 0 and submenu or nil,
	}
end

local function promptForToken()
	local btn, token = hs.dialog.textPrompt(
		"incident.io API Key",
		"Paste an incident.io API key (with read:incident scope).",
		"",
		"Save",
		"Cancel"
	)
	if btn == "Save" and token and token ~= "" then
		setToken(token)
		refresh()
	end
end

local function buildMenu()
	local items = {}

	if not getToken() then
		table.insert(items, { title = "incident.io API key not configured", disabled = true })
		table.insert(items, { title = "-" })
		table.insert(items, { title = "Set API key…", fn = promptForToken })
		table.insert(items, {
			title = "Get an API key…",
			fn = function()
				hs.urlevent.openURL("https://app.incident.io/settings/api-keys")
			end,
		})
		return items
	end

	table.insert(items, { title = "Active incidents", disabled = true })
	if #activeIncidents == 0 then
		table.insert(items, { title = "No active incidents", disabled = true })
	else
		for _, inc in ipairs(activeIncidents) do
			table.insert(items, buildIncidentItem(inc))
		end
	end

	table.insert(items, { title = "-" })
	table.insert(items, { title = "Recent incidents", disabled = true })
	if #pastIncidents == 0 then
		table.insert(items, { title = "No recent incidents", disabled = true })
	else
		for _, inc in ipairs(pastIncidents) do
			table.insert(items, buildIncidentItem(inc))
		end
	end

	table.insert(items, { title = "-" })
	table.insert(items, {
		title = "Refresh",
		fn = function()
			refresh()
		end,
	})
	table.insert(items, {
		title = "Open incident.io",
		fn = function()
			hs.urlevent.openURL(dashboardURL)
		end,
	})
	table.insert(items, { title = "-" })
	table.insert(items, {
		title = "Reset API key",
		fn = function()
			deleteToken()
			activeIncidents = {}
			pastIncidents = {}
			setBadge()
		end,
	})
	return items
end

refresh = function()
	-- Capture timers as upvalues so the hs.timer userdata isn't GC'd after the
	-- chunk returns.
	local _ = pollTimer or initialRefreshTimer
	if not getToken() then
		activeIncidents = {}
		pastIncidents = {}
		setBadge()
		return
	end

	fetchIncidents({ "live", "triage" }, 25, function(incidents)
		activeIncidents = incidents

		if seen.primed then
			for _, inc in ipairs(incidents) do
				if inc.id and not seen:has(inc.id) then
					notifyOne(inc)
					break
				end
			end
		end
		for _, inc in ipairs(incidents) do
			seen:mark(inc.id)
		end
		seen.primed = true
		seen:save()

		setBadge()
	end)

	fetchIncidents({ "closed", "learning", "canceled", "declined", "merged" }, 10, function(incidents)
		pastIncidents = incidents
	end)
end

if menubar then
	menubar:setMenu(buildMenu)
	setBadge()
	initialRefreshTimer = hs.timer.doAfter(INITIAL_REFRESH_DELAY_SECONDS, function()
		initialRefreshTimer = nil
		fetchDashboardURL(refresh)
		pollTimer = hs.timer.doEvery(POLL_SECONDS, refresh)
	end)
end
