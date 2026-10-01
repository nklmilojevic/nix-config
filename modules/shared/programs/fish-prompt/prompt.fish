# Native fish prompt. Ported from the former starship config:
#   left:  user@ host directory branch(:remote) commit (state) +added/-deleted ❯
#   right: nix-shell kubernetes python duration time
#
# The git segment renders asynchronously: a background fish runs the git
# commands, writes "$PWD\n<segment>" to a per-shell file and sends the shell
# SIGUSR1, whose handler loads the file and repaints.

set -g __prompt_source (path resolve -- (status filename))

# Catppuccin Mocha
set -g __prompt_red f38ba8
set -g __prompt_green a6e3a1
set -g __prompt_yellow f9e2af
set -g __prompt_blue 89b4fa
set -g __prompt_mauve cba6f7
set -g __prompt_teal 94e2d5
set -g __prompt_lavender b4befe

set -g __prompt_dir_truncation 8
set -g __prompt_cmd_duration_min 2000

# The kubernetes segment only appears while the command line matches this.
set -g __prompt_kube_input_regex '^(k|kubectl|helm|k9s|kustomize|stern|flux|s|sofka)\b'

# Prints text in a color. Flags before the color are passed to set_color.
function __prompt_seg
    set -l text $argv[-1]
    set -e argv[-1]
    set_color $argv
    printf '%s' $text
    set_color normal
end

function __prompt_is_ssh
    set -q SSH_CONNECTION; or set -q SSH_CLIENT; or set -q SSH_TTY
end

function __prompt_user_host
    set -l ssh 0
    __prompt_is_ssh; and set ssh 1

    if fish_is_root_user
        __prompt_seg --bold $__prompt_red "$USER@"
    else if test $ssh = 1; or begin
            set -q LOGNAME; and test "$LOGNAME" != "$USER"
        end
        __prompt_seg --bold $__prompt_yellow "$USER@"
    end

    if test $ssh = 1
        __prompt_seg --bold --dim $__prompt_green \U000f08c0' '(prompt_hostname)
        printf ' '
    end
end

# $argv[1]: path of $PWD relative to the git repo root ("" at the root), or
# unset outside a repo.
function __prompt_directory
    set -l path (string replace -r -- '^'(string escape --style=regex -- $HOME)'(?=/|$)' '~' $PWD)
    set -l parts (string split -n / -- $path)
    set -l prefix ''
    string match -q '/*' -- $path; and set prefix /

    set -l total (count $parts)
    set -l offset 0
    if test $total -gt $__prompt_dir_truncation
        set offset (math $total - $__prompt_dir_truncation)
        set parts $parts[(math $offset + 1)..-1]
        set prefix ''
    end

    if test (count $parts) -eq 0
        __prompt_seg $__prompt_lavender /
    else if set -q argv[1]
        # Index of the repo root among the visible components.
        set -l root (math $total - (count (string split -n / -- $argv[1])) - $offset)
        if test $root -ge 1
            set -l before $prefix
            test $root -gt 1; and set before $prefix(string join / -- $parts[1..(math $root - 1)])/
            __prompt_seg $__prompt_lavender $before
            __prompt_seg --bold $__prompt_teal $parts[$root]
            if test $root -lt (count $parts)
                __prompt_seg $__prompt_lavender /(string join / -- $parts[(math $root + 1)..-1])
            end
        else
            __prompt_seg $__prompt_lavender (string join / -- $parts)
        end
    else
        __prompt_seg $__prompt_lavender $prefix(string join / -- $parts)
    end

    test -w .; or __prompt_seg $__prompt_red ' '\uf023
    printf ' '
end

function __prompt_git_state -a git_dir
    set -l state
    set -l current
    set -l total
    if test -d $git_dir/rebase-merge
        set state REBASING
        read current <$git_dir/rebase-merge/msgnum 2>/dev/null
        read total <$git_dir/rebase-merge/end 2>/dev/null
    else if test -d $git_dir/rebase-apply
        if test -f $git_dir/rebase-apply/rebasing
            set state REBASING
        else if test -f $git_dir/rebase-apply/applying
            set state AM
        else
            set state AM/REBASE
        end
        read current <$git_dir/rebase-apply/next 2>/dev/null
        read total <$git_dir/rebase-apply/last 2>/dev/null
    else if test -f $git_dir/MERGE_HEAD
        set state MERGING
    else if test -f $git_dir/REVERT_HEAD
        set state REVERTING
    else if test -f $git_dir/CHERRY_PICK_HEAD
        set state CHERRY-PICKING
    else if test -f $git_dir/BISECT_LOG
        set state BISECTING
    else
        return
    end

    test -n "$current" -a -n "$total"; and set state "$state $current/$total"
    printf '('
    __prompt_seg --bold $__prompt_yellow $state
    printf ') '
end

function __prompt_git_metrics
    set -l stat (command git diff --shortstat HEAD 2>/dev/null)
    test -n "$stat"; or return
    set -l added (string match -rg '(\d+) insertion' -- $stat; or echo 0)
    set -l deleted (string match -rg '(\d+) deletion' -- $stat; or echo 0)
    __prompt_seg $__prompt_green "+$added"
    printf /
    __prompt_seg $__prompt_red "-$deleted"
    printf ' '
end

function __prompt_git -a git_dir
    set -l branch (command git symbolic-ref --short -q HEAD)
    if test -n "$branch"
        set -l remote (command git for-each-ref --format='%(upstream:lstrip=3)' refs/heads/$branch)
        set -l label \ue0a0" $branch"
        test -n "$remote" -a "$remote" != "$branch"; and set label "$label:$remote"
        __prompt_seg $__prompt_red $label
        printf ' '
    else
        __prompt_seg $__prompt_red \ue0a0' HEAD'
        printf ' '
        set -l hash (command git rev-parse HEAD 2>/dev/null)
        if test -n "$hash"
            __prompt_seg --bold $__prompt_green \uf417' '(string sub -l 7 -- $hash)
            printf ' '
        end
    end

    __prompt_git_state $git_dir
    __prompt_git_metrics
end

function __prompt_character -a last_status
    set -l symbol ❯
    set -l color $__prompt_green
    set -l bold
    test "$last_status" -ne 0; and set symbol ✗; and set color $__prompt_red

    if contains -- "$fish_key_bindings" fish_vi_key_bindings fish_hybrid_key_bindings fish_helix_key_bindings
        set bold --bold
        switch $fish_bind_mode
            case default
                set symbol ❮
                set color $__prompt_green
            case visual
                set symbol ❮
                set color $__prompt_yellow
            case replace replace_one
                set symbol ❮
                set color $__prompt_mauve
            case '*'
                set bold
        end
    end

    __prompt_seg $bold $color $symbol
    printf ' '
end

# Runs in the background fish: renders the segment, publishes it atomically and
# notifies the shell.
function __prompt_git_worker -a file git_dir shell_pid
    printf '%s\n%s' $PWD (__prompt_git $git_dir | string collect) >$file.tmp
    command mv -f $file.tmp $file
    test -n "$shell_pid"; and command kill -USR1 $shell_pid
end

function __prompt_git_load
    read -z -l data <$__prompt_git_file 2>/dev/null; or return
    set -g __prompt_git_cache (string split -m1 \n -- $data)
end

# Starts a background render of the git segment when the cached one is stale,
# and prints the cached segment if it belongs to $PWD.
function __prompt_git_async -a git_dir
    if set -q __prompt_git_sync
        __prompt_git $git_dir
        return
    end

    if set -q __prompt_git_stale
        set -e __prompt_git_stale
        set -q __prompt_git_pid; and command kill $__prompt_git_pid 2>/dev/null
        command fish --no-config -c 'source $argv[1]; __prompt_git_worker $argv[2..]' \
            -- $__prompt_source $__prompt_git_file $git_dir $__prompt_git_notify </dev/null >/dev/null 2>&1 &
        set -g __prompt_git_pid $last_pid
        builtin disown $last_pid 2>/dev/null
    end

    test "$__prompt_git_cache[1]" = "$PWD"; and printf '%s' $__prompt_git_cache[2]
end

function fish_prompt
    set -l last_status $status

    if contains -- --final-rendering $argv
        __prompt_seg --bold green ❯
        printf ' '
        return
    end

    __prompt_user_host
    # $git[1]: git dir, $git[2]: $PWD relative to the repo root.
    set -l git (command git rev-parse --git-dir --show-prefix 2>/dev/null)
    if set -q git[1]
        __prompt_directory (string trim -r -c / -- "$git[2]")
        __prompt_git_async $git[1]
    else
        __prompt_directory
    end
    __prompt_character $last_status
end

function __prompt_nix_shell
    set -q IN_NIX_SHELL; or return
    set -l label \uf313' '
    set -q name; and set label "$label$name"
    __prompt_seg --dim $__prompt_green $label
    printf ' '
end

function __prompt_kube_context
    set -l files ~/.kube/config
    set -q KUBECONFIG; and set files (string split : -- $KUBECONFIG)

    set -l context
    for file in $files
        test -r $file; or continue
        set context (string match -rg '^current-context:\s*["\']?([^"\'\s]+)' <$file)
        test -n "$context"; and break
    end
    test -n "$context"; or return 1

    set -l namespace
    for file in $files
        test -r $file; or continue
        set namespace (awk -v ctx=$context -v quotes="[\"']" '
            function unquote(s) { gsub(/^[ \t]+|[ \t]+$/, "", s); gsub("^" quotes "|" quotes "$", "", s); return s }
            function flush() { if (found && name == ctx) { print ns; exit } name = ""; ns = "" }
            /^contexts:/ { in_ctx = 1; next }
            in_ctx && /^[^ \t-]/ { flush(); in_ctx = 0 }
            !in_ctx { next }
            /^[ \t]*- / { flush(); found = 1 }
            { line = $0; sub(/^[ \t-]*/, "", line) }
            line ~ /^name:/ { name = unquote(substr(line, 6)) }
            line ~ /^namespace:/ { ns = unquote(substr(line, 11)) }
            END { flush() }
        ' $file)
        test -n "$namespace"; and break
    end

    printf '%s\n' $context $namespace
end

function __prompt_kubernetes
    commandline --current-buffer 2>/dev/null | string trim -l | string match -qr -- $__prompt_kube_input_regex
    or return

    set -l kube (__prompt_kube_context)
    or return
    set -l label \U000f10fe" $kube[1]"
    test -n "$kube[2]"; and set label "$label ($kube[2])"
    __prompt_seg --dim $__prompt_blue $label
    printf ' '
end

function __prompt_python
    set -l markers (path filter -- *.py *.ipynb requirements.txt .python-version pyproject.toml Pipfile tox.ini setup.py __init__.py)
    set -q VIRTUAL_ENV; or set -q markers[1]; or return

    set -l python
    for bin in python python3 python2
        if command -q $bin
            set python $bin
            break
        end
    end

    set -l label \ue73c' '
    if test -n "$python"
        set -l pyver (command $python --version 2>&1 | string match -rg 'Python (\S+)')
        test -n "$pyver"; and set label "$label""v$pyver "
    end
    if set -q VIRTUAL_ENV
        set -l venv (path basename -- $VIRTUAL_ENV)
        set -q VIRTUAL_ENV_PROMPT; and test -n "$VIRTUAL_ENV_PROMPT"; and set venv (string trim -c '() ' -- $VIRTUAL_ENV_PROMPT)
        set label "$label$venv "
    end
    __prompt_seg --dim $__prompt_yellow $label
end

function __prompt_cmd_duration
    set -q CMD_DURATION; or return
    test $CMD_DURATION -ge $__prompt_cmd_duration_min; or return

    set -l secs (math --scale=0 $CMD_DURATION / 1000)
    set -l out ''
    set -l d (math --scale=0 $secs / 86400)
    set -l h (math --scale=0 $secs % 86400 / 3600)
    set -l m (math --scale=0 $secs % 3600 / 60)
    set -l s (math --scale=0 $secs % 60)
    test $d -gt 0; and set out $out$d"d"
    test $d -gt 0 -o $h -gt 0; and set out $out$h"h"
    test $d -gt 0 -o $h -gt 0 -o $m -gt 0; and set out $out$m"m"
    set out $out$s"s"

    __prompt_seg --dim $__prompt_yellow \U000f051b' '$out
    printf ' '
end

function fish_right_prompt
    contains -- --final-rendering $argv; and return

    __prompt_nix_shell
    __prompt_kubernetes
    __prompt_python
    __prompt_cmd_duration
    __prompt_seg --dim $__prompt_yellow \U000f0150' '(date +%T)
    printf ' '
end

# The character segment already shows the vi mode.
function fish_mode_prompt
end

status is-interactive; or return

set -g fish_transient_prompt 1

set -g __prompt_git_file (command mktemp -t fish-prompt-git.XXXXXX)
set -g __prompt_git_notify $fish_pid
set -g __prompt_git_stale 1

# Git state only needs re-reading after a command or a directory change, not on
# every repaint (typing, the async result itself).
function __prompt_git_mark_stale --on-event fish_postexec --on-variable PWD
    set -g __prompt_git_stale 1
end

function __prompt_git_ready --on-signal SIGUSR1
    __prompt_git_load
    commandline -f repaint
end

function __prompt_git_cleanup --on-event fish_exit
    command rm -f $__prompt_git_file $__prompt_git_file.tmp
end

# Repaint while typing so the kubernetes segment can react to the command,
# but only when the first word changes.
function __prompt_input_repaint
    set -l token (commandline --current-buffer | string trim -l | string split -m1 -f1 ' ')
    if test "$token" != "$__prompt_input_last_token"
        set -g __prompt_input_last_token "$token"
        commandline -f repaint
    end
end

function __prompt_reset_input --on-event fish_postexec
    set -g __prompt_input_last_token ""
end

bind space self-insert __prompt_input_repaint
bind -M insert space self-insert __prompt_input_repaint
bind backspace backward-delete-char __prompt_input_repaint
bind -M insert backspace backward-delete-char __prompt_input_repaint
