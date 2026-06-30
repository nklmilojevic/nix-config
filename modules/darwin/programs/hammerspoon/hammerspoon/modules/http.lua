-- JSON HTTP helpers.
--
-- GET uses hs.http.doAsyncRequest with explicit no-cache headers — the curl
-- path via hs.task was silently dropping completion callbacks under load and
-- wedging the single-slot queue.
--
-- PATCH/PUT/DELETE still go through curl: hs.http mishandles empty-body
-- writes against the GitHub API, so the mark-as-read calls have to shell out.
-- The curl queue keeps a watchdog so a dropped task callback can't stall it
-- indefinitely.
--
-- All callbacks receive (data | nil, err | nil).

local M = {}

local CURL = "/usr/bin/curl"

local function buildArgs(method, url, headers, body)
	local args = {
		"-sS",
		"--fail",
		"-g", -- disable URL globbing so '[' and ']' in query strings work
		"--connect-timeout",
		"5",
		"--max-time",
		"15",
		"-X",
		method,
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
local activeWatchdog = nil

-- curl --max-time is 15s; give the OS a few seconds of slack before the
-- watchdog steps in. Without this, a single dropped hs.task callback wedges
-- the queue forever and the next pump() short-circuits silently.
local WATCHDOG_SECONDS = 25

local function pump()
	if active or #queue == 0 then
		return
	end
	local job = table.remove(queue, 1)
	local done = false
	local taskRef

	local function finish(body, err)
		if done then
			return
		end
		done = true
		if activeWatchdog then
			activeWatchdog:stop()
			activeWatchdog = nil
		end
		active = nil
		job.callback(body or "", err)
		pump()
	end

	taskRef = hs.task.new(CURL, function(exitCode, stdout, stderr)
		if exitCode == 0 then
			finish(stdout, nil)
		else
			finish(stdout, string.format("exit=%s %s", tostring(exitCode), (stderr or ""):sub(1, 300)))
		end
	end, job.args)
	active = taskRef
	activeWatchdog = hs.timer.doAfter(WATCHDOG_SECONDS, function()
		if done then
			return
		end
		print("[httpx] watchdog: task callback never fired, force-clearing queue")
		if taskRef then
			pcall(function()
				taskRef:terminate()
			end)
		end
		finish("", "watchdog timeout")
	end)
	taskRef:start()
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
	local h = {}
	for k, v in pairs(headers or {}) do
		h[k] = v
	end
	-- NSURLSession's protocol cache will happily hand back a stale response
	-- to a repeated GET against the same URL with the same Authorization
	-- header; force a fresh fetch on every poll.
	h["Cache-Control"] = "no-cache"
	h["Pragma"] = "no-cache"
	hs.http.doAsyncRequest(url, "GET", nil, h, function(status, body)
		if status == nil or status < 0 then
			callback(nil, "network error status=" .. tostring(status))
			return
		end
		if status < 200 or status >= 300 then
			callback(nil, string.format("http %d: %s", status, (body or ""):sub(1, 200)))
			return
		end
		callback(decodeJSON(body))
	end)
end

-- POST JSON payload, decode JSON response. callback(data, err).
function M.postJSON(url, headers, payload, callback)
	local h = {}
	for k, v in pairs(headers or {}) do
		h[k] = v
	end
	h["Content-Type"] = h["Content-Type"] or "application/json"
	local body = hs.json.encode(payload or {})
	run("POST", url, h, body, function(respBody, err)
		if err then
			callback(nil, err)
			return
		end
		callback(decodeJSON(respBody))
	end)
end

-- Fire request with no body and no expected JSON response (PATCH/PUT/DELETE
-- mark-as-read style). callback(ok, err) — err nil on success.
function M.send(method, url, headers, callback)
	run(method, url, headers, nil, function(_, err)
		if callback then
			callback(err == nil, err)
		end
	end)
end

return M
