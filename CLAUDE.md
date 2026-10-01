# nix-config

## Shell prompt

The prompt is plain fish, not starship: `modules/shared/programs/fish-prompt/prompt.fish`, sourced at the end of `interactiveShellInit` by `modules/shared/programs/fish-prompt/default.nix`. Colors are hardcoded Catppuccin Mocha hex values at the top of the file.

The git segment is async: after each command or `cd`, a `fish --no-config` worker renders it into a per-shell temp file and sends the shell `SIGUSR1`, and the handler loads the file and repaints. Repaints from typing reuse the cached segment, which is only shown while it matches `$PWD`. Universal variables won't work for this: `--no-config` fish neither reads nor writes them.

The kubernetes segment only shows while the command line matches `__prompt_kube_input_regex` (e.g. `k `, `kubectl `, `helm `). Space and backspace are bound to repaint when the first word changes, so the segment appears as you type.

After changing the prompt, run the tests (they use a temp HOME and temp git repos, so they don't depend on local state):

```fish
fish modules/shared/programs/fish-prompt/test.fish
```

The same script is the `checks.fish-prompt` flake check.
