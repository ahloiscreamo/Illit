set -gx FZF_DEFAULT_OPTS '
  --color=fg:#c8c8e5,fg+:#c8c8e5,bg:#232136,bg+:#393552
  --color=hl:#3e8fb0,hl+:#9ccfd8,info:#f6c177,marker:#f6c177
  --color=prompt:#eb6f92,spinner:#c4a7e7,pointer:#c4a7e7,header:#9ccfd8
  --color=border:#393552,label:#44415a,query:#6e6a86
  --border="rounded" --border-label="" --preview-window="noborder" --prompt="> "
  --marker=">" --pointer="◆" --separator="─" --scrollbar="│"
  --style full'
set -gx YT_X_FZF_OPTS $FZF_DEFAULT_OPTS'
  --color=bg+:#44415a
  --color=marker:#3e8fb0
  --color=header:#3e8fb0
  --color=border:#44415a
  --color=label:#ea9a97
  --color=query:#f6c177
  --preview-window="border-rounded"'
set -gx BAT_THEME "Rose-Pine-Moon"
set -gx NNN_BATTHEME "Rose-Pine-Moon"
