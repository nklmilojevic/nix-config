-- GitHub notifications in the macOS menubar.
--   Token: macOS Keychain (service "swiftbar-github", account "token")
--          shared with the SwiftBar plugin so no re-auth needed during the pilot.
--   Click menubar -> menu of unread notifications.
--   Click an item -> mark thread read + open on github.com.
--   New-item native notification fires once per poll cycle (after the first poll
--   primes the seen-ids set, so reloading Hammerspoon doesn't spam you).

local sf = require("modules/sf-symbols")
local httpx = require("modules/http")
local Keychain = require("modules/keychain")
local Seen = require("modules/seen")

local KEYCHAIN_SERVICE = "swiftbar-github"
local KEYCHAIN_ACCOUNT = "token"
local POLL_SECONDS = 60
local INITIAL_REFRESH_DELAY_SECONDS = 5
local API_LIST = "https://api.github.com/notifications?per_page=25"

local menubar = hs.menubar.new(true, "github-notifications")
-- bellActive: rendered in default color, displayed as template so macOS
-- repaints it to the menubar foreground (white in dark menubar).
-- bellIdle/bellMissing: rendered in fixed gray, displayed non-template.
local bellActive = sf.symbol("bell.fill")
local bellIdle = sf.symbol("bell.fill", { color = "gray" })
local bellMissing = sf.symbol("bell.slash", { color = "gray" })
local notifications = {}
local seen = Seen.new("githubNotifSeenIDs")
local lastBadgeState = nil
local pollTimer = nil
local initialRefreshTimer = nil
local refresh -- forward decl
local clearDismissed -- forward decl

-- GitHub's GET /notifications endpoint lags PATCH/PUT writes by ~30–60s, so
-- threads we just marked read keep reappearing on the next poll. Track local
-- dismissals and filter them out until propagation catches up.
local dismissedAt = {}
local DISMISS_TTL = 120 -- seconds

local function markDismissed(id)
	if id then
		dismissedAt[id] = os.time()
	end
end

local function filterDismissed(list)
	local now = os.time()
	local out = {}
	for _, n in ipairs(list) do
		local at = n.id and dismissedAt[n.id]
		if at then
			if (now - at) < DISMISS_TTL then
				-- still within propagation window, hide it
			else
				dismissedAt[n.id] = nil
				out[#out + 1] = n
			end
		else
			out[#out + 1] = n
		end
	end
	return out
end

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

local function getToken()
	return Keychain.get(KEYCHAIN_SERVICE, KEYCHAIN_ACCOUNT)
end

local function setToken(token)
	return Keychain.set(KEYCHAIN_SERVICE, KEYCHAIN_ACCOUNT, token)
end

local function deleteToken()
	return Keychain.delete(KEYCHAIN_SERVICE, KEYCHAIN_ACCOUNT)
end

local function setBadge()
	if not menubar then return end
	local hasToken = getToken() ~= nil
	local count = #notifications
	local state = string.format("%s:%d", hasToken and "token" or "missing", count)
	if state == lastBadgeState then return end
	lastBadgeState = state

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
	httpx.send("PATCH", "https://api.github.com/notifications/threads/" .. id, headers,
		function(ok, err)
			if not ok then print("[gh-notif] markThreadRead " .. id .. " failed: " .. (err or "")) end
			if callback then callback() end
		end)
end

local function markAllRead(callback)
	local headers = authHeaders()
	if not headers then
		if callback then callback() end
		return
	end
	httpx.send("PUT", "https://api.github.com/notifications", headers,
		function(ok, err)
			if not ok then print("[gh-notif] markAllRead failed: " .. (err or "")) end
			if callback then callback() end
		end)
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
	markDismissed(id)
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
			for _, n in ipairs(notifications) do
				markDismissed(n.id)
			end
			notifications = {}
			setBadge()
			markAllRead(function() if refresh then refresh() end end)
		end,
	})
	table.insert(items, {
		title = "Open on GitHub",
		fn = function() hs.urlevent.openURL("https://github.com/notifications") end,
	})
	table.insert(items, {
		title = "Clear local cache",
		fn = function() if clearDismissed then clearDismissed() end end,
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
	-- Capture timers as upvalues so the hs.timer userdata isn't GC'd after the
	-- chunk returns.
	local _ = pollTimer or initialRefreshTimer
	local headers = authHeaders()
	if not headers then
		print("[gh-notif] refresh skipped: no token")
		notifications = {}
		setBadge()
		return
	end
	print("[gh-notif] refresh: requesting " .. API_LIST)
	httpx.getJSON(API_LIST, headers, function(data, err)
		if err or type(data) ~= "table" then
			print("[gh-notif] refresh failed: " .. (err or "non-table response"))
			return
		end

		local filtered = filterDismissed(data)
		print(string.format(
			"[gh-notif] refresh ok: api=%d dismissed_filtered=%d kept=%d",
			#data, #data - #filtered, #filtered
		))

		if seen.primed then
			for _, n in ipairs(filtered) do
				if n.id and not seen:has(n.id) then
					notifyOne(n)
					break
				end
			end
		end
		for _, n in ipairs(filtered) do
			seen:mark(n.id)
		end
		seen.primed = true
		seen:save()

		notifications = filtered
		setBadge()
	end)
end

-- Expose a way to clear the local dismissal map manually, so a stale
-- "still in cooldown" filter can be reset without an hs.reload.
clearDismissed = function()
	local n = 0
	for _ in pairs(dismissedAt) do n = n + 1 end
	dismissedAt = {}
	print(string.format("[gh-notif] cleared %d dismissed entries", n))
	if refresh then refresh() end
end

if menubar then
	menubar:setMenu(buildMenu)
	setBadge()
	initialRefreshTimer = hs.timer.doAfter(INITIAL_REFRESH_DELAY_SECONDS, function()
		initialRefreshTimer = nil
		refresh()
		pollTimer = hs.timer.doEvery(POLL_SECONDS, refresh)
	end)
end
