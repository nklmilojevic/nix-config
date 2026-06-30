-- Reload the Hammerspoon config automatically when files in the config dir change.
-- Adapted from the ReloadConfiguration Spoon by Jon Lorusso (MIT).

local obj = {}

obj.watch_paths = { hs.configdir }
obj.watchers = {}

for _, dir in pairs(obj.watch_paths) do
	obj.watchers[dir] = hs.pathwatcher.new(dir, hs.reload):start()
end

return obj
