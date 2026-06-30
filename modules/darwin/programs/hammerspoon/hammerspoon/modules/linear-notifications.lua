-- Linear notifications in the menubar.
--   API key: macOS Keychain (service "swiftbar-linear", account "api-key")
--            shared with the SwiftBar plugin during the pilot.
--   Click an item -> mark notification read + open the issue/project.
--   Native notification fires for new unread items (after the first poll
--   primes the seen-ids set).

local sf = require("modules/sf-symbols")
local Keychain = require("modules/keychain")
local Seen = require("modules/seen")

local KEYCHAIN_SERVICE = "swiftbar-linear"
local KEYCHAIN_ACCOUNT = "api-key"
local POLL_SECONDS = 120
local INITIAL_REFRESH_DELAY_SECONDS = 20
local API_URL = "https://api.linear.app/graphql"

local NOTIF_QUERY =
	[[{ notifications(first: 20) { nodes { id type readAt createdAt inboxUrl title subtitle actor { name } ... on IssueNotification { issue { id identifier title url team { name } } comment { id body } } ... on ProjectNotification { project { id name url } projectUpdate { id body } } } } }]]

local menubar = hs.menubar.new(true, "linear-notifications")
local notifications = {}
local seen = Seen.new("linearSeenIDs")
local lastBadgeState = nil
local pollTimer = nil
local initialRefreshTimer = nil
local refresh -- forward decl

local iconActive = sf.symbol("lineweight")
local iconIdle = sf.symbol("lineweight", { color = "gray" })
local iconMissing = sf.symbol("lineweight", { color = "gray" })

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
		["Content-Type"] = "application/json",
		["Authorization"] = token,
	}
end

local function unreadCount()
	local n = 0
	for _, notif in ipairs(notifications) do
		if not notif.readAt then
			n = n + 1
		end
	end
	return n
end

local function setBadge()
	if not menubar then
		return
	end
	local hasToken = getToken() ~= nil
	local count = unreadCount()
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

local function nowUTC()
	return os.date("!%Y-%m-%dT%H:%M:%S.000Z")
end

local function urlForNotification(notif)
	local issueURL = notif.issue and notif.issue.url
	if issueURL and issueURL ~= "" then
		return issueURL
	end
	local projectURL = notif.project and notif.project.url
	if projectURL and projectURL ~= "" then
		return projectURL
	end
	local inbox = notif.inboxUrl or "https://linear.app/inbox"
	if notif.type == "feedSummaryGenerated" then
		return (inbox:gsub("/notification/.*$", ""))
	end
	return inbox
end

local function formatNotification(notif)
	local actor = (notif.actor and notif.actor.name) or "Someone"
	local issueID = notif.issue and notif.issue.identifier or ""
	local issueTitle = notif.issue and notif.issue.title or ""
	local projectName = notif.project and notif.project.name or ""
	local label, sub
	local t = notif.type

	if t == "issueAssignedToYou" then
		label, sub = actor .. " assigned you to " .. issueID, issueTitle
	elseif t == "issueCommentMention" or t == "issueMention" then
		label, sub = actor .. " mentioned you in " .. issueID, issueTitle
	elseif t == "issueComment" then
		label, sub = actor .. " commented on " .. issueID, issueTitle
	elseif t == "issueNewComment" then
		label, sub = "New comment on " .. issueID, issueTitle
	elseif t == "issueStatusChanged" then
		label, sub = "Status changed on " .. issueID, issueTitle
	elseif t == "issuePriorityChanged" then
		label, sub = "Priority changed on " .. issueID, issueTitle
	elseif t == "issueSubscribed" then
		label, sub = "You were subscribed to " .. issueID, issueTitle
	elseif t == "feedSummaryGenerated" then
		label, sub = "Weekly Pulse", notif.subtitle or ""
	elseif t == "projectUpdateCreated" then
		label, sub = "Project update: " .. projectName, notif.subtitle or ""
	elseif t == "projectUpdateMentionPrompt" then
		label, sub = "Update prompt: " .. projectName, notif.subtitle or ""
	else
		if notif.title and notif.title ~= "" then
			label = notif.title
			sub = notif.subtitle or ""
		elseif issueID ~= "" then
			label = (t or "Linear") .. ": " .. issueID
			sub = issueTitle
		else
			label = t or "Linear notification"
			sub = notif.subtitle or ""
		end
	end
	return label, sub
end

local function postGraphQL(query, callback)
	local headers = authHeaders()
	if not headers then
		if callback then
			callback(nil)
		end
		return
	end
	local body = hs.json.encode({ query = query })
	hs.http.doAsyncRequest(API_URL, "POST", body, headers, function(status, respBody)
		if status ~= 200 or not respBody then
			if callback then
				callback(nil)
			end
			return
		end
		local ok, data = pcall(hs.json.decode, respBody)
		if not ok then
			if callback then
				callback(nil)
			end
			return
		end
		callback(data)
	end)
end

local function markRead(notifID, callback)
	if not notifID then
		if callback then
			callback()
		end
		return
	end
	local readAt = nowUTC()
	local mutation =
		string.format('mutation { notificationUpdate(id: "%s", input: { readAt: "%s" }) { success } }', notifID, readAt)
	postGraphQL(mutation, function()
		if callback then
			callback()
		end
	end)
end

local function notifyOne(notif)
	local label, sub = formatNotification(notif)
	local url = urlForNotification(notif)
	local id = notif.id
	hs.notify
		.new(function()
			if id then
				markRead(id, function()
					if refresh then
						refresh()
					end
				end)
			end
			if url then
				hs.urlevent.openURL(url)
			end
		end, {
			title = label,
			informativeText = sub or "",
			autoWithdraw = true,
			hasActionButton = true,
			actionButtonTitle = "Open",
		})
		:send()
end

local function dismissOne(id, url)
	for i, n in ipairs(notifications) do
		if n.id == id then
			n.readAt = nowUTC()
			break
		end
	end
	setBadge()
	markRead(id)
	if url then
		hs.urlevent.openURL(url)
	end
end

local function markAllRead()
	-- Optimistic local mark-read
	for _, n in ipairs(notifications) do
		if not n.readAt then
			n.readAt = nowUTC()
		end
	end
	setBadge()
	-- Server-side: loop unread, mutate each. Use a small chained sequence to
	-- avoid hammering the API in parallel.
	postGraphQL("{ notifications(first: 50) { nodes { id readAt } } }", function(data)
		if not data or not data.data or not data.data.notifications then
			return
		end
		for _, n in ipairs(data.data.notifications.nodes) do
			if not n.readAt then
				markRead(n.id)
			end
		end
		if refresh then
			refresh()
		end
	end)
end

local function promptForToken()
	local btn, token = hs.dialog.textPrompt(
		"Linear API Key",
		"Paste a Linear personal API key (https://linear.app/settings/api).",
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
		table.insert(items, { title = "Linear API key not configured", disabled = true })
		table.insert(items, { title = "-" })
		table.insert(items, { title = "Set API key…", fn = promptForToken })
		table.insert(items, {
			title = "Get an API key…",
			fn = function()
				hs.urlevent.openURL("https://linear.app/settings/api")
			end,
		})
		return items
	end

	local unread = {}
	for _, n in ipairs(notifications) do
		if not n.readAt then
			table.insert(unread, n)
		end
	end

	if #unread == 0 then
		table.insert(items, { title = "No unread notifications", disabled = true })
	else
		for _, notif in ipairs(unread) do
			local label, sub = formatNotification(notif)
			local url = urlForNotification(notif)
			local id = notif.id
			local short = #label > 55 and (label:sub(1, 52) .. "…") or label
			table.insert(items, {
				title = short,
				fn = function()
					dismissOne(id, url)
				end,
			})
		end
	end

	table.insert(items, { title = "-" })
	table.insert(items, {
		title = "Refresh",
		fn = function()
			refresh()
		end,
	})
	table.insert(items, { title = "Mark all as read", fn = markAllRead })
	table.insert(items, {
		title = "Open inbox",
		fn = function()
			hs.urlevent.openURL("https://linear.app/inbox")
		end,
	})
	table.insert(items, { title = "-" })
	table.insert(items, {
		title = "Reset API key",
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
	if not getToken() then
		notifications = {}
		setBadge()
		return
	end
	postGraphQL(NOTIF_QUERY, function(data)
		if not data or not data.data or not data.data.notifications then
			return
		end
		local nodes = data.data.notifications.nodes or {}

		if seen.primed then
			for _, n in ipairs(nodes) do
				if n.id and not n.readAt and not seen:has(n.id) then
					notifyOne(n)
					break
				end
			end
		end
		for _, n in ipairs(nodes) do
			if not n.readAt then
				seen:mark(n.id)
			end
		end
		seen.primed = true
		seen:save()

		notifications = nodes
		setBadge()
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
