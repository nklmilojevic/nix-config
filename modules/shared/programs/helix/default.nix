{pkgs, ...}: {
  programs.helix = with pkgs; {
    enable = true;
    defaultEditor = true;
    extraPackages = [
      bash-language-server
      clang-tools
      docker-compose-language-service
      dockerfile-language-server-nodejs
      golangci-lint
      golangci-lint-langserver
      gopls
      gotools
      lua-language-server
      marksman
      nixd
      nixpkgs-fmt
      nodePackages.prettier
      nodePackages.typescript-language-server
      pgformatter
      (python3.withPackages (p: (with p; [
        ruff
        python-lsp-ruff
        python-lsp-server
      ])))
      rust-analyzer
      ruby_3_4
      rubyPackages_3_4.solargraph
      stylua
      taplo
      taplo-lsp
      terraform-ls
      typescript
      vscode-langservers-extracted
      yaml-language-server
    ];

    settings = {
      theme = "catppuccin_mocha";

      editor = {
        color-modes = true;
        cursorline = true;
        bufferline = "multiple";

        soft-wrap.enable = true;

        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };

        file-picker = {
          hidden = false;
          ignore = false;
        };

        indent-guides = {
          render = true;
        };

        end-of-line-diagnostics = "hint";
        inline-diagnostics.cursor-line = "warning";

        lsp = {
          display-inlay-hints = true;
          display-messages = true;
        };

        statusline = {
          left = ["mode" "file-name" "spinner" "read-only-indicator" "file-modification-indicator"];
          right = ["diagnostics" "selections" "register" "file-type" "file-line-ending" "position"];
          mode.normal = "";
          mode.insert = "I";
          mode.select = "S";
        };
      };
    };

    languages = {
      language-server.lsp-ai = {
        command = "lsp-ai";
        config = {
          actions = [
            {
              action_display_name = "Complete";
              model = "model1";
              parameters = {
                max_context = 4096;
                max_tokens = 4096;
                system = ''
                  You are an AI coding assistant. Your task is to complete code snippets. The user's cursor position is marked by "<CURSOR>". Follow these steps:

                  1. Analyze the code context and the cursor position.
                  2. Provide your chain of thought reasoning, wrapped in <reasoning> tags. Include thoughts about the cursor position, what needs to be completed, and any necessary formatting.
                  3. Determine the appropriate code to complete the current thought, including finishing partial words or lines.
                  4. Replace "<CURSOR>" with the necessary code, ensuring proper formatting and line breaks.
                  5. Wrap your code solution in <answer> tags. Only code should be in <answer>, not reasoning.

                  Your response should always include both the reasoning and the answer. Pay special attention to completing partial words or lines before adding new lines of code.

                  <examples>
                  <example>
                  User input:
                  --main.py--
                  # A function that reads in user inpu<CURSOR>

                  Response:
                  <reasoning>
                  1. The cursor is positioned after "inpu" in a comment describing a function that reads user input.
                  2. We need to complete the word "input" in the comment first.
                  3. After completing the comment, we should add a new line before defining the function.
                  4. The function should use Python's built-in `input()` function to read user input.
                  5. We'll name the function descriptively and include a return statement.
                  </reasoning>

                  <answer>t
                  def read_user_input():
                      user_input = input("Enter your input: ")
                      return user_input
                  </answer>
                  </example>

                  <example>
                  User input:
                  --main.py--
                  def fibonacci(n):
                      if n <= 1:
                          return n
                      else:
                          re<CURSOR>


                  Response:
                  <reasoning>
                  1. The cursor is positioned after "re" in the 'else' clause of a recursive Fibonacci function.
                  2. We need to complete the return statement for the recursive case.
                  3. The "re" already present likely stands for "return", so we'll continue from there.
                  4. The Fibonacci sequence is the sum of the two preceding numbers.
                  5. We should return the sum of fibonacci(n-1) and fibonacci(n-2).
                  </reasoning>

                  <answer>turn fibonacci(n-1) + fibonacci(n-2)</answer>
                  </example>
                  </examples>
                '';
                messages = [
                  {
                    role = "user";
                    content = "{CODE}";
                  }
                ];
              };
              post_process = {
                extractor = "(?s)<answer>(.*?)</answer>";
              };
            }
            {
              action_display_name = "Refactor";
              model = "model1";
              parameters = {
                max_context = 4096;
                max_tokens = 4096;
                system = ''
                  You are an AI coding assistant specializing in code refactoring. Your task is to analyze the given code snippet and provide a refactored version that REPLACES the selected code. The refactored code must maintain the same functionality while improving its structure, efficiency, or readability. Do not include any explanation text in your response - only the refactored code wrapped in <answer> tags.
                '';
                messages = [
                  {
                    role = "user";
                    content = "Refactor this code:\n{SELECTED_TEXT}";
                  }
                ];
              };
              post_process = {
                extractor = "(?s)<answer>(.*?)</answer>";
              };
            }
          ];

          memory.file_store = {};
          models.model1 = {
            type = "open_ai";
            chat_endpoint = "https://api.openai.com/v1/chat/completions";
            model = "gpt-4o";
            auth_token_env_var_name = "OPENAI_API_KEY";
          };
          completion = {
            model = "model1";
            parameters = {
              max_tokens = 64;
              max_context = 1024;
              messages = [
                {
                  role = "system";
                  content = ''
                    Instructions:
                    - You are an AI programming assistant.
                    - Given a piece of code with the cursor location marked by "<CURSOR>", replace "<CURSOR>" with the correct code or comment.
                    - First, think step-by-step.
                    - Describe your plan for what to build in pseudocode, written out in great detail.
                    - Then output the code replacing the "<CURSOR>"
                    - Ensure that your completion fits within the language context of the provided code snippet (e.g., Python, JavaScript, Rust).

                    Rules:
                    - Only respond with code or comments.
                    - Only replace "<CURSOR>"; do not include any previously written code.
                    - Never include "<CURSOR>" in your response
                    - If the cursor is within a comment, complete the comment meaningfully.
                    - Handle ambiguous cases by providing the most contextually appropriate completion.
                    - Be consistent with your responses.
                  '';
                }
                {
                  role = "user";
                  content = "def greet(name):\n    print(f\"Hello, {<CURSOR>}\")";
                }
                {
                  role = "assistant";
                  content = "name";
                }
                {
                  role = "user";
                  content = "function sum(a, b) {\n    return a + <CURSOR>;\n}";
                }
                {
                  role = "assistant";
                  content = "b";
                }
                {
                  role = "user";
                  content = "fn multiply(a: i32, b: i32) -> i32 {\n    a * <CURSOR>\n}";
                }
                {
                  role = "assistant";
                  content = "b";
                }
                {
                  role = "user";
                  content = "# <CURSOR>\ndef add(a, b):\n    return a + b";
                }
                {
                  role = "assistant";
                  content = "Adds two numbers";
                }
                {
                  role = "user";
                  content = "# This function checks if a number is even\n<CURSOR>";
                }
                {
                  role = "assistant";
                  content = "def is_even(n):\n    return n % 2 == 0";
                }
                {
                  role = "user";
                  content = "{CODE}";
                }
              ];
            };
          };
        };
      };

      language-server.biome = {
        command = "biome";
        args = ["lsp-proxy"];
      };

      language-server.rust-analyzer.config.check = {
        command = "clippy";
      };

      language-server.yaml-language-server.config.yaml.schemas = {
        kubernetes = "kubernetes/*.yaml";
      };

      language-server.typescript-language-server.config.tsserver = {
        path = "${pkgs.typescript}/lib/node_modules/typescript/lib/tsserver.js";
      };

      language = [
        {
          name = "css";
          language-servers = ["vscode-css-language-server" "lsp-ai"];
          formatter = {
            command = "prettier";
            args = ["--stdin-filepath" "file.css"];
          };
          auto-format = true;
        }
        {
          name = "go";
          language-servers = ["gopls" "golangci-lint-lsp" "lsp-ai"];
          formatter = {
            command = "goimports";
          };
          auto-format = true;
        }
        {
          name = "html";
          language-servers = ["vscode-html-language-server" "lsp-ai"];
          formatter = {
            command = "prettier";
            args = ["--stdin-filepath" "file.html"];
          };
          auto-format = true;
        }
        {
          name = "javascript";
          language-servers = [
            {
              name = "typescript-language-server";
              except-features = ["format"];
            }
            "biome"
            "lsp-ai"
          ];
          auto-format = true;
        }
        {
          name = "json";
          language-servers = [
            {
              name = "vscode-json-language-server";
              except-features = ["format"];
            }
            "biome"
          ];
          formatter = {
            command = "biome";
            args = ["format" "--indent-style" "space" "--stdin-file-path" "file.json"];
          };
          auto-format = true;
        }
        {
          name = "jsonc";
          language-servers = [
            {
              name = "vscode-json-language-server";
              except-features = ["format"];
            }
            "biome"
          ];
          formatter = {
            command = "biome";
            args = ["format" "--indent-style" "space" "--stdin-file-path" "file.jsonc"];
          };
          file-types = ["jsonc" "hujson"];
          auto-format = true;
        }
        {
          name = "jsx";
          language-servers = [
            {
              name = "typescript-language-server";
              except-features = ["format"];
            }
            "biome"
            "gpt"
          ];
          formatter = {
            command = "biome";
            args = ["format" "--indent-style" "space" "--stdin-file-path" "file.jsx"];
          };
          auto-format = true;
        }
        {
          name = "lua";
          language-servers = ["lua-language-server" "lsp-ai"];
          formatter = {
            command = "stylua";
            args = ["-"];
          };
          auto-format = true;
        }
        {
          name = "markdown";
          language-servers = ["marksman" "lsp-ai"];
          formatter = {
            command = "prettier";
            args = ["--stdin-filepath" "file.md"];
          };
          auto-format = true;
        }
        {
          name = "ruby";
          language-servers = ["solargraph" "lsp-ai"];
          auto-format = true;
        }
        {
          name = "nix";
          language-servers = ["nil" "lsp-ai"];
          formatter = {
            command = "alejandra";
          };
          auto-format = true;
        }
        {
          name = "python";
          language-servers = ["pylsp" "lsp-ai"];
          formatter = {
            command = "sh";
            args = ["-c" "ruff check --select I --fix - | ruff format --line-length 88 -"];
          };
          auto-format = true;
        }
        {
          name = "rust";
          language-servers = ["rust-analyzer" "lsp-ai"];
          auto-format = true;
        }
        {
          name = "scss";
          language-servers = ["vscode-css-language-server" "lsp-ai"];
          formatter = {
            command = "prettier";
            args = ["--stdin-filepath" "file.scss"];
          };
          auto-format = true;
        }
        {
          name = "sql";
          language-servers = ["gpt"];
          formatter = {
            command = "pg_format";
            args = ["-iu1" "--no-space-function" "-"];
          };
          auto-format = true;
        }
        {
          name = "toml";
          language-servers = ["taplo"];
          formatter = {
            command = "taplo";
            args = ["fmt" "-o" "column_width=120" "-"];
          };
          auto-format = true;
        }
        {
          name = "tsx";
          language-servers = [
            {
              name = "typescript-language-server";
              except-features = ["format"];
            }
            "biome"
            "gpt"
          ];
          formatter = {
            command = "biome";
            args = ["format" "--indent-style" "space" "--stdin-file-path" "file.tsx"];
          };
          auto-format = true;
        }
        {
          name = "typescript";
          language-servers = [
            {
              name = "typescript-language-server";
              except-features = ["format"];
            }
            "biome"
            "gpt"
          ];
          formatter = {
            command = "biome";
            args = ["format" "--indent-style" "space" "--stdin-file-path" "file.ts"];
          };
          auto-format = true;
        }
        {
          name = "yaml";
          language-servers = ["yaml-language-server"];
          formatter = {
            command = "prettier";
            args = ["--stdin-filepath" "file.yaml"];
          };
          auto-format = true;
        }
      ];
    };
  };
}
