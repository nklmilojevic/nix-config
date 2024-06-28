---@type LazySpec
return {
  "nvimtools/none-ls.nvim",
  opts = function(_, config)
    config.sources = {
      -- Set a formatter
      -- null_ls.builtins.formatting.stylua,
      -- null_ls.builtins.formatting.prettier,
    }
    return config
  end,
}
