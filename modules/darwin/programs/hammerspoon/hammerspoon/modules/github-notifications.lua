-- GitHub notifications in the macOS menubar.
--   Token: macOS Keychain (service "swiftbar-github", account "token")
--          shared with the SwiftBar plugin so no re-auth needed during the pilot.
--   Click menubar -> menu of unread notifications.
--   Click an item -> mark thread read + open on github.com.
--   New-item native notification fires once per poll cycle (after the first poll
--   primes the seen-ids set, so reloading Hammerspoon doesn't spam you).

local sf = require("modules/sf-symbols")

local KEYCHAIN_SERVICE = "swiftbar-github"
local KEYCHAIN_ACCOUNT = "token"
local POLL_SECONDS = 60
local API_LIST = "https://api.github.com/notifications?per_page=25"

local menubar = hs.menubar.new()
-- bellActive: rendered in default color, displayed as template so macOS
-- repaints it to the menubar foreground (white in dark menubar).
-- bellIdle/bellMissing: rendered in fixed gray, displayed non-template.
local bellActive = sf.symbol("bell.fill")
local bellIdle = sf.symbol("bell.fill", { color = "gray" })
local bellMissing = sf.symbol("bell.slash", { color = "gray" })
local notifications = {}
local seenIDs = {}
local primed = false
local pollTimer = nil
local refresh -- forward decl

local REASON_TEXT = {
	assign = "assigned",
	author = "author",
	comment = "commented",
	mention = "mentioned",
	review_requested = "review requested",
	state_change = "state changed",
	subscribed = "subscribed",
	team_mention = "team mentioned",
}

local function shellEscape(s)
	return "'" .. (s or ""):gsub("'", "'\\''") .. "'"
end

local function getToken()
	local out, ok = hs.execute(string.format(
		"security find-generic-password -s %s -a %s -w 2>/dev/null",
		shellEscape(KEYCHAIN_SERVICE), shellEscape(KEYCHAIN_ACCOUNT)
	))
	if not ok or not out then return nil end
	out = out:gsub("%s+$", "")
	return out ~= "" and out or nil
end

local function setToken(token)
	hs.execute(string.format(
		"security add-generic-password -s %s -a %s -w %s -U",
		shellEscape(KEYCHAIN_SERVICE), shellEscape(KEYCHAIN_ACCOUNT), shellEscape(token)
	))
end

local function deleteToken()
	hs.execute(string.format(
		"security delete-generic-password -s %s -a %s 2>/dev/null",
		shellEscape(KEYCHAIN_SERVICE), shellEscape(KEYCHAIN_ACCOUNT)
	))
end

local function setBadge()
	if not menubar then return end
	local hasToken = getToken() ~= nil
	local count = #notifications

	local icon, isTemplate
	if not hasToken then
		icon, isTemplate = bellMissing, false
	elseif count > 0 then
		icon, isTemplate = bellActive, true
	else
		icon, isTemplate = bellIdle, false
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

local function authHeaders()
	local token = getToken()
	if not token then return nil end
	return {
		["Accept"] = "application/vnd.github+json",
		["Authorization"] = "Bearer " .. token,
	}
end

local function apiToWebURL(apiURL)
	if not apiURL then return nil end
	return (apiURL:gsub("api%.github%.com/repos", "github.com"):gsub("/pulls/", "/pull/"))
end

local function markThreadRead(id, callback)
	local headers = authHeaders()
	if not headers or not id then
		if callback then callback() end
		return
	end
	hs.http.doAsyncRequest(
		"https://api.github.com/notifications/threads/" .. id,
		"PATCH", "", headers,
		function() if callback then callback() end end
	)
end

local function markAllRead(callback)
	local headers = authHeaders()
	if not headers then
		if callback then callback() end
		return
	end
	hs.http.doAsyncRequest(
		"https://api.github.com/notifications", "PUT", "", headers,
		function() if callback then callback() end end
	)
end

local function notifyOne(notif)
	local subj = notif.subject or {}
	local typeStr = subj.type or ""
	local reasonStr = REASON_TEXT[notif.reason] or notif.reason or ""
	local title = subj.title or "New notification"
	local webURL = apiToWebURL(subj.url)
	local id = notif.id

	hs.notify.new(function()
		if id then markThreadRead(id, function() if refresh then refresh() end end) end
		if webURL then hs.urlevent.openURL(webURL) end
	end, {
		title = "GitHub: " .. typeStr,
		subTitle = reasonStr,
		informativeText = title,
		autoWithdraw = true,
		hasActionButton = true,
		actionButtonTitle = "Open",
	}):send()
end

local function dismissOne(id, webURL)
	for i, n in ipairs(notifications) do
		if n.id == id then
			table.remove(notifications, i)
			break
		end
	end
	setBadge()
	markThreadRead(id)
	if webURL then hs.urlevent.openURL(webURL) end
end

local function promptForToken()
	local btn, token = hs.dialog.textPrompt(
		"GitHub Token",
		"Paste a GitHub Personal Access Token with the 'notifications' scope.",
		"", "Save", "Cancel"
	)
	if btn == "Save" and token and token ~= "" then
		setToken(token)
		refresh()
	end
end

local function buildMenu()
	local items = {}

	if not getToken() then
		table.insert(items, { title = "GitHub token not configured", disabled = true })
		table.insert(items, { title = "-" })
		table.insert(items, { title = "Set token…", fn = promptForToken })
		table.insert(items, {
			title = "Get a token…",
			fn = function() hs.urlevent.openURL("https://github.com/settings/tokens") end,
		})
		return items
	end

	if #notifications == 0 then
		table.insert(items, { title = "No notifications", disabled = true })
	else
		for _, notif in ipairs(notifications) do
			local subj = notif.subject or {}
			local typ = subj.type or ""
			local title = subj.title or ""
			local repo = (notif.repository or {}).full_name or ""
			local reasonStr = REASON_TEXT[notif.reason] or notif.reason or ""
			local short = #title > 60 and (title:sub(1, 57) .. "…") or title
			local label = string.format("%s — %s (%s)", short, repo, reasonStr)
			local webURL
			if typ == "Issue" or typ == "PullRequest" then
				webURL = apiToWebURL(subj.url)
			elseif repo ~= "" then
				webURL = "https://github.com/" .. repo
			end
			local id = notif.id
			table.insert(items, {
				title = label,
				fn = function() dismissOne(id, webURL) end,
			})
		end
	end

	table.insert(items, { title = "-" })
	table.insert(items, { title = "Refresh", fn = function() refresh() end })
	table.insert(items, {
		title = "Mark all as read",
		fn = function()
			notifications = {}
			setBadge()
			markAllRead(function() if refresh then refresh() end end)
		end,
	})
	table.insert(items, {
		title = "Open on GitHub",
		fn = function() hs.urlevent.openURL("https://github.com/notifications") end,
	})
	table.insert(items, { title = "-" })
	table.insert(items, {
		title = "Reset token",
		fn = function()
			deleteToken()
			notifications = {}
			setBadge()
		end,
	})
	return items
end

refresh = function()
	local headers = authHeaders()
	if not headers then
		notifications = {}
		setBadge()
		return
	end
	hs.http.doAsyncRequest(API_LIST, "GET", nil, headers, function(status, body)
		if status ~= 200 or not body then return end
		local ok, data = pcall(hs.json.decode, body)
		if not ok or type(data) ~= "table" then return end

		-- Notify on the first new id, matching the SwiftBar plugin's behaviour.
		-- Skip the very first poll so reloading Hammerspoon doesn't spam.
		if primed then
			for _, n in ipairs(data) do
				if n.id and not seenIDs[n.id] then
					notifyOne(n)
					break
				end
			end
		end
		for _, n in ipairs(data) do
			if n.id then seenIDs[n.id] = true end
		end
		primed = true

		notifications = data
		setBadge()
	end)
end

if menubar then
	menubar:setMenu(buildMenu)
	setBadge()
	refresh()
	pollTimer = hs.timer.doEvery(POLL_SECONDS, refresh)
end
