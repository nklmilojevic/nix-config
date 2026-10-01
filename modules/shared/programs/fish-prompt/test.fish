# Tests for prompt.fish. Run: fish modules/shared/programs/fish-prompt/test.fish
set -l here (path dirname (status filename))
set -l tmp (mktemp -d)
set -gx HOME $tmp/home
mkdir -p $HOME
set -e SSH_CONNECTION SSH_CLIENT SSH_TTY VIRTUAL_ENV IN_NIX_SHELL KUBECONFIG XDG_CONFIG_HOME
set -gx LOGNAME $USER
set -gx GIT_CONFIG_GLOBAL /dev/null
set -gx GIT_AUTHOR_NAME t GIT_AUTHOR_EMAIL t@t GIT_COMMITTER_NAME t GIT_COMMITTER_EMAIL t@t

source $here/prompt.fish
# Render git inline; the async path is tested separately below.
set -g __prompt_git_sync 1

set -g failures 0
function check -a name expected actual
    if test "$expected" = "$actual"
        echo "ok   $name"
    else
        echo "FAIL $name"
        echo "     expected: [$expected]"
        echo "     actual:   [$actual]"
        set failures (math $failures + 1)
    end
end

function plain
    string replace -ra '\e\[[0-9;]*m|\e\(B' '' -- (string collect -- $argv)
end

function left
    true
    plain (fish_prompt)
end

# Command line as seen by the kubernetes segment.
function commandline
    printf '%s\n' $__test_input
end

# directory
cd $HOME
check 'home' '~ ❯ ' (left)
mkdir -p $HOME/a/b
cd $HOME/a/b
check 'under home' '~/a/b ❯ ' (left)
mkdir -p $tmp/1/2/3/4/5/6/7/8/9
cd $tmp/1/2/3/4/5/6/7/8/9
check 'truncated to 8' '2/3/4/5/6/7/8/9 ❯ ' (left)
cd /
check 'root (read-only)' '/ '\uf023' ❯ ' (left)

# character
cd $HOME
false
check 'error character' '~ ✗ ' (plain (fish_prompt))
check 'transient' '❯ ' (plain (fish_prompt --final-rendering))

# git
mkdir -p $HOME/repo/sub
cd $HOME/repo
command git init -q -b main
printf 'a\nb\n' >f
command git add f
command git commit -qm init
check 'repo root' '~/repo '\ue0a0' main ❯ ' (left)
cd sub
check 'repo subdir' '~/repo/sub '\ue0a0' main ❯ ' (left)
cd ..
printf 'c\n' >>f
check 'metrics unstaged' '~/repo '\ue0a0' main +1/-0 ❯ ' (left)
command git add f
check 'metrics staged' '~/repo '\ue0a0' main +1/-0 ❯ ' (left)
command git commit -qm two
touch .git/MERGE_HEAD
check 'merging' '~/repo '\ue0a0' main (MERGING) ❯ ' (left)
rm .git/MERGE_HEAD
command git checkout -q --detach HEAD
set -l hash (command git rev-parse --short=7 HEAD)
check 'detached' "~/repo "\ue0a0" HEAD "\uf417" $hash ❯ " (left)
command git checkout -q main
command git clone -q $HOME/repo $HOME/clone
cd $HOME/clone
check 'same-name upstream hidden' '~/clone '\ue0a0' main ❯ ' (left)
command git checkout -q -b feature --track origin/main
check 'different upstream shown' '~/clone '\ue0a0' feature:main ❯ ' (left)

# async: a background worker renders git into the file; the test polls the
# file instead of waiting for SIGUSR1 (no notify pid is set).
cd $HOME/repo
set -e __prompt_git_sync
set -g __prompt_git_file $tmp/git-cache
set -g __prompt_git_notify
set -g __prompt_git_stale 1
check 'async prompt before result' '~/repo ❯ ' (left)
check 'async stale flag consumed' 1 (set -q __prompt_git_stale; or echo 1)
for i in (seq 50)
    test -s $__prompt_git_file; and break
    sleep 0.1
end
__prompt_git_load
check 'async published pwd' $PWD "$__prompt_git_cache[1]"
check 'async published segment' \ue0a0' main ' (plain $__prompt_git_cache[2])
check 'async cached prompt' '~/repo '\ue0a0' main ❯ ' (left)
check 'async repaint starts no job' 1 (set -q __prompt_git_stale; or echo 1)
set -g __prompt_git_cache /elsewhere ' other '
check 'async cache for other dir hidden' '~/repo ❯ ' (left)

# SIGUSR1 end to end: the worker signals this process.
function __test_on_usr1 --on-signal SIGUSR1
    set -g __test_got_usr1 1
    __prompt_git_load
end
rm -f $__prompt_git_file
set -g __prompt_git_notify $fish_pid
set -g __prompt_git_stale 1
left >/dev/null
for i in (seq 50)
    set -q __test_got_usr1; and break
    sleep 0.1
end
check 'async signal received' 1 "$__test_got_usr1"
check 'async signal loads cache' '~/repo '\ue0a0' main ❯ ' (left)
functions -e __test_on_usr1
set -e __prompt_git_cache __prompt_git_file __prompt_git_notify
set -g __prompt_git_sync 1

# The repo root is still highlighted when only part of the path is visible.
mkdir -p $tmp/1/2/3/4/5/6/7/r/x/y
cd $tmp/1/2/3/4/5/6/7/r
command git init -q -b main
cd x/y
check 'truncated repo' '3/4/5/6/7/r/x/y '\ue0a0' main ❯ ' (left)

# right prompt
cd $HOME
set -g CMD_DURATION 0
set -l now (date +%T)
check 'right minimal' \U000f0150" $now " (plain (fish_right_prompt))
set CMD_DURATION 3723000
check 'duration' \U000f051b" 1h2m3s "\U000f0150" $now " (plain (fish_right_prompt))
set CMD_DURATION 1999
check 'duration below min' \U000f0150" $now " (plain (fish_right_prompt))

set -gx IN_NIX_SHELL impure
set -gx name dev
check 'nix shell' \uf313" dev "\U000f0150" $now " (plain (fish_right_prompt))
set -e IN_NIX_SHELL name

mkdir -p $HOME/.kube
printf '%s\n' \
    'apiVersion: v1' \
    'contexts:' \
    '- context:' \
    '    cluster: a' \
    '    user: a' \
    '  name: other' \
    '- name: "prod"' \
    '  context:' \
    '    cluster: b' \
    '    namespace: payments' \
    'current-context: prod' >$HOME/.kube/config
set -g __test_input 'k get pods'
check 'kube on k' \U000f10fe" prod (payments) "\U000f0150" $now " (plain (fish_right_prompt))
set __test_input 'kit status'
check 'kube hidden for other commands' \U000f0150" $now " (plain (fish_right_prompt))
set __test_input ''
check 'kube hidden on empty input' \U000f0150" $now " (plain (fish_right_prompt))
printf '%s\n' 'contexts:' '- context:' '    cluster: a' '  name: dev' 'current-context: dev' >$tmp/kc
set -gx KUBECONFIG $tmp/missing:$tmp/kc
set __test_input 'helm upgrade'
check 'kube without namespace' \U000f10fe" dev "\U000f0150" $now " (plain (fish_right_prompt))
set -e KUBECONFIG __test_input

mkdir -p $HOME/py
cd $HOME/py
touch pyproject.toml
set -l pyver (python3 --version 2>&1 | string match -rg 'Python (\S+)')
check 'python' \ue73c" v$pyver "\U000f0150" $now " (plain (fish_right_prompt))

cd /
rm -rf $tmp
test $failures -eq 0
