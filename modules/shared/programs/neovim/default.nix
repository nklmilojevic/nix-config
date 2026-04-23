{
  lib,
  pkgs,
  ...
}:
let
  # Plugins not managed by nixvim's programs.nixvim.plugins.*; installed
  # directly from pkgs.vimPlugins via extraPlugins below.
  extraPluginNames = [
    "SchemaStore.nvim"
    "blink-copilot"
    "dial.nvim"
    "friendly-snippets"
    "gh.nvim"
    "grug-far.nvim"
    "helm-ls.nvim"
    "inc-rename.nvim"
    "lazydev.nvim"
    "litee.nvim"
    "markdown-preview.nvim"
    "nui.nvim"
    "nvim-ansible"
    "nvim-lspconfig"
    "nvim-treesitter-textobjects"
    "persistence.nvim"
    "plenary.nvim"
    "tokyonight.nvim"
    "ts-comments.nvim"
    "vim-dadbod"
    "vim-dadbod-completion"
    "vim-dadbod-ui"
  ];
  pluginAttrFor =
    name: if name == "catppuccin" then "catppuccin-nvim" else lib.replaceStrings [ "." ] [ "-" ] name;
  pluginPackageFor =
    name:
    let
      attr = pluginAttrFor name;
    in
    if builtins.hasAttr attr pkgs.vimPlugins then
      pkgs.vimPlugins.${attr}
    else
      throw "Missing vim plugin package for ${name} (${attr})";
  grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
    bash
    c
    css
    diff
    dockerfile
    go
    gomod
    gosum
    gowork
    hcl
    html
    javascript
    jsdoc
    json
    lua
    luadoc
    luap
    markdown
    markdown_inline
    nix
    php
    printf
    python
    query
    regex
    rust
    sql
    svelte
    terraform
    toml
    tsx
    typescript
    vim
    vimdoc
    vue
    xml
    yaml
  ];
in
{
  programs.nixvim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;

    globals = {
      mapleader = " ";
      maplocalleader = "\\";
      autoformat = true;
      ai_cmp = true;
      snacks_animate = true;
      trouble_lualine = true;
      deprecation_warnings = false;
      loaded_sql_completion = true;
      omni_sql_default_compl_type = "syntax";
      markdown_recommended_style = 0;
    };

    opts = {
      autowrite = true;
      completeopt = "menu,menuone,noselect";
      conceallevel = 2;
      confirm = true;
      cursorline = true;
      expandtab = true;
      foldlevel = 99;
      foldmethod = "expr";
      foldexpr = "v:lua.vim.treesitter.foldexpr()";
      foldtext = "";
      formatoptions = "jcroqlnt";
      grepformat = "%f:%l:%c:%m";
      grepprg = "rg --vimgrep";
      ignorecase = true;
      inccommand = "nosplit";
      jumpoptions = "view";
      laststatus = 3;
      linebreak = true;
      list = true;
      mouse = "a";
      number = true;
      pumblend = 10;
      pumheight = 10;
      relativenumber = true;
      ruler = false;
      scrolloff = 4;
      shiftround = true;
      shiftwidth = 2;
      showmode = false;
      sidescrolloff = 8;
      signcolumn = "yes";
      smartcase = true;
      smartindent = true;
      smoothscroll = true;
      spelllang = [ "en" ];
      splitbelow = true;
      splitkeep = "screen";
      splitright = true;
      tabstop = 2;
      termguicolors = true;
      timeoutlen = 300;
      undofile = true;
      undolevels = 10000;
      updatetime = 200;
      virtualedit = "block";
      wildmode = "longest:full,full";
      winminwidth = 5;
      wrap = false;
    };

    keymaps = import ./keymaps.nix;

    extraPlugins = map pluginPackageFor extraPluginNames;

    extraPackages = with pkgs; [
      ansible-language-server
      basedpyright
      bash-language-server
      biome
      docker-compose-language-service
      dockerfile-language-server
      fd
      fish
      gofumpt
      golangci-lint
      golangci-lint-langserver
      gopls
      gotools
      helm-ls
      intelephense
      lua-language-server
      marksman
      markdown-toc
      markdownlint-cli2
      nil
      nixd
      nixfmt
      pgformatter
      php84Packages.php-cs-fixer
      php84Packages.php-codesniffer
      phpactor
      prettier
      python3Packages.python-lsp-ruff
      python3Packages.python-lsp-server
      python3Packages.ruff
      ripgrep
      rust-analyzer
      shellcheck
      shfmt
      sqlfluff
      statix
      stylua
      svelte-language-server
      tailwindcss-language-server
      taplo
      terraform-ls
      typescript
      typescript-language-server
      vscode-langservers-extracted
      vtsls
      vue-language-server
      yaml-language-server
    ];

    diagnostic.settings = {
      underline = true;
      update_in_insert = false;
      virtual_text = {
        spacing = 4;
        source = "if_many";
        prefix = "●";
      };
      severity_sort = true;
      signs.text.__raw = ''
        {
          [vim.diagnostic.severity.ERROR] = " ",
          [vim.diagnostic.severity.WARN] = " ",
          [vim.diagnostic.severity.HINT] = " ",
          [vim.diagnostic.severity.INFO] = " ",
        }
      '';
    };

    plugins.treesitter = {
      enable = true;
      settings = {
        highlight.enable = true;
        indent.enable = true;
      };
      inherit grammarPackages;
    };

    plugins.flash.enable = true;

    plugins.todo-comments.enable = true;

    plugins.ts-autotag.enable = true;

    plugins.trouble = {
      enable = true;
      settings.modes.lsp.win.position = "right";
    };

    plugins.treesitter-context = {
      enable = true;
      settings = {
        mode = "cursor";
        max_lines = 3;
      };
    };

    plugins.render-markdown = {
      enable = true;
      settings = {
        code = {
          sign = false;
          width = "block";
          right_pad = 1;
        };
        heading = {
          sign = false;
          icons = [ ];
        };
        checkbox.enabled = false;
      };
    };

    plugins.noice = {
      enable = true;
      settings = {
        lsp.override = {
          "vim.lsp.util.convert_input_to_markdown_lines" = true;
          "vim.lsp.util.stylize_markdown" = true;
        };
        presets = {
          bottom_search = true;
          command_palette = true;
          inc_rename = true;
          long_message_to_split = true;
        };
        routes = [
          {
            filter = {
              event = "msg_show";
              any = [
                { find = "%d+L, %d+B"; }
                { find = "; after #%d+"; }
                { find = "; before #%d+"; }
              ];
            };
            view = "mini";
          }
        ];
      };
    };

    colorschemes.catppuccin = {
      enable = true;
      settings = {
        integrations = {
          blink_cmp = true;
          flash = true;
          gitsigns = true;
          mini = true;
          noice = true;
          snacks = true;
          treesitter = true;
          treesitter_context = true;
          which_key = true;
        };
        lsp_styles.underlines = {
          errors = [ "undercurl" ];
          hints = [ "undercurl" ];
          warnings = [ "undercurl" ];
          information = [ "undercurl" ];
        };
      };
    };

    plugins.which-key = {
      enable = true;
      settings = {
        preset = "helix";
        spec = [
          { __unkeyed-1 = "<leader><tab>"; group = "tabs"; mode = [ "n" "x" ]; }
          { __unkeyed-1 = "<leader>b"; group = "buffer"; mode = [ "n" "x" ]; }
          { __unkeyed-1 = "<leader>c"; group = "code"; mode = [ "n" "x" ]; }
          { __unkeyed-1 = "<leader>f"; group = "file/find"; mode = [ "n" "x" ]; }
          { __unkeyed-1 = "<leader>g"; group = "git"; mode = [ "n" "x" ]; }
          { __unkeyed-1 = "<leader>gh"; group = "hunks"; mode = [ "n" "x" ]; }
          { __unkeyed-1 = "<leader>G"; group = "github"; mode = [ "n" "x" ]; }
          { __unkeyed-1 = "<leader>q"; group = "quit/session"; mode = [ "n" "x" ]; }
          { __unkeyed-1 = "<leader>s"; group = "search"; mode = [ "n" "x" ]; }
          { __unkeyed-1 = "<leader>u"; group = "ui"; mode = [ "n" "x" ]; }
          { __unkeyed-1 = "<leader>w"; group = "windows"; mode = [ "n" "x" ]; }
          { __unkeyed-1 = "<leader>x"; group = "diagnostics/quickfix"; mode = [ "n" "x" ]; }
          { __unkeyed-1 = "["; group = "prev"; mode = [ "n" "x" ]; }
          { __unkeyed-1 = "]"; group = "next"; mode = [ "n" "x" ]; }
          { __unkeyed-1 = "g"; group = "goto"; mode = [ "n" "x" ]; }
          { __unkeyed-1 = "gs"; group = "surround"; mode = [ "n" "x" ]; }
          { __unkeyed-1 = "z"; group = "fold"; mode = [ "n" "x" ]; }
        ];
      };
    };

    plugins.gitsigns = {
      enable = true;
      settings = {
        signs = {
          add.text = "▎";
          change.text = "▎";
          delete.text = "";
          topdelete.text = "";
          changedelete.text = "▎";
          untracked.text = "▎";
        };
        signs_staged = {
          add.text = "▎";
          change.text = "▎";
          delete.text = "";
          topdelete.text = "";
          changedelete.text = "▎";
        };
        on_attach.__raw = ''
          function(buffer)
            local gs = package.loaded.gitsigns
            local map = vim.keymap.set
            local function bmap(mode, lhs, rhs, desc)
              map(mode, lhs, rhs, { buffer = buffer, desc = desc, silent = true })
            end
            bmap("n", "]h", function()
              if vim.wo.diff then
                vim.cmd.normal({ "]c", bang = true })
              else
                gs.nav_hunk("next")
              end
            end, "Next Hunk")
            bmap("n", "[h", function()
              if vim.wo.diff then
                vim.cmd.normal({ "[c", bang = true })
              else
                gs.nav_hunk("prev")
              end
            end, "Prev Hunk")
            bmap("n", "]H", function() gs.nav_hunk("last") end, "Last Hunk")
            bmap("n", "[H", function() gs.nav_hunk("first") end, "First Hunk")
            bmap({ "n", "x" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
            bmap({ "n", "x" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
            bmap("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
            bmap("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
            bmap("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
            bmap("n", "<leader>ghp", gs.preview_hunk_inline, "Preview Hunk Inline")
            bmap("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame Line")
            bmap("n", "<leader>ghB", gs.blame, "Blame Buffer")
            bmap("n", "<leader>ghd", gs.diffthis, "Diff This")
            bmap("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff This ~")
            bmap({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Select Hunk")
          end
        '';
      };
    };

    plugins.bufferline = {
      enable = true;
      settings = {
        highlights.__raw = ''
          (function()
            local ok, mod = pcall(require, "catppuccin.special.bufferline")
            if ok then return mod.get_theme() end
            return nil
          end)()
        '';
        options = {
          always_show_bufferline = false;
          diagnostics = "nvim_lsp";
          close_command.__raw = "function(n) Snacks.bufdelete(n) end";
          right_mouse_command.__raw = "function(n) Snacks.bufdelete(n) end";
          diagnostics_indicator.__raw = ''
            function(_, _, diag)
              local ret = (diag.error and " " .. diag.error .. " " or "")
                .. (diag.warning and " " .. diag.warning or "")
              return vim.trim(ret)
            end
          '';
        };
      };
    };

    plugins.lsp = import ./lsp.nix;

    plugins.snacks = {
      enable = true;
      settings = {
        dashboard = {
          enabled = true;
          preset = {
            header = ''
              ██╗   ██╗██╗███╗   ███╗██╗  ██╗ ██████╗ ██╗      █████╗
              ██║   ██║██║████╗ ████║██║ ██╔╝██╔═══██╗██║     ██╔══██╗
              ██║   ██║██║██╔████╔██║█████╔╝ ██║   ██║██║     ███████║
              ╚██╗ ██╔╝██║██║╚██╔╝██║██╔═██╗ ██║   ██║██║     ██╔══██║
               ╚████╔╝ ██║██║ ╚═╝ ██║██║  ██╗╚██████╔╝███████╗██║  ██║
                ╚═══╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝
            '';
            keys = [
              {
                icon = " ";
                key = "f";
                desc = "Find File";
                action.__raw = "function() Snacks.picker.files({ cwd = UserNixvim.project_root() }) end";
              }
              { icon = " "; key = "n"; desc = "New File"; action = ":ene | startinsert"; }
              {
                icon = " ";
                key = "g";
                desc = "Find Text";
                action.__raw = "function() Snacks.picker.grep({ cwd = UserNixvim.project_root() }) end";
              }
              {
                icon = " ";
                key = "r";
                desc = "Recent Files";
                action.__raw = "function() Snacks.picker.recent() end";
              }
              {
                icon = " ";
                key = "c";
                desc = "Config";
                action.__raw = ''function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end'';
              }
              {
                icon = " ";
                key = "p";
                desc = "Projects";
                action.__raw = "function() Snacks.picker.projects() end";
              }
              { icon = " "; key = "q"; desc = "Quit"; action = ":qa"; }
            ];
          };
          sections = [
            { section = "header"; }
            { section = "keys"; gap = 1; padding = 1; }
          ];
        };
        indent.enabled = true;
        input.enabled = true;
        notifier.enabled = true;
        picker = {
          enabled = true;
          win.input.keys."<a-c>" = {
            __unkeyed-1 = "toggle_cwd";
            mode = [ "n" "i" ];
          };
          actions.toggle_cwd.__raw = ''
            function(picker)
              local root = UserNixvim.project_root()
              local cwd = vim.fs.normalize((vim.uv or vim.loop).cwd() or ".")
              local current = picker:cwd()
              picker:set_cwd(current == root and cwd or root)
              picker:find()
            end
          '';
        };
        scope.enabled = true;
        scroll.enabled = true;
        words.enabled = true;
      };
    };

    plugins.blink-cmp = {
      enable = true;
      settings = {
        snippets.preset = "default";
        appearance = {
          use_nvim_cmp_as_default = false;
          nerd_font_variant = "mono";
        };
        completion = {
          accept.auto_brackets.enabled = true;
          documentation = {
            auto_show = true;
            auto_show_delay_ms = 200;
          };
          ghost_text.enabled.__raw = "vim.g.ai_cmp";
          menu.draw.treesitter = [ "lsp" ];
        };
        cmdline = {
          enabled = true;
          keymap = {
            preset = "cmdline";
            "<Right>" = false;
            "<Left>" = false;
          };
          completion = {
            list.selection.preselect = false;
            menu.auto_show.__raw = ''function() return vim.fn.getcmdtype() == ":" end'';
            ghost_text.enabled = true;
          };
        };
        keymap = {
          preset = "enter";
          "<C-y>" = [ "select_and_accept" ];
        };
        sources = {
          default = [ "copilot" "lsp" "path" "snippets" "buffer" "dadbod" ];
          providers = {
            copilot = {
              name = "copilot";
              module = "blink-copilot";
              score_offset = 100;
              async = true;
            };
            dadbod = {
              name = "Dadbod";
              module = "vim_dadbod_completion.blink";
            };
          };
        };
      };
    };

    plugins.copilot-lua = {
      enable = true;
      settings = {
        panel.enabled = false;
        suggestion = {
          enabled.__raw = "not vim.g.ai_cmp";
          auto_trigger = true;
          hide_during_completion.__raw = "vim.g.ai_cmp";
          keymap = {
            accept = false;
            next = "<M-]>";
            prev = "<M-[>";
          };
        };
        filetypes = {
          markdown = true;
          help = true;
        };
      };
    };

    plugins.lint = {
      enable = true;
      autoCmd.event = [ "BufWritePost" "BufEnter" "InsertLeave" ];
      lintersByFt = {
        go = [ "golangcilint" ];
        markdown = [ "markdownlint-cli2" ];
        nix = [ "statix" ];
        php = [ "phpcs" ];
        sql = [ "sqlfluff" ];
        mysql = [ "sqlfluff" ];
        plsql = [ "sqlfluff" ];
      };
    };

    plugins.mini-icons = {
      enable = true;
      mockDevIcons = true;
      settings = {
        file = {
          ".keep" = { glyph = "󰊢"; hl = "MiniIconsGrey"; };
          ".eslintrc.js" = { glyph = "󰱺"; hl = "MiniIconsYellow"; };
          ".go-version" = { glyph = ""; hl = "MiniIconsBlue"; };
          ".node-version" = { glyph = ""; hl = "MiniIconsGreen"; };
          ".prettierrc" = { glyph = ""; hl = "MiniIconsPurple"; };
          ".yarnrc.yml" = { glyph = ""; hl = "MiniIconsBlue"; };
          "devcontainer.json" = { glyph = ""; hl = "MiniIconsAzure"; };
          "eslint.config.js" = { glyph = "󰱺"; hl = "MiniIconsYellow"; };
          "package.json" = { glyph = ""; hl = "MiniIconsGreen"; };
          "tsconfig.json" = { glyph = ""; hl = "MiniIconsAzure"; };
          "tsconfig.build.json" = { glyph = ""; hl = "MiniIconsAzure"; };
          "yarn.lock" = { glyph = ""; hl = "MiniIconsBlue"; };
        };
        filetype = {
          dotenv = { glyph = ""; hl = "MiniIconsYellow"; };
          gotmpl = { glyph = "󰟓"; hl = "MiniIconsGrey"; };
        };
      };
    };

    plugins.mini-pairs = {
      enable = true;
      settings = {
        modes = {
          insert = true;
          command = true;
          terminal = false;
        };
        skip_next = ''[%w%%%'%[%"%.%`%$]'';
        skip_ts = [ "string" ];
        skip_unbalanced = true;
        markdown = true;
      };
    };

    plugins.mini-ai = {
      enable = true;
      settings = {
        n_lines = 500;
        custom_textobjects.__raw = ''
          (function()
            local ai = require("mini.ai")
            return {
              o = ai.gen_spec.treesitter({
                a = { "@block.outer", "@conditional.outer", "@loop.outer" },
                i = { "@block.inner", "@conditional.inner", "@loop.inner" },
              }),
              f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
              c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
              u = ai.gen_spec.function_call(),
              U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }),
            }
          end)()
        '';
      };
    };

    plugins.mini-surround.enable = true;

    plugins.mini-hipatterns = {
      enable = true;
      settings.highlighters.__raw = ''
        (function()
          local hi = require("mini.hipatterns")
          return {
            hex_color = hi.gen_highlighter.hex_color({ priority = 2000 }),
          }
        end)()
      '';
    };

    plugins.yanky = {
      enable = true;
      settings = {
        system_clipboard.sync_with_ring.__raw = "not vim.env.SSH_CONNECTION";
        highlight.timer = 150;
      };
    };

    plugins.venv-selector = {
      enable = true;
      settings.options = {
        notify_user_on_venv_activation = true;
        override_notify = false;
      };
    };

    plugins.lualine = {
      enable = true;
      settings = {
        options = {
          theme = "auto";
          globalstatus = true;
          disabled_filetypes.statusline = [ "dashboard" "alpha" "ministarter" "snacks_dashboard" ];
        };
        sections.__raw = ''
          {
            lualine_a = { "mode" },
            lualine_b = { "branch" },
            lualine_c = {
              function() return vim.fn.fnamemodify(UserNixvim.project_root(), ":t") end,
              {
                "diagnostics",
                symbols = {
                  error = " ",
                  warn = " ",
                  info = " ",
                  hint = " ",
                },
              },
              { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
              function() return UserNixvim.root_relative_path() end,
            },
            lualine_x = {
              {
                function()
                  local ok, noice = pcall(require, "noice")
                  if ok and noice.api.status.command.has() then
                    return noice.api.status.command.get()
                  end
                end,
                cond = function()
                  local ok, noice = pcall(require, "noice")
                  return ok and noice.api.status.command.has()
                end,
              },
              {
                function()
                  local ok, noice = pcall(require, "noice")
                  if ok and noice.api.status.mode.has() then
                    return noice.api.status.mode.get()
                  end
                end,
                cond = function()
                  local ok, noice = pcall(require, "noice")
                  return ok and noice.api.status.mode.has()
                end,
              },
              {
                function()
                  local clients = package.loaded["copilot"]
                      and vim.lsp.get_clients({ name = "copilot", bufnr = 0 })
                    or {}
                  if #clients > 0 then
                    local status = require("copilot.status").data.status
                    return " "
                      .. ((status == "InProgress" and "pending") or (status == "Warning" and "error") or "ok")
                  end
                end,
              },
              {
                "diff",
                symbols = {
                  added = " ",
                  modified = " ",
                  removed = " ",
                },
              },
            },
            lualine_y = {
              { "progress", separator = " ", padding = { left = 1, right = 0 } },
              { "location", padding = { left = 0, right = 1 } },
            },
            lualine_z = {
              function() return " " .. os.date("%R") end,
            },
          }
        '';
      };
    };

    plugins."conform-nvim" = {
      enable = true;
      settings = {
        default_format_opts = {
          timeout_ms = 3000;
          async = false;
          quiet = false;
          lsp_format = "fallback";
        };
        format_on_save.__raw = ''
          function(bufnr)
            if vim.g.autoformat then
              return { bufnr = bufnr, lsp_format = "fallback" }
            end
          end
        '';
        formatters = {
          injected.options.ignore_errors = true;
          sqlfluff.args = [
            "format"
            "--dialect=ansi"
            "-"
          ];
        };
        formatters_by_ft = {
          fish = [ "fish_indent" ];
          go = [
            "goimports"
            "gofumpt"
          ];
          lua = [ "stylua" ];
          markdown = [
            "prettier"
            "markdownlint-cli2"
            "markdown-toc"
          ];
          "markdown.mdx" = [
            "prettier"
            "markdownlint-cli2"
            "markdown-toc"
          ];
          nix = [ "nixfmt" ];
          php = [ "php_cs_fixer" ];
          sh = [ "shfmt" ];
          sql = [ "sqlfluff" ];
          mysql = [ "sqlfluff" ];
          plsql = [ "sqlfluff" ];
          svelte = [ "prettier" ];
        };
      };
    };

    extraConfigLuaPre = ''
      vim.filetype.add({
        extension = {
          mdx = "markdown.mdx",
        },
      })

      local opt = vim.opt

      opt.clipboard = vim.env.SSH_CONNECTION and "" or "unnamedplus"
      opt.fillchars = {
        foldopen = "",
        foldclose = "",
        fold = " ",
        foldsep = " ",
        diff = "╱",
        eob = " ",
      }
      opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
      opt.shortmess:append({ W = true, I = true, c = true, C = true })
      opt.listchars = {
        tab = "» ",
        trail = "·",
        nbsp = "␣",
      }
    '';
    extraConfigLuaPost = ''
      local function project_root()
        local buf = vim.api.nvim_get_current_buf()
        for _, client in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
          local workspace = client.config.workspace_folders
          if workspace and workspace[1] and workspace[1].uri then
            return vim.uri_to_fname(workspace[1].uri)
          end
          if client.config.root_dir then
            return client.config.root_dir
          end
        end

        local name = vim.api.nvim_buf_get_name(buf)
        if name ~= "" then
          local root = vim.fs.root(name, { ".git", "lua", "package.json", "tsconfig.json", "go.mod", "flake.nix" })
          if root then
            return root
          end
        end

        return vim.fn.getcwd()
      end

      local function root_relative_path()
        local file = vim.api.nvim_buf_get_name(0)
        if file == "" then
          return "[No Name]"
        end
        local root = project_root()
        if file:find(root, 1, true) == 1 then
          return file:sub(#root + 2)
        end
        return vim.fn.fnamemodify(file, ":~:.")
      end

      _G.UserNixvim = _G.UserNixvim or {}
      UserNixvim.project_root = project_root
      UserNixvim.root_relative_path = root_relative_path

      pcall(function()
        local augend = require("dial.augend")
        require("dial.config").augends:register_group({
          default = {
            augend.integer.alias.decimal,
            augend.integer.alias.decimal_int,
            augend.integer.alias.hex,
            augend.date.alias["%Y/%m/%d"],
            augend.constant.alias.en_weekday,
            augend.constant.alias.en_weekday_full,
            augend.constant.alias.bool,
            augend.constant.alias.Bool,
          },
          markdown = {
            augend.constant.new({
              elements = { "[ ]", "[x]" },
              word = false,
              cyclic = true,
            }),
            augend.misc.alias.markdown_header,
          },
          css = {
            augend.hexcolor.new({ case = "lower" }),
            augend.hexcolor.new({ case = "upper" }),
          },
        })
        vim.g.dials_by_ft = {
          css = "css",
          javascript = "default",
          javascriptreact = "default",
          json = "default",
          lua = "default",
          markdown = "markdown",
          python = "default",
          sass = "css",
          scss = "css",
          typescript = "default",
          typescriptreact = "default",
          vue = "css",
        }
      end)

      pcall(function() require("litee.lib").setup() end)
      pcall(function() require("litee.gh").setup({}) end)
    '';
  };
}
