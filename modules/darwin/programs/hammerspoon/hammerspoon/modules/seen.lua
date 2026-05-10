-- Persistent set of "already seen" item IDs, shared across reloads so the
-- notification-firing modules don't re-fire native notifications for items
-- the user has already been shown — even after Hammerspoon restarts.
--
-- Usage:
--   local seen = require("modules/seen").new("myModuleSeenIDs")
--   if seen.primed and not seen:has(id) then notify(item) end
--   seen:mark(id)
--   seen:save()  -- no-op if nothing changed since last save

local M = {}
M.__index = M

function M.new(key)
	local self = setmetatable({}, M)
	self.key = key
	self.ids = hs.settings.get(key) or {}
	self.primed = next(self.ids) ~= nil
	self.dirty = false
	return self
end

function M:has(id)
	return id ~= nil and self.ids[id] == true
end

function M:mark(id)
	if id == nil or self.ids[id] then return end
	self.ids[id] = true
	self.dirty = true
end

function M:save()
	if not self.dirty then return end
	hs.settings.set(self.key, self.ids)
	self.dirty = false
end

return M
