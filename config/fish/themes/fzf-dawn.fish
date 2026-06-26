set -gx FZF_DEFAULT_OPTS '
  --color=fg:#575279,fg+:#575279,bg:#faf4ed,bg+:#f2e9e1
  --color=hl:#286983,hl+:#56949f,info:#ea9d34,marker:#ea9d34
  --color=prompt:#b4637a,spinner:#907aa9,pointer:#907aa9,header:#56949f
  --color=border:#f2e9e1,label:#dfdad9,query:#9893a5
  --border="rounded" --border-label="" --preview-window="noborder" --prompt="> "
  --marker=">" --pointer="◆" --separator="─" --scrollbar="│"
  --style full'
set -gx YT_X_FZF_OPTS $FZF_DEFAULT_OPTS'
  --color=bg+:#dfdad9
  --color=marker:#286983
  --color=header:#286983
  --color=border:#dfdad9
  --color=label:#d7827e
  --color=query:#ea9d34
  --preview-window="border-rounded"'
set -gx BAT_THEME "Rose-Pine-Dawn"
set -gx NNN_BATTHEME "Rose-Pine-Dawn"
