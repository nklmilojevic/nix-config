local M = {}

function M.setup(config)
  config.front_end = 'WebGpu'
  config.animation_fps = 120
end

return M
