#!/usr/bin/env bash
set -euo pipefail

show_error() {
    printf '%s\nPress Enter to close.\n' "$1" >&2
    read -r </dev/tty || true
    exit 1
}

# Use the overlay's terminal to reach the Kitty instance that launched it.
unset KITTY_LISTEN_ON
remote=(kitten @)
tabs=$("${remote[@]}" ls | jq -r --arg window "$KITTY_WINDOW_ID" '
    .[] | select(any(.tabs[].windows[]; (.id | tostring) == $window))
    | .tabs | to_entries[]
    | [.value.id, "\(if .value.is_active then "*" else " " end) \(.key + 1)  \(.value.title | gsub("[[:cntrl:]]"; " "))"]
    | join("\t")
') || show_error 'Kitty could not list its tabs.'
[[ -n $tabs ]] || show_error 'Kitty could not find the window that opened this picker.'

if selection=$(fzf --no-sort --delimiter=$'\t' --with-nth=2 --nth=1 \
    --prompt='Kitty tab> ' --header='↑/↓ select · Enter switch · Esc cancel' <<< "$tabs"); then
    tab_id=${selection%%$'\t'*}
    "${remote[@]}" focus-tab --match "id:$tab_id" || show_error 'Kitty could not focus the selected tab.'
else
    status=$?
    if (( status != 1 && status != 130 )); then
        show_error "fzf exited with status $status."
    fi
fi
