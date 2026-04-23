{
      enable = true;
      inlayHints = true;
      onAttach = ''
        if client and client.server_capabilities and client.server_capabilities.inlayHintProvider and vim.bo[bufnr].filetype ~= "vue" then
          vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
        end
      '';
      servers = {
        ansiblels = { enable = true; package = null; };
        bashls = { enable = true; package = null; };
        dockerls = { enable = true; package = null; };
        docker_compose_language_service = { enable = true; package = null; };
        helm_ls = { enable = true; package = null; };
        intelephense = { enable = true; package = null; };
        marksman = { enable = true; package = null; };
        nil_ls = { enable = true; package = null; };
        pyright = { enable = true; package = null; };
        svelte = { enable = true; package = null; };
        taplo = { enable = true; package = null; };
        terraformls = { enable = true; package = null; };
        vue_ls = { enable = true; package = null; tslsIntegration = false; };

        gopls = {
          enable = true;
          package = null;
          settings.gopls = {
            gofumpt = true;
            codelenses = {
              gc_details = false;
              generate = true;
              regenerate_cgo = true;
              run_govulncheck = true;
              test = true;
              tidy = true;
              upgrade_dependency = true;
              vendor = true;
            };
            hints = {
              assignVariableTypes = true;
              compositeLiteralFields = true;
              compositeLiteralTypes = true;
              constantValues = true;
              functionTypeParameters = true;
              parameterNames = true;
              rangeVariableTypes = true;
            };
            analyses = {
              nilness = true;
              unusedparams = true;
              unusedwrite = true;
              useany = true;
            };
            usePlaceholders = true;
            completeUnimported = true;
            staticcheck = true;
            directoryFilters = [ "-.git" "-.vscode" "-.idea" "-.vscode-test" "-node_modules" ];
            semanticTokens = true;
          };
        };

        jsonls = {
          enable = true;
          package = null;
          settings = {
            schemas.__raw = ''require("schemastore").json.schemas()'';
            validate.enable = true;
          };
        };

        lua_ls = {
          enable = true;
          package = null;
          settings = {
            workspace.checkThirdParty = false;
            codeLens.enable = true;
            completion.callSnippet = "Replace";
            doc.privateName = [ "^_" ];
            hint = {
              enable = true;
              setType = false;
              paramType = true;
              paramName = "Disable";
              semicolon = "Disable";
              arrayIndex = "Disable";
            };
          };
        };

        ruff = {
          enable = true;
          package = null;
          extraOptions = {
            cmd_env.RUFF_TRACE = "messages";
            init_options.settings.logLevel = "error";
          };
          onAttach.function = ''
            client.server_capabilities.hoverProvider = false
          '';
        };

        tailwindcss = {
          enable = true;
          package = null;
          settings.tailwindCSS.includeLanguages = {
            elixir = "html-eex";
            eelixir = "html-eex";
            heex = "html-eex";
          };
        };

        vtsls = {
          enable = true;
          package = null;
          settings.vtsls.tsserver.globalPlugins.__raw = ''
            (function()
              local plugins = {}
              local vue = vim.fn.exepath("vue-language-server")
              if vue ~= "" then
                table.insert(plugins, {
                  name = "@vue/typescript-plugin",
                  location = vim.fn.fnamemodify(vue, ":h:h")
                    .. "/lib/node_modules/@vue/language-server",
                  languages = { "vue" },
                  configNamespace = "typescript",
                  enableForWorkspaceTypeScriptVersions = true,
                })
              end
              local svelte = vim.fn.exepath("svelteserver")
              if svelte ~= "" then
                table.insert(plugins, {
                  name = "typescript-svelte-plugin",
                  location = vim.fn.fnamemodify(svelte, ":h:h")
                    .. "/lib/node_modules/svelte-language-server/node_modules/typescript-svelte-plugin",
                  enableForWorkspaceTypeScriptVersions = true,
                })
              end
              return plugins
            end)()
          '';
        };

        yamlls = {
          enable = true;
          package = null;
          extraOptions = {
            capabilities.textDocument.foldingRange = {
              dynamicRegistration = false;
              lineFoldingOnly = true;
            };
            settings = {
              redhat.telemetry.enabled = false;
              yaml = {
                keyOrdering = false;
                format.enable = true;
                validate = true;
                schemaStore = {
                  enable = false;
                  url = "";
                };
                schemas.__raw = ''require("schemastore").yaml.schemas()'';
              };
            };
          };
        };
      };
}
