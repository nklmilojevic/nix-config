-- Move and resize windows in halves/thirds/corners via the keyboard.
-- Adapted from the MiroWindowsManager Spoon by Miro Mannino (MIT).

local obj = {}
obj.__index = obj

-- The sizes a window can have, expressed as dividends of the screen size.
-- e.g. { 2, 3, 3/2 } means 1/2, 1/3 and 2/3 of the screen.
obj.sizes = { 2, 3, 3 / 2 }

-- The sizes a window can have in full-screen, expressed as dividends of the screen size.
obj.fullScreenSizes = { 1, 4 / 3, 2 }

-- The grid the window manager snaps to, applied via hs.grid.setGrid().
obj.GRID = { w = 24, h = 24 }

obj._pressed = {
	up = false,
	down = false,
	left = false,
	right = false,
}

function obj:_nextStep(dim, offs, cb)
	if hs.window.focusedWindow() then
		local axis = dim == "w" and "x" or "y"
		local oppDim = dim == "w" and "h" or "w"
		local oppAxis = dim == "w" and "y" or "x"
		local win = hs.window.frontmostWindow()
		local screen = win:screen()

		local cell = hs.grid.get(win, screen)

		local nextSize = self.sizes[1]
		for i = 1, #self.sizes do
			if
				cell[dim] == self.GRID[dim] / self.sizes[i]
				and (cell[axis] + (offs and cell[dim] or 0)) == (offs and self.GRID[dim] or 0)
			then
				nextSize = self.sizes[(i % #self.sizes) + 1]
				break
			end
		end

		cb(cell, nextSize)
		if cell[oppAxis] ~= 0 and cell[oppAxis] + cell[oppDim] ~= self.GRID[oppDim] then
			cell[oppDim] = self.GRID[oppDim]
			cell[oppAxis] = 0
		end

		hs.grid.set(win, cell, screen)
	end
end

function obj:_nextFullScreenStep()
	if hs.window.focusedWindow() then
		local win = hs.window.frontmostWindow()
		local screen = win:screen()

		local cell = hs.grid.get(win, screen)

		local nextSize = self.fullScreenSizes[1]
		for i = 1, #self.fullScreenSizes do
			if
				cell.w == self.GRID.w / self.fullScreenSizes[i]
				and cell.h == self.GRID.h / self.fullScreenSizes[i]
				and cell.x == (self.GRID.w - self.GRID.w / self.fullScreenSizes[i]) / 2
				and cell.y == (self.GRID.h - self.GRID.h / self.fullScreenSizes[i]) / 2
			then
				nextSize = self.fullScreenSizes[(i % #self.fullScreenSizes) + 1]
				break
			end
		end

		cell.w = self.GRID.w / nextSize
		cell.h = self.GRID.h / nextSize
		cell.x = (self.GRID.w - self.GRID.w / nextSize) / 2
		cell.y = (self.GRID.h - self.GRID.h / nextSize) / 2

		hs.grid.set(win, cell, screen)
	end
end

function obj:_fullDimension(dim)
	if hs.window.focusedWindow() then
		local win = hs.window.frontmostWindow()
		local screen = win:screen()
		local cell = hs.grid.get(win, screen)

		if dim == "x" then
			cell = "0,0 " .. self.GRID.w .. "x" .. self.GRID.h
		else
			cell[dim] = self.GRID[dim]
			cell[dim == "w" and "x" or "y"] = 0
		end

		hs.grid.set(win, cell, screen)
	end
end

function obj:bindHotkeys(mapping)
	hs.hotkey.bind(mapping.down[1], mapping.down[2], function()
		self._pressed.down = true
		if self._pressed.up then
			self:_fullDimension("h")
		else
			self:_nextStep("h", true, function(cell, nextSize)
				cell.y = self.GRID.h - self.GRID.h / nextSize
				cell.h = self.GRID.h / nextSize
			end)
		end
	end, function()
		self._pressed.down = false
	end)

	hs.hotkey.bind(mapping.right[1], mapping.right[2], function()
		self._pressed.right = true
		if self._pressed.left then
			self:_fullDimension("w")
		else
			self:_nextStep("w", true, function(cell, nextSize)
				cell.x = self.GRID.w - self.GRID.w / nextSize
				cell.w = self.GRID.w / nextSize
			end)
		end
	end, function()
		self._pressed.right = false
	end)

	hs.hotkey.bind(mapping.left[1], mapping.left[2], function()
		self._pressed.left = true
		if self._pressed.right then
			self:_fullDimension("w")
		else
			self:_nextStep("w", false, function(cell, nextSize)
				cell.x = 0
				cell.w = self.GRID.w / nextSize
			end)
		end
	end, function()
		self._pressed.left = false
	end)

	hs.hotkey.bind(mapping.up[1], mapping.up[2], function()
		self._pressed.up = true
		if self._pressed.down then
			self:_fullDimension("h")
		else
			self:_nextStep("h", false, function(cell, nextSize)
				cell.y = 0
				cell.h = self.GRID.h / nextSize
			end)
		end
	end, function()
		self._pressed.up = false
	end)

	hs.hotkey.bind(mapping.fullscreen[1], mapping.fullscreen[2], function()
		self:_nextFullScreenStep()
	end)
end

function obj:init()
	hs.grid.setGrid(obj.GRID.w .. "x" .. obj.GRID.h)
	hs.grid.MARGINX = 0
	hs.grid.MARGINY = 0
end

local hyper = { "ctrl", "alt", "cmd", "shift" }

hs.window.animationDuration = 0
obj:init()
obj:bindHotkeys({
	up = { hyper, "up" },
	right = { hyper, "right" },
	down = { hyper, "down" },
	left = { hyper, "left" },
	fullscreen = { hyper, "return" },
	nextscreen = { hyper, "n" },
})

return obj
