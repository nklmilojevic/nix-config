-- GitHub pull requests (created / review-requested / assigned) in the menubar.
--   Token: shared Keychain entry with github-notifications (service
--          "swiftbar-github", account "token").
--   Click an item -> open in browser.
--   Native notification fires for new review-requested and assigned PRs
--   (after the first poll primes the seen-ids set).

local sf = require("modules/sf-symbols")
local Keychain = require("modules/keychain")
local Seen = require("modules/seen")
local Strings = require("modules/strings")

local KEYCHAIN_SERVICE = "swiftbar-github"
local KEYCHAIN_ACCOUNT = "token"
local POLL_SECONDS = 180
local INITIAL_REFRESH_DELAY_SECONDS = 35

local menubar = hs.menubar.new(true, "github-prs")
local createdPRs = {}
local assignedPRs = {}
local reviewPRs = {}
local username = nil
local seen = Seen.new("githubPRsSeenIDs")
local lastBadgeState = nil
local pollTimer = nil
local initialRefreshTimer = nil
local refresh -- forward decl

local iconActive = sf.symbol("arrow.triangle.branch")
local iconIdle = sf.symbol("arrow.triangle.branch", { color = "gray" })
local iconMissing = sf.symbol("arrow.triangle.branch", { color = "gray" })

local function getToken()
	return Keychain.get(KEYCHAIN_SERVICE, KEYCHAIN_ACCOUNT)
end

local function authHeaders()
	local token = getToken()
	if not token then
		return nil
	end
	return {
		["Accept"] = "application/vnd.github+json",
		["Authorization"] = "Bearer " .. token,
	}
end

local function totalCount()
	return #createdPRs + #assignedPRs + #reviewPRs
end

local function setBadge()
	if not menubar then
		return
	end
	local hasToken = getToken() ~= nil
	local count = totalCount()
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

	if hasToken and count > 0 then
		menubar:setTitle(hs.styledtext.new(" " .. count, { font = { size = 13 } }))
	else
		menubar:setTitle("")
	end
end

local function urlEncode(s)
	return (tostring(s or ""):gsub("([^%w%-_%.~])", function(c)
		return string.format("%%%02X", string.byte(c))
	end))
end

local function fetchPRs(query, callback)
	local headers = authHeaders()
	if not headers then
		callback({})
		return
	end
	local url = "https://api.github.com/search/issues?per_page=15&q=" .. urlEncode(query)
	hs.http.doAsyncRequest(url, "GET", nil, headers, function(status, body)
		if status ~= 200 or not body then
			callback({})
			return
		end
		local ok, data = pcall(hs.json.decode, body)
		if not ok or not data or not data.items then
			callback({})
			return
		end
		callback(data.items)
	end)
end

local function fetchUser(callback)
	local headers = authHeaders()
	if not headers then
		if callback then
			callback()
		end
		return
	end
	hs.http.doAsyncRequest("https://api.github.com/user", "GET", nil, headers, function(status, body)
		if status == 200 and body then
			local ok, data = pcall(hs.json.decode, body)
			if ok and data and data.login then
				username = data.login
			end
		end
		if callback then
			callback()
		end
	end)
end

local function notifyPR(pr, kind)
	local title = pr.title or "New PR"
	local user = pr.user and pr.user.login or "Someone"
	local notifTitle
	if kind == "review" then
		notifTitle = "Review requested by " .. user
	elseif kind == "assigned" then
		notifTitle = "Assigned by " .. user
	else
		notifTitle = "New PR"
	end
	hs.notify
		.new(function()
			if pr.html_url then
				hs.urlevent.openURL(pr.html_url)
			end
		end, {
			title = notifTitle,
			informativeText = title,
			autoWithdraw = true,
			hasActionButton = true,
			actionButtonTitle = "Open",
		})
		:send()
end

local function checkNewAndNotify(items, prefix)
	if not seen.primed then
		return
	end
	for _, pr in ipairs(items) do
		if pr.id then
			local key = prefix .. "-" .. pr.id
			if not seen:has(key) then
				if prefix == "review" or prefix == "assigned" then
					notifyPR(pr, prefix)
				end
			end
		end
	end
end

local function markSeen(items, prefix)
	for _, pr in ipairs(items) do
		if pr.id then
			seen:mark(prefix .. "-" .. pr.id)
		end
	end
	seen:save()
end

local function buildPRItem(pr)
	local title = pr.title or ""
	local repo = (pr.repository_url or ""):gsub("https://api%.github%.com/repos/", "")
	local short = Strings.truncate(title, 50)
	local prefix = pr.draft and "[Draft] " or ""
	local label = prefix .. short

	local style = {}
	if pr.draft then
		style.color = { red = 0.55, green = 0.55, blue = 0.55, alpha = 1 }
	end
	local titleAttr = next(style) and hs.styledtext.new(label, style) or label

	local submenu = {
		{ title = string.format("%s #%s", repo, pr.number or "?"), disabled = true },
		{
			title = "Open",
			fn = function()
				if pr.html_url then
					hs.urlevent.openURL(pr.html_url)
				end
			end,
		},
	}

	return {
		title = titleAttr,
		fn = function()
			if pr.html_url then
				hs.urlevent.openURL(pr.html_url)
			end
		end,
		menu = submenu,
	}
end

local function buildSection(items, label, color)
	local entries = {}
	if #items == 0 then
		return entries
	end
	table.insert(entries, {
		title = hs.styledtext.new(string.format("%s (%d)", label, #items), { color = color }),
		disabled = true,
	})
	for _, pr in ipairs(items) do
		table.insert(entries, buildPRItem(pr))
	end
	table.insert(entries, { title = "-" })
	return entries
end

local function buildMenu()
	local items = {}

	if not getToken() then
		table.insert(items, { title = "GitHub token not configured", disabled = true })
		table.insert(items, { title = "-" })
		table.insert(items, {
			title = "Open GitHub tokens settings",
			fn = function()
				hs.urlevent.openURL("https://github.com/settings/tokens")
			end,
		})
		return items
	end

	local sections = {
		buildSection(createdPRs, "Created by you", { red = 0.3, green = 0.5, blue = 0.9, alpha = 1 }),
		buildSection(reviewPRs, "Review requested", { red = 1.0, green = 0.6, blue = 0.0, alpha = 1 }),
		buildSection(assignedPRs, "Assigned to you", { red = 0.7, green = 0.4, blue = 0.9, alpha = 1 }),
	}

	local any = false
	for _, section in ipairs(sections) do
		for _, entry in ipairs(section) do
			table.insert(items, entry)
			any = true
		end
	end

	if not any then
		table.insert(items, { title = "No open pull requests", disabled = true })
		table.insert(items, { title = "-" })
	end

	table.insert(items, {
		title = "Refresh",
		fn = function()
			refresh()
		end,
	})
	table.insert(items, {
		title = "Open Pull Requests",
		fn = function()
			hs.urlevent.openURL("https://github.com/pulls")
		end,
	})
	return items
end

refresh = function()
	-- Capture timers as upvalues so the hs.timer userdata isn't GC'd after the
	-- chunk returns.
	local _ = pollTimer or initialRefreshTimer
	if not getToken() then
		createdPRs, assignedPRs, reviewPRs = {}, {}, {}
		setBadge()
		return
	end
	if not username then
		fetchUser(function()
			if username then
				refresh()
			end
		end)
		return
	end

	local remaining = 3
	local function done()
		remaining = remaining - 1
		if remaining == 0 then
			setBadge()
		end
	end

	fetchPRs("is:pr is:open author:" .. username, function(items)
		createdPRs = items
		done()
	end)

	fetchPRs("is:pr is:open assignee:" .. username, function(items)
		checkNewAndNotify(items, "assigned")
		markSeen(items, "assigned")
		assignedPRs = items
		done()
	end)

	fetchPRs("is:pr is:open review-requested:" .. username, function(items)
		checkNewAndNotify(items, "review")
		markSeen(items, "review")
		reviewPRs = items
		seen.primed = true
		done()
	end)
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
