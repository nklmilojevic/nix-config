[
      {
        mode = [
          "n"
          "x"
        ];
        key = "j";
        action = "v:count == 0 ? 'gj' : 'j'";
        options = {
          desc = "Down";
          expr = true;
          silent = true;
        };
      }
      {
        mode = [
          "n"
          "x"
        ];
        key = "k";
        action = "v:count == 0 ? 'gk' : 'k'";
        options = {
          desc = "Up";
          expr = true;
          silent = true;
        };
      }
      {
        mode = "n";
        key = "<C-h>";
        action = "<cmd>TmuxNavigateLeft<CR>";
        options.desc = "Go to Left Window";
      }
      {
        mode = "n";
        key = "<C-j>";
        action = "<cmd>TmuxNavigateDown<CR>";
        options.desc = "Go to Lower Window";
      }
      {
        mode = "n";
        key = "<C-k>";
        action = "<cmd>TmuxNavigateUp<CR>";
        options.desc = "Go to Upper Window";
      }
      {
        mode = "n";
        key = "<C-l>";
        action = "<cmd>TmuxNavigateRight<CR>";
        options.desc = "Go to Right Window";
      }
      {
        mode = "n";
        key = "<C-Up>";
        action = "<cmd>resize +2<CR>";
        options.desc = "Increase Window Height";
      }
      {
        mode = "n";
        key = "<C-Down>";
        action = "<cmd>resize -2<CR>";
        options.desc = "Decrease Window Height";
      }
      {
        mode = "n";
        key = "<C-Left>";
        action = "<cmd>vertical resize -2<CR>";
        options.desc = "Decrease Window Width";
      }
      {
        mode = "n";
        key = "<C-Right>";
        action = "<cmd>vertical resize +2<CR>";
        options.desc = "Increase Window Width";
      }
      {
        mode = "n";
        key = "<S-h>";
        action = "<cmd>BufferLineCyclePrev<CR>";
        options.desc = "Prev Buffer";
      }
      {
        mode = "n";
        key = "<S-l>";
        action = "<cmd>BufferLineCycleNext<CR>";
        options.desc = "Next Buffer";
      }
      {
        mode = "n";
        key = "[b";
        action = "<cmd>BufferLineCyclePrev<CR>";
        options.desc = "Prev Buffer";
      }
      {
        mode = "n";
        key = "]b";
        action = "<cmd>BufferLineCycleNext<CR>";
        options.desc = "Next Buffer";
      }
      {
        mode = "n";
        key = "[B";
        action = "<cmd>BufferLineMovePrev<CR>";
        options.desc = "Move Buffer Prev";
      }
      {
        mode = "n";
        key = "]B";
        action = "<cmd>BufferLineMoveNext<CR>";
        options.desc = "Move Buffer Next";
      }
      {
        mode = "n";
        key = "<leader>bb";
        action = "<cmd>e #<CR>";
        options.desc = "Switch to Other Buffer";
      }
      {
        mode = "n";
        key = "<leader>`";
        action = "<cmd>e #<CR>";
        options.desc = "Switch to Other Buffer";
      }
      {
        mode = "n";
        key = "<leader>bD";
        action = "<cmd>:bd<CR>";
        options.desc = "Delete Buffer and Window";
      }
      {
        mode = "n";
        key = "<leader>ur";
        action = "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>";
        options.desc = "Redraw / Clear hlsearch / Diff Update";
      }
      {
        mode = "n";
        key = "n";
        action = "'Nn'[v:searchforward].'zv'";
        options = {
          desc = "Next Search Result";
          expr = true;
        };
      }
      {
        mode = "n";
        key = "N";
        action = "'nN'[v:searchforward].'zv'";
        options = {
          desc = "Prev Search Result";
          expr = true;
        };
      }
      {
        mode = "i";
        key = ",";
        action = ",<c-g>u";
      }
      {
        mode = "i";
        key = ".";
        action = ".<c-g>u";
      }
      {
        mode = "i";
        key = ";";
        action = ";<c-g>u";
      }
      {
        mode = [
          "i"
          "x"
          "n"
          "s"
        ];
        key = "<C-s>";
        action = "<cmd>w<CR><esc>";
        options.desc = "Save File";
      }
      {
        mode = "n";
        key = "<leader>K";
        action = "<cmd>norm! K<CR>";
        options.desc = "Keywordprg";
      }
      {
        mode = "x";
        key = "<";
        action = "<gv";
      }
      {
        mode = "x";
        key = ">";
        action = ">gv";
      }
      {
        mode = "n";
        key = "<leader>fn";
        action = "<cmd>enew<CR>";
        options.desc = "New File";
      }
      {
        mode = "n";
        key = "<leader>xx";
        action = "<cmd>Trouble diagnostics toggle<CR>";
        options.desc = "Diagnostics (Trouble)";
      }
      {
        mode = "n";
        key = "<leader>xX";
        action = "<cmd>Trouble diagnostics toggle filter.buf=0<CR>";
        options.desc = "Buffer Diagnostics (Trouble)";
      }
      {
        mode = "n";
        key = "<leader>cs";
        action = "<cmd>Trouble symbols toggle<CR>";
        options.desc = "Symbols (Trouble)";
      }
      {
        mode = "n";
        key = "<leader>cS";
        action = "<cmd>Trouble lsp toggle<CR>";
        options.desc = "LSP references/definitions/... (Trouble)";
      }
      {
        mode = "n";
        key = "<leader>xL";
        action = "<cmd>Trouble loclist toggle<CR>";
        options.desc = "Location List (Trouble)";
      }
      {
        mode = "n";
        key = "<leader>xQ";
        action = "<cmd>Trouble qflist toggle<CR>";
        options.desc = "Quickfix List (Trouble)";
      }
      {
        mode = "n";
        key = "<leader>xt";
        action = "<cmd>Trouble todo toggle<CR>";
        options.desc = "Todo (Trouble)";
      }
      {
        mode = "n";
        key = "<leader>xT";
        action = "<cmd>Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}<CR>";
        options.desc = "Todo/Fix/Fixme (Trouble)";
      }
      {
        mode = [
          "n"
          "x"
        ];
        key = "y";
        action = "<Plug>(YankyYank)";
        options.desc = "Yank Text";
      }
      {
        mode = [
          "n"
          "x"
        ];
        key = "p";
        action = "<Plug>(YankyPutAfter)";
        options.desc = "Put Text After Cursor";
      }
      {
        mode = [
          "n"
          "x"
        ];
        key = "P";
        action = "<Plug>(YankyPutBefore)";
        options.desc = "Put Text Before Cursor";
      }
      {
        mode = "n";
        key = "<leader>cp";
        action = "<cmd>MarkdownPreviewToggle<CR>";
        options.desc = "Markdown Preview";
      }
      {
        mode = "n";
        key = "<leader>D";
        action = "<cmd>DBUIToggle<CR>";
        options.desc = "Toggle DBUI";
      }
      {
        mode = "n";
        key = "<leader>cv";
        action = "<cmd>VenvSelect<CR>";
        options.desc = "Select VirtualEnv";
      }
      {
        mode = "n";
        key = "<leader>qq";
        action = "<cmd>qa<CR>";
        options.desc = "Quit All";
      }
      {
        mode = "n";
        key = "<leader>-";
        action = "<C-W>s";
        options = {
          desc = "Split Window Below";
          remap = true;
        };
      }
      {
        mode = "n";
        key = "<leader>|";
        action = "<C-W>v";
        options = {
          desc = "Split Window Right";
          remap = true;
        };
      }
      {
        mode = "n";
        key = "<leader>wd";
        action = "<C-W>c";
        options = {
          desc = "Delete Window";
          remap = true;
        };
      }
      {
        mode = "n";
        key = "<leader><tab>l";
        action = "<cmd>tablast<CR>";
        options.desc = "Last Tab";
      }
      {
        mode = "n";
        key = "<leader><tab>o";
        action = "<cmd>tabonly<CR>";
        options.desc = "Close Other Tabs";
      }
      {
        mode = "n";
        key = "<leader><tab>f";
        action = "<cmd>tabfirst<CR>";
        options.desc = "First Tab";
      }
      {
        mode = "n";
        key = "<leader><tab><tab>";
        action = "<cmd>tabnew<CR>";
        options.desc = "New Tab";
      }
      {
        mode = "n";
        key = "<leader><tab>]";
        action = "<cmd>tabnext<CR>";
        options.desc = "Next Tab";
      }
      {
        mode = "n";
        key = "<leader><tab>d";
        action = "<cmd>tabclose<CR>";
        options.desc = "Close Tab";
      }
      {
        mode = "n";
        key = "<leader><tab>[";
        action = "<cmd>tabprevious<CR>";
        options.desc = "Previous Tab";
      }
      {
        mode = "n";
        key = "<leader>Gc";
        action = "";
        options.desc = "+Commits";
      }
      {
        mode = "n";
        key = "<leader>Gi";
        action = "";
        options.desc = "+Issues";
      }
      {
        mode = "n";
        key = "<leader>Gl";
        action = "";
        options.desc = "+Litee";
      }
      {
        mode = "n";
        key = "<leader>Gp";
        action = "";
        options.desc = "+Pull Request";
      }
      {
        mode = "n";
        key = "<leader>Gr";
        action = "";
        options.desc = "+Review";
      }
      {
        mode = "n";
        key = "<leader>Gt";
        action = "";
        options.desc = "+Threads";
      }
      {
        mode = "n";
        key = "<leader>Gcc";
        action = "<cmd>GHCloseCommit<CR>";
        options.desc = "Close";
      }
      {
        mode = "n";
        key = "<leader>Gce";
        action = "<cmd>GHExpandCommit<CR>";
        options.desc = "Expand";
      }
      {
        mode = "n";
        key = "<leader>Gco";
        action = "<cmd>GHOpenToCommit<CR>";
        options.desc = "Open To";
      }
      {
        mode = "n";
        key = "<leader>Gcp";
        action = "<cmd>GHPopOutCommit<CR>";
        options.desc = "Pop Out";
      }
      {
        mode = "n";
        key = "<leader>Gcz";
        action = "<cmd>GHCollapseCommit<CR>";
        options.desc = "Collapse";
      }
      {
        mode = "n";
        key = "<leader>Gip";
        action = "<cmd>GHPreviewIssue<CR>";
        options.desc = "Preview";
      }
      {
        mode = "n";
        key = "<leader>Gio";
        action = "<cmd>GHOpenIssue<CR>";
        options.desc = "Open";
      }
      {
        mode = "n";
        key = "<leader>Glt";
        action = "<cmd>LTPanel<CR>";
        options.desc = "Toggle Panel";
      }
      {
        mode = "n";
        key = "<leader>Gpc";
        action = "<cmd>GHClosePR<CR>";
        options.desc = "Close";
      }
      {
        mode = "n";
        key = "<leader>Gpd";
        action = "<cmd>GHPRDetails<CR>";
        options.desc = "Details";
      }
      {
        mode = "n";
        key = "<leader>Gpe";
        action = "<cmd>GHExpandPR<CR>";
        options.desc = "Expand";
      }
      {
        mode = "n";
        key = "<leader>Gpo";
        action = "<cmd>GHOpenPR<CR>";
        options.desc = "Open";
      }
      {
        mode = "n";
        key = "<leader>Gpp";
        action = "<cmd>GHPopOutPR<CR>";
        options.desc = "PopOut";
      }
      {
        mode = "n";
        key = "<leader>Gpr";
        action = "<cmd>GHRefreshPR<CR>";
        options.desc = "Refresh";
      }
      {
        mode = "n";
        key = "<leader>Gpt";
        action = "<cmd>GHOpenToPR<CR>";
        options.desc = "Open To";
      }
      {
        mode = "n";
        key = "<leader>Gpz";
        action = "<cmd>GHCollapsePR<CR>";
        options.desc = "Collapse";
      }
      {
        mode = "n";
        key = "<leader>Grb";
        action = "<cmd>GHStartReview<CR>";
        options.desc = "Begin";
      }
      {
        mode = "n";
        key = "<leader>Grc";
        action = "<cmd>GHCloseReview<CR>";
        options.desc = "Close";
      }
      {
        mode = "n";
        key = "<leader>Grd";
        action = "<cmd>GHDeleteReview<CR>";
        options.desc = "Delete";
      }
      {
        mode = "n";
        key = "<leader>Gre";
        action = "<cmd>GHExpandReview<CR>";
        options.desc = "Expand";
      }
      {
        mode = "n";
        key = "<leader>Grs";
        action = "<cmd>GHSubmitReview<CR>";
        options.desc = "Submit";
      }
      {
        mode = "n";
        key = "<leader>Grz";
        action = "<cmd>GHCollapseReview<CR>";
        options.desc = "Collapse";
      }
      {
        mode = "n";
        key = "<leader>Gtc";
        action = "<cmd>GHCreateThread<CR>";
        options.desc = "Create";
      }
      {
        mode = "n";
        key = "<leader>Gtn";
        action = "<cmd>GHNextThread<CR>";
        options.desc = "Next";
      }
      {
        mode = "n";
        key = "<leader>Gtt";
        action = "<cmd>GHToggleThread<CR>";
        options.desc = "Toggle";
      }
      {
        mode = "n";
        key = "<leader>bd";
        action.__raw = "function() Snacks.bufdelete() end";
        options.desc = "Delete Buffer";
      }
      {
        mode = "n";
        key = "<leader>bo";
        action.__raw = "function() Snacks.bufdelete.other() end";
        options.desc = "Delete Other Buffers";
      }
      {
        mode = [
          "i"
          "n"
          "s"
        ];
        key = "<esc>";
        action.__raw = ''
          function()
            vim.cmd("noh")
            return "<esc>"
          end
        '';
        options = {
          expr = true;
          desc = "Escape and Clear hlsearch";
        };
      }
      {
        mode = "n";
        key = "gco";
        action = "o<esc>Vcx<esc><cmd>normal gcc<CR>fxa<bs>";
        options.desc = "Add Comment Below";
      }
      {
        mode = "n";
        key = "gcO";
        action = "O<esc>Vcx<esc><cmd>normal gcc<CR>fxa<bs>";
        options.desc = "Add Comment Above";
      }
      {
        mode = "n";
        key = "<leader>xl";
        action.__raw = ''
          function()
            local success, err = pcall(vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 and vim.cmd.lclose or vim.cmd.lopen)
            if not success and err then
              vim.notify(err, vim.log.levels.ERROR)
            end
          end
        '';
        options.desc = "Location List";
      }
      {
        mode = "n";
        key = "<leader>xq";
        action.__raw = ''
          function()
            local success, err = pcall(vim.fn.getqflist({ winid = 0 }).winid ~= 0 and vim.cmd.cclose or vim.cmd.copen)
            if not success and err then
              vim.notify(err, vim.log.levels.ERROR)
            end
          end
        '';
        options.desc = "Quickfix List";
      }
      {
        mode = [
          "n"
          "x"
        ];
        key = "<leader>cf";
        action.__raw = ''function() require("conform").format({ async = false, lsp_format = "fallback" }) end'';
        options.desc = "Format";
      }
      {
        mode = "n";
        key = "<leader>cd";
        action.__raw = "function() vim.diagnostic.open_float() end";
        options.desc = "Line Diagnostics";
      }
      {
        mode = "n";
        key = "]d";
        action.__raw = "function() vim.diagnostic.jump({ count = vim.v.count1, float = true }) end";
        options.desc = "Next Diagnostic";
      }
      {
        mode = "n";
        key = "[d";
        action.__raw = "function() vim.diagnostic.jump({ count = -vim.v.count1, float = true }) end";
        options.desc = "Prev Diagnostic";
      }
      {
        mode = "n";
        key = "]e";
        action.__raw = "function() vim.diagnostic.jump({ count = vim.v.count1, severity = vim.diagnostic.severity.ERROR, float = true }) end";
        options.desc = "Next Error";
      }
      {
        mode = "n";
        key = "[e";
        action.__raw = "function() vim.diagnostic.jump({ count = -vim.v.count1, severity = vim.diagnostic.severity.ERROR, float = true }) end";
        options.desc = "Prev Error";
      }
      {
        mode = "n";
        key = "]w";
        action.__raw = "function() vim.diagnostic.jump({ count = vim.v.count1, severity = vim.diagnostic.severity.WARN, float = true }) end";
        options.desc = "Next Warning";
      }
      {
        mode = "n";
        key = "[w";
        action.__raw = "function() vim.diagnostic.jump({ count = -vim.v.count1, severity = vim.diagnostic.severity.WARN, float = true }) end";
        options.desc = "Prev Warning";
      }
      {
        mode = "n";
        key = "<leader>,";
        action.__raw = "function() Snacks.picker.buffers() end";
        options.desc = "Buffers";
      }
      {
        mode = "n";
        key = "<leader>/";
        action.__raw = "function() Snacks.picker.grep({ cwd = UserNixvim.project_root() }) end";
        options.desc = "Grep (Root Dir)";
      }
      {
        mode = "n";
        key = "<leader><space>";
        action.__raw = "function() Snacks.picker.files({ cwd = UserNixvim.project_root() }) end";
        options.desc = "Find Files (Root Dir)";
      }
      {
        mode = "n";
        key = "<leader>fb";
        action.__raw = "function() Snacks.picker.buffers() end";
        options.desc = "Buffers";
      }
      {
        mode = "n";
        key = "<leader>fc";
        action.__raw = ''function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end'';
        options.desc = "Find Config File";
      }
      {
        mode = "n";
        key = "<leader>ff";
        action.__raw = "function() Snacks.picker.files({ cwd = UserNixvim.project_root() }) end";
        options.desc = "Find Files (Root Dir)";
      }
      {
        mode = "n";
        key = "<leader>fF";
        action.__raw = "function() Snacks.picker.files({ cwd = vim.fn.getcwd() }) end";
        options.desc = "Find Files (cwd)";
      }
      {
        mode = "n";
        key = "<leader>fg";
        action.__raw = "function() Snacks.picker.git_files({ cwd = UserNixvim.project_root() }) end";
        options.desc = "Find Files (git-files)";
      }
      {
        mode = "n";
        key = "<leader>fr";
        action.__raw = "function() Snacks.picker.recent() end";
        options.desc = "Recent";
      }
      {
        mode = "n";
        key = "<leader>fp";
        action.__raw = "function() Snacks.picker.projects() end";
        options.desc = "Projects";
      }
      {
        mode = "n";
        key = "<leader>sg";
        action.__raw = "function() Snacks.picker.grep({ cwd = UserNixvim.project_root() }) end";
        options.desc = "Grep (Root Dir)";
      }
      {
        mode = "n";
        key = "<leader>sG";
        action.__raw = "function() Snacks.picker.grep({ cwd = vim.fn.getcwd() }) end";
        options.desc = "Grep (cwd)";
      }
      {
        mode = [
          "n"
          "x"
        ];
        key = "<leader>sw";
        action.__raw = "function() Snacks.picker.grep_word({ cwd = UserNixvim.project_root() }) end";
        options.desc = "Visual selection or word (Root Dir)";
      }
      {
        mode = [
          "n"
          "x"
        ];
        key = "<leader>sW";
        action.__raw = "function() Snacks.picker.grep_word({ cwd = vim.fn.getcwd() }) end";
        options.desc = "Visual selection or word (cwd)";
      }
      {
        mode = "n";
        key = "<leader>sd";
        action.__raw = "function() Snacks.picker.diagnostics() end";
        options.desc = "Diagnostics";
      }
      {
        mode = "n";
        key = "<leader>sD";
        action.__raw = "function() Snacks.picker.diagnostics_buffer() end";
        options.desc = "Buffer Diagnostics";
      }
      {
        mode = "n";
        key = "<leader>sh";
        action.__raw = "function() Snacks.picker.help() end";
        options.desc = "Help Pages";
      }
      {
        mode = "n";
        key = "<leader>sk";
        action.__raw = "function() Snacks.picker.keymaps() end";
        options.desc = "Keymaps";
      }
      {
        mode = "n";
        key = "<leader>sq";
        action.__raw = "function() Snacks.picker.qflist() end";
        options.desc = "Quickfix List";
      }
      {
        mode = "n";
        key = "<leader>s/";
        action.__raw = "function() Snacks.picker.search_history() end";
        options.desc = "Search History";
      }
      {
        mode = "n";
        key = "<leader>su";
        action.__raw = "function() Snacks.picker.undo() end";
        options.desc = "Undotree";
      }
      {
        mode = "n";
        key = "<leader>uC";
        action.__raw = "function() Snacks.picker.colorschemes() end";
        options.desc = "Colorschemes";
      }
      {
        mode = "n";
        key = "<leader>n";
        action.__raw = "function() Snacks.picker.notifications() end";
        options.desc = "Notification History";
      }
      {
        mode = "n";
        key = "<leader>un";
        action.__raw = "function() Snacks.notifier.hide() end";
        options.desc = "Dismiss All Notifications";
      }
      {
        mode = "n";
        key = "<leader>uf";
        action.__raw = "function() vim.g.autoformat = not vim.g.autoformat end";
        options.desc = "Toggle Auto Format";
      }
      {
        mode = "n";
        key = "<leader>us";
        action.__raw = "function() vim.opt.spell = not vim.opt.spell:get() end";
        options.desc = "Spelling";
      }
      {
        mode = "n";
        key = "<leader>uw";
        action.__raw = "function() vim.opt.wrap = not vim.opt.wrap:get() end";
        options.desc = "Wrap";
      }
      {
        mode = "n";
        key = "<leader>uL";
        action.__raw = "function() vim.opt.relativenumber = not vim.opt.relativenumber:get() end";
        options.desc = "Relative Number";
      }
      {
        mode = "n";
        key = "<leader>ud";
        action.__raw = "function() vim.diagnostic.enable(not vim.diagnostic.is_enabled()) end";
        options.desc = "Diagnostics";
      }
      {
        mode = "n";
        key = "<leader>ul";
        action.__raw = "function() vim.opt.number = not vim.opt.number:get() end";
        options.desc = "Line Number";
      }
      {
        mode = "n";
        key = "<leader>uc";
        action.__raw = "function() vim.opt.conceallevel = vim.opt.conceallevel:get() > 0 and 0 or 2 end";
        options.desc = "Conceal Level";
      }
      {
        mode = "n";
        key = "<leader>ub";
        action.__raw = ''function() vim.opt.background = vim.opt.background:get() == "dark" and "light" or "dark" end'';
        options.desc = "Dark Background";
      }
      {
        mode = "n";
        key = "<leader>ut";
        action.__raw = ''
          function()
            local tsc = require("treesitter-context")
            if tsc.enabled() then
              tsc.disable()
            else
              tsc.enable()
            end
          end
        '';
        options.desc = "Treesitter Context";
      }
      {
        mode = "n";
        key = "<leader>um";
        action.__raw = ''
          function()
            local rm = require("render-markdown")
            rm.set(not rm.get())
          end
        '';
        options.desc = "Render Markdown";
      }
      {
        mode = "n";
        key = "<leader>gg";
        action.__raw = ''
          function()
            if vim.fn.executable("lazygit") == 1 then
              Snacks.lazygit({ cwd = UserNixvim.project_root() })
            end
          end
        '';
        options.desc = "Lazygit (Root Dir)";
      }
      {
        mode = "n";
        key = "<leader>gG";
        action.__raw = ''
          function()
            if vim.fn.executable("lazygit") == 1 then
              Snacks.lazygit()
            end
          end
        '';
        options.desc = "Lazygit (cwd)";
      }
      {
        mode = "n";
        key = "<leader>gL";
        action.__raw = "function() Snacks.picker.git_log() end";
        options.desc = "Git Log (cwd)";
      }
      {
        mode = "n";
        key = "<leader>gb";
        action.__raw = "function() Snacks.picker.git_log_line() end";
        options.desc = "Git Blame Line";
      }
      {
        mode = "n";
        key = "<leader>gf";
        action.__raw = "function() Snacks.picker.git_log_file() end";
        options.desc = "Git Current File History";
      }
      {
        mode = "n";
        key = "<leader>gl";
        action.__raw = "function() Snacks.picker.git_log({ cwd = UserNixvim.project_root() }) end";
        options.desc = "Git Log";
      }
      {
        mode = [
          "n"
          "x"
        ];
        key = "<leader>gB";
        action.__raw = "function() Snacks.gitbrowse() end";
        options.desc = "Git Browse (open)";
      }
      {
        mode = [
          "n"
          "x"
        ];
        key = "<leader>gY";
        action.__raw = ''
          function()
            Snacks.gitbrowse({
              open = function(url)
                vim.fn.setreg("+", url)
              end,
              notify = false,
            })
          end
        '';
        options.desc = "Git Browse (copy)";
      }
      {
        mode = "n";
        key = "]q";
        action.__raw = ''
          function()
            if require("trouble").is_open() then
              require("trouble").next({ skip_groups = true, jump = true })
            else
              pcall(vim.cmd.cnext)
            end
          end
        '';
        options.desc = "Next Trouble/Quickfix Item";
      }
      {
        mode = "n";
        key = "[q";
        action.__raw = ''
          function()
            if require("trouble").is_open() then
              require("trouble").prev({ skip_groups = true, jump = true })
            else
              pcall(vim.cmd.cprev)
            end
          end
        '';
        options.desc = "Prev Trouble/Quickfix Item";
      }
      {
        mode = "n";
        key = "]t";
        action.__raw = ''function() require("todo-comments").jump_next() end'';
        options.desc = "Next Todo Comment";
      }
      {
        mode = "n";
        key = "[t";
        action.__raw = ''function() require("todo-comments").jump_prev() end'';
        options.desc = "Previous Todo Comment";
      }
      {
        mode = "n";
        key = "<leader>st";
        action.__raw = "function() Snacks.picker.todo_comments() end";
        options.desc = "Todo";
      }
      {
        mode = "n";
        key = "<leader>sT";
        action.__raw = ''function() Snacks.picker.todo_comments({ keywords = { "TODO", "FIX", "FIXME" } }) end'';
        options.desc = "Todo/Fix/Fixme";
      }
      {
        mode = [
          "n"
          "v"
        ];
        key = "<C-a>";
        action.__raw = ''
          function()
            local mode = vim.fn.mode(true)
            local is_visual = mode == "v" or mode == "V" or mode == "\22"
            local func = is_visual and "inc_visual" or "inc_normal"
            return require("dial.map")[func]("default")
          end
        '';
        options = {
          expr = true;
          desc = "Increment";
        };
      }
      {
        mode = [
          "n"
          "v"
        ];
        key = "<C-x>";
        action.__raw = ''
          function()
            local mode = vim.fn.mode(true)
            local is_visual = mode == "v" or mode == "V" or mode == "\22"
            local func = is_visual and "dec_visual" or "dec_normal"
            return require("dial.map")[func]("default")
          end
        '';
        options = {
          expr = true;
          desc = "Decrement";
        };
      }
      {
        mode = "n";
        key = "<leader>p";
        action.__raw = "function() Snacks.picker.yanky() end";
        options.desc = "Open Yank History";
      }
      {
        mode = "n";
        key = "<leader>cr";
        action.__raw = ''function() return ":" .. require("inc_rename").config.cmd_name .. " " .. vim.fn.expand("<cword>") end'';
        options = {
          expr = true;
          desc = "Rename (inc-rename.nvim)";
        };
      }
      {
        mode = "n";
        key = "<leader>sr";
        action.__raw = ''
          function()
            local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
            require("grug-far").open({
              transient = true,
              prefills = {
                filesFilter = ext and ext ~= "" and "*." .. ext or nil,
              },
            })
          end
        '';
        options.desc = "Search and Replace";
      }
      {
        mode = "n";
        key = "gd";
        action.__raw = "function() Snacks.picker.lsp_definitions() end";
        options.desc = "Goto Definition";
      }
      {
        mode = "n";
        key = "gr";
        action.__raw = "function() Snacks.picker.lsp_references() end";
        options = {
          desc = "References";
          nowait = true;
        };
      }
      {
        mode = "n";
        key = "gI";
        action.__raw = "function() Snacks.picker.lsp_implementations() end";
        options.desc = "Goto Implementation";
      }
      {
        mode = "n";
        key = "gy";
        action.__raw = "function() Snacks.picker.lsp_type_definitions() end";
        options.desc = "Goto Type Definition";
      }
      {
        mode = "n";
        key = "gD";
        action.__raw = "function() vim.lsp.buf.declaration() end";
        options.desc = "Goto Declaration";
      }
      {
        mode = "n";
        key = "K";
        action.__raw = "function() vim.lsp.buf.hover() end";
        options.desc = "Hover";
      }
      {
        mode = "i";
        key = "<C-k>";
        action.__raw = "function() vim.lsp.buf.signature_help() end";
        options.desc = "Signature Help";
      }
      {
        mode = "n";
        key = "gK";
        action.__raw = "function() vim.lsp.buf.signature_help() end";
        options.desc = "Signature Help";
      }
      {
        mode = [
          "n"
          "x"
        ];
        key = "<leader>ca";
        action.__raw = "function() vim.lsp.buf.code_action() end";
        options.desc = "Code Action";
      }
      {
        mode = "n";
        key = "<leader>cl";
        action.__raw = "function() Snacks.picker.lsp_config() end";
        options.desc = "Lsp Info";
      }
      {
        mode = "n";
        key = "<leader>ss";
        action.__raw = "function() Snacks.picker.lsp_symbols() end";
        options.desc = "LSP Symbols";
      }
      {
        mode = "n";
        key = "<leader>sS";
        action.__raw = "function() Snacks.picker.lsp_workspace_symbols() end";
        options.desc = "LSP Workspace Symbols";
      }
      {
        mode = "n";
        key = "<leader>ui";
        action.__raw = "function() vim.show_pos() end";
        options.desc = "Inspect Pos";
      }
      {
        mode = "n";
        key = "<leader>uI";
        action.__raw = ''
          function()
            vim.treesitter.inspect_tree()
            vim.api.nvim_input("I")
          end
        '';
        options.desc = "Inspect Tree";
      }
      {
        mode = "n";
        key = "<leader>fT";
        action.__raw = "function() Snacks.terminal() end";
        options.desc = "Terminal (cwd)";
      }
      {
        mode = "n";
        key = "<leader>ft";
        action.__raw = "function() Snacks.terminal(nil, { cwd = UserNixvim.project_root() }) end";
        options.desc = "Terminal (Root Dir)";
      }
      {
        mode = [
          "n"
          "t"
        ];
        key = "<c-/>";
        action.__raw = "function() Snacks.terminal(nil, { cwd = UserNixvim.project_root() }) end";
        options.desc = "Terminal (Root Dir)";
      }
]
