#!/usr/bin/env bash

# fshow - git commit browser (enter for show, ctrl-d for diff, ` toggles sort)
# git rev-parse HEAD > /dev/null 2>&1 || exit

def_pager="less -R"
pager=""

if command -v delta &>/dev/null; then
  # if set pager is delta
  pager="delta --paging=always"
  preview_pager='| delta'
else
  pager="$def_pager"
  preview_pager=''
fi

preview="
  grep -o \"[a-f0-9]\{7,\}\" <<< {} |
    xargs git show --color=always $preview_pager |
      bat -p --color=always
"

# Find clipboard utility
copy='true'
# NOTE: Will probably will never run on windows but
# better safe than sorry
if [ "$OS" = 'Windows_NT' ]; then
  # Gitbash
  copy="cat '{+f}' | awk '{ print \$1 }' | clip.exe"
elif [ "$OSTYPE" = 'darwin' ] || command -v 'pbcopy' &>/dev/null; then
  copy="cat {+f} | awk '{ print \$1 }' | pbcopy"
# Assume linux if above didn't match
elif [ -n "$WAYLAND_DISPLAY" ] && command -v 'wl-copy' &>/dev/null; then
  copy="cat {+f} | awk '{ print \$1 }' | wl-copy --foreground --type text/plain"
elif [ -n "$DISPLAY" ] && command -v 'xsel' &>/dev/null; then
  copy="cat {+f} | awk '{ print \$1 }' | xsel -i -b"
elif [ -n "$DISPLAY" ] && command -v 'xclip' &>/dev/null; then
  copy="cat {+f} | awk '{ print \$1 }' | xclip -i -selection clipboard"
fi

# Local variables
out shas sha q k

# Setup history
fzf_history="${FZF_HIST_DIR:-$HOME/.cache/fzf_history}"
mkdir -p "$fzf_history"

# Default fzf flags
fzf-down () {
  fzf \
    --height '100%' \
    --min-height 20 \
    --input-border \
    --cycle \
    --layout=reverse \
    --multi \
    --bind 'alt-f:first' \
    --bind 'alt-l:last' \
    --bind 'alt-c:clear-query' \
    --bind 'ctrl-a:select-all' \
    --bind 'ctrl-d:deselect-all' \
    --bind 'ctrl-/:change-preview-window(down|hidden|)' \
    --bind 'ctrl-^:toggle-preview' \
    --bind "ctrl-y:execute-silent:$copy" \
    --bind 'alt-up:preview-page-up' \
    --bind 'alt-down:preview-page-down' \
    --bind 'ctrl-s:toggle-sort' \
    --header 'ctrl-d: Diff' \
    --prompt 'Commits> ' \
    --preview "$preview" \
    --ansi --no-sort --reverse \
    --print-query --expect=ctrl-d \
    "--history=$fzf_history/fzf-git_show" \
    --border "$@"
}

# main loop
while out=$(
  git log --graph --color=always \
    --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
    fzf-down --query="$q"); do
        q=$(head -1 <<< "$out")
        k=$(head -2 <<< "$out" | tail -1)
        # shas=($(sed '1,2d;s/^[^a-z0-9]*//;/^$/d' <<< "$out" | awk '{print $1}'))

        shas=()
        while IFS='' read -r new_sha; do
          shas+=("$new_sha")
        done < <(sed '1,2d;s/^[^a-z0-9]*//;/^$/d' <<< "$out" | awk '{print $1}')

  # shellcheck disable=SC2128
  [ -z "$shas" ] && continue
  if [ "$k" = ctrl-d ]; then
    bash -c "git diff --color=always ${shas[*]} | $pager"
  else
    for sha in "${shas[@]}"; do
      bash -c "git show --color=always $sha | $pager"
    done
  fi
done

