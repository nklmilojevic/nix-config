-- Cached macOS Keychain lookups for polling modules.
--
-- Reading a generic password shells out to /usr/bin/security, which is
-- noticeably expensive when multiple menubar pollers repaint every minute.
-- Cache values in-process and update the cache on writes from Hammerspoon.

local M = {}

local cache = {}

local function cacheKey(service, account)
	return tostring(service or "") .. "\0" .. tostring(account or "")
end

local function shellEscape(s)
	return "'" .. (s or ""):gsub("'", "'\\''") .. "'"
end

function M.get(service, account)
	local key = cacheKey(service, account)
	local cached = cache[key]
	if cached ~= nil then
		return cached ~= false and cached or nil
	end

	local out, ok = hs.execute(string.format(
		"security find-generic-password -s %s -a %s -w 2>/dev/null",
		shellEscape(service), shellEscape(account)
	))
	if not ok or not out then
		cache[key] = false
		return nil
	end

	out = out:gsub("%s+$", "")
	local token = out ~= "" and out or nil
	cache[key] = token or false
	return token
end

function M.set(service, account, value)
	local _, ok = hs.execute(string.format(
		"security add-generic-password -s %s -a %s -w %s -U",
		shellEscape(service), shellEscape(account), shellEscape(value)
	))

	local key = cacheKey(service, account)
	cache[key] = ok and value or nil
	return ok
end

function M.delete(service, account)
	local _, ok = hs.execute(string.format(
		"security delete-generic-password -s %s -a %s 2>/dev/null",
		shellEscape(service), shellEscape(account)
	))

	cache[cacheKey(service, account)] = false
	return ok
end

function M.clear(service, account)
	if service and account then
		cache[cacheKey(service, account)] = nil
	else
		cache = {}
	end
end

return M
