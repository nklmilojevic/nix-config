-- Curl-backed JSON HTTP helpers.
--
-- We use curl via hs.task instead of hs.http.doAsyncRequest because:
--   * NSURLSession's URL cache can silently return stale responses;
--   * hs.http mishandles empty-body PATCH/PUT against the GitHub API;
--   * curl matches the byte-for-byte behaviour of the SwiftBar plugins that
--     these modules replaced.
--
-- All callbacks receive (data | nil, err | nil).

local M = {}

local CURL = "/usr/bin/curl"

local function buildArgs(method, url, headers, body)
	local args = {
		"-sS", "--fail",
		"-g", -- disable URL globbing so '[' and ']' in query strings work
		"--connect-timeout", "5", "--max-time", "15",
		"-X", method,
	}
	for k, v in pairs(headers or {}) do
		args[#args + 1] = "-H"
		args[#args + 1] = k .. ": " .. v
	end
	if body then
		args[#args + 1] = "--data-binary"
		args[#args + 1] = body
	end
	args[#args + 1] = url
	return args
end

-- Serialize all curl invocations through a single-slot queue. hs.task seems
-- to silently drop completion callbacks when several curls are spawned in the
-- same Lua tick; running them one at a time keeps every callback firing.
-- Polling cadence is ~60s, so the throughput hit is negligible.
local queue = {}
local active = nil

local function pump()
	if active or #queue == 0 then return end
	local job = table.remove(queue, 1)
	active = hs.task.new(CURL, function(exitCode, stdout, stderr)
		active = nil
		if exitCode == 0 then
			job.callback(stdout or "", nil)
		else
			job.callback(stdout or "", string.format(
				"exit=%s %s", tostring(exitCode), (stderr or ""):sub(1, 300)
			))
		end
		pump()
	end, job.args)
	active:start()
end

local function run(method, url, headers, body, callback)
	queue[#queue + 1] = {
		args = buildArgs(method, url, headers, body),
		callback = callback,
	}
	pump()
end

local function decodeJSON(body)
	local ok, data = pcall(hs.json.decode, body or "")
	if not ok then
		return nil, "decode failed: " .. tostring(data)
	end
	return data, nil
end

-- GET URL, decode JSON. callback(data, err).
function M.getJSON(url, headers, callback)
	run("GET", url, headers, nil, function(body, err)
		if err then callback(nil, err) return end
		callback(decodeJSON(body))
	end)
end

-- POST JSON payload, decode JSON response. callback(data, err).
function M.postJSON(url, headers, payload, callback)
	local h = {}
	for k, v in pairs(headers or {}) do h[k] = v end
	h["Content-Type"] = h["Content-Type"] or "application/json"
	local body = hs.json.encode(payload or {})
	run("POST", url, h, body, function(respBody, err)
		if err then callback(nil, err) return end
		callback(decodeJSON(respBody))
	end)
end

-- Fire request with no body and no expected JSON response (PATCH/PUT/DELETE
-- mark-as-read style). callback(ok, err) — err nil on success.
function M.send(method, url, headers, callback)
	run(method, url, headers, nil, function(_, err)
		if callback then callback(err == nil, err) end
	end)
end

return M
