# Show "command ~/short/path" in tmux title
# When a command starts
function __tmux_title_update --on-event fish_preexec
    if test -n "$TMUX"
        set cmd (string split -f1 ' ' $argv)
        if test "$cmd" = ".."
            return
        end
        set safe_cmd (string replace -a '.' '_' $cmd)
        set safe_path (prompt_pwd | string replace -a '/' ' › ' | string replace -a '.' '_')
        tmux rename-window "$safe_cmd $safe_path"
    end
end
# When prompt returns (no command running), just show dir
function __tmux_title_reset --on-event fish_prompt
    if test -n "$TMUX"
        set safe_path (prompt_pwd | string replace -a '/' ' › ' | string replace -a '.' '_')
        tmux rename-window "$safe_path"
    end
end
