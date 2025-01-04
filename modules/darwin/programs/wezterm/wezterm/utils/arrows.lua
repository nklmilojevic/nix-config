local wt = require 'wezterm'

---@class Arrow
local M = {}

M.arrow_solid_left = ''
M.arrow_thin_left = ''
M.arrow_solid_right = ''
M.arrow_thin_right = ''

function M:arrow(direction)
  if direction ~= 'left' and direction ~= 'right' then
    wt.log_error(
      'Invalid direction: '
      .. tostring(direction)
      .. ". Allowed values are 'left' or 'right'."
    )
  end

  -- Handle the direction
  if direction == 'left' then
    return 'You chose left!'
  elseif direction == 'right' then
    return 'You chose right!'
  end
end

return M
