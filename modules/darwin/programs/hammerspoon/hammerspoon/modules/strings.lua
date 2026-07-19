local M = {}

-- Truncate to at most maxChars characters (not bytes), appending an ellipsis,
-- so multi-byte UTF-8 sequences like emoji are never split.
function M.truncate(s, maxChars)
	local len = utf8.len(s)
	if len == nil then
		-- invalid UTF-8: fall back to byte truncation
		return #s > maxChars and (s:sub(1, maxChars - 1) .. "…") or s
	end
	if len <= maxChars then
		return s
	end
	return s:sub(1, utf8.offset(s, maxChars) - 1) .. "…"
end

return M
