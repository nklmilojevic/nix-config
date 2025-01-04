local M = {}

function M.setup(config)
  config.unix_domains = { { name = 'unix' } }
  config.default_gui_startup_args = { 'connect', 'unix' }
  config.mux_env_remove = { 'SSH_CLIENT', 'SSH_CONNECTION' }
end

return M
