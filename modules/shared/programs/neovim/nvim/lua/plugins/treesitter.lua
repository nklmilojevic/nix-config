---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  opts = function(_, opts)
    opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, {
      "bash",
      "c",
      "css",
      "dockerfile",
      "elixir",
      "go",
      "gomod",
      "hcl",
      "html",
      "json",
      "lua",
      "markdown",
      "php",
      "python",
      "regex",
      "ruby",
      "rust",
      "sql",
      "terraform",
      "toml",
      "tsx",
      "vim",
      "vimdoc",
      "yaml",
    })
  end,
}
