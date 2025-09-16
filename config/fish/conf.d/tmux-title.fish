# Show "command ~/short/path" in tmux title

# When a command starts
function __tmux_title_update --on-event fish_preexec
    if test -n "$TMUX"
        set cmd (string split -f1 ' ' $argv)

        set path (string replace -r "^$HOME" "~" (pwd))
        set short_path (string replace -r '/([^/])[^/]+/' '/\1/' $path)

        tmux rename-window "$cmd $short_path"
    end
end

# When prompt returns (no command running), just show dir
function __tmux_title_reset --on-event fish_prompt
    if test -n "$TMUX"
        set path (string replace -r "^$HOME" "~" (pwd))
        set short_path (string replace -r '/([^/])[^/]+/' '/\1/' $path)

        tmux rename-window $short_path
    end
end
