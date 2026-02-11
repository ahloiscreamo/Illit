#!/usr/bin/env bash

# Need Bash version 4.2 or higher to have support for 'declare'
bash_version_min="4.2"
if [ -z "$BASH_VERSION" ] || [[ "${BASH_VERSION%%[^0-9.]*}" < "$bash_version_min" ]]; then
    echo "Error: This script requires Bash version $bash_version_min or higher."
    exit 1
fi

# Preserve bash features in subshells (eg. fzf)
SHELL="$(command -v bash)"

# Image support
IMAGE_SUPPORT="ueberzugpp"

#┏┳┓┏━┓┏━╸╻┏━╸   ╺┳╸┏━┓┏━┓┏━╸
#┃┃┃┣━┫┃╺┓┃┃  ╺━╸ ┃ ┣━┫┣━┛┣╸
#╹ ╹╹ ╹┗━┛╹┗━╸    ╹ ╹ ╹╹  ┗━╸
#A script written by Christos Angelopoulos in March 2023 under GNU GENERAL PUBLIC LICENSE
#
function load_colors(){
 if [[ $COLORED_MESSAGES == "yes" ]];
 then
  Yellow="\e[33m"
  Green="\e[32m"
  Red="\e[31m"
  Magenta="\e[35m"
  Cyan="\e[36m"
  Gray="\e[90m"
  Black="\e[30m" 
  bold="\x1b[1m"
  normal="\e[m"
 else
  Yellow="";
  Green="";
  Red="" ;
  Magenta="" ;
  Cyan="" ;
  Gray="" ;
  bold="" ;
  normal=""
 fi;
}
function notify() {
    [ "${NOTIFICATION_ENABLED:-yes}" == "no" ] && return 0;

    command -v notify-send >/dev/null && {
        notify-send -t $1 -i "$2" "magic-tape" "$3"
        return 0
    }
    [ -n "$KITTY_PID" ] && [ $kitty_version -gt 35 ] && {
        case "$(uname -s)" in
            # FIXME: For some reason `-p` does not work on macOS
            Darwin) kitty @ kitten notify -s silent -e $(($1 / 1000))s "magic-tape" "$3" ;;
            *) kitty @ kitten notify -s silent -e $(($1 / 1000))s -p "$2" "magic-tape" "$3" ;;
        esac
        return 0
    }
    command -v osascript >/dev/null && {
        osascript -e "display notification \"$1\" with title \"magic-tape\""
        return 0
    }
    return 1
}
function copy_to_clipboard() {
    command -v xclip >/dev/null && { echo "$1" | xclip -sel clip; return 0; }
    command -v pbcopy >/dev/null && { echo "$1" | pbcopy; return 0; }
    return 1
}
function setup_cache_directories() {
    mkdir -p "$HOME/.cache/magic-tape/history"
    mkdir -p "$HOME/.cache/magic-tape/json"
    mkdir -p "$HOME/.cache/magic-tape/search/channels"
    mkdir -p "$HOME/.cache/magic-tape/search/video"
    mkdir -p "$HOME/.cache/magic-tape/jpg"
    mkdir -p "$HOME/.cache/magic-tape/subscriptions/jpg"
    mkdir -p "$HOME/.cache/magic-tape/comments"
    touch "$HOME/.cache/magic-tape/subscriptions/subscriptions.txt"
    touch "$HOME/.cache/magic-tape/history/watch_history.txt"
    touch "$HOME/.cache/magic-tape/history/search_history.txt"
    touch "$HOME/.cache/magic-tape/history/liked.txt"
}

function load_config() {

 setup_cache_directories

 if [[ -e "$HOME/.config/magic-tape/magic-tape.conf" ]]
 then
  source "$HOME/.config/magic-tape/magic-tape.conf"
  load_colors

  if [[ -z "$USE_NERD_FONTS" ]]; then USE_NERD_FONTS="yes"; fi
  if [ "$USE_NERD_FONTS" = "yes" ]; then
    # Nerd Font Icons
    ICON_FEED="󰗃"; ICON_ALGORITHM="󰌶"; ICON_TRENDING=""; ICON_SEARCH=""; ICON_REPEAT=""; ICON_CHANNEL="󰑈"; ICON_LIKED=""; ICON_HISTORY=""; ICON_SEARCH_HISTORY="󱘢"; ICON_MISC=""; ICON_QUIT="󰈆"; ICON_PREFERENCES=""; ICON_UPDATE=""; ICON_LIKE=""; ICON_UNLIKE=""; ICON_IMPORT=""; ICON_SUBSCRIBE="󰗃"; ICON_UNSUBSCRIBE="󰗼"; ICON_CLEAR=""; ICON_BACK="󰌍"; ICON_PLAY="󰎁"; ICON_PLAY_AUDIO="󰎄"; ICON_DOWNLOAD=""; ICON_BROWSER="爵"; ICON_LINK=""; ICON_MAIN_MENU="󰋞"; ICON_NO_FILTER="󰗢"; ICON_DUR_S="󰔟"; ICON_DUR_M="󰔣"; ICON_DUR_L="󰔞"; ICON_PLAYLIST="󰥴"; ICON_SELECT_VIDEO="";
  else
    # Emoji Fallbacks
    ICON_FEED="📡"; ICON_ALGORITHM="🔥"; ICON_TRENDING="📈"; ICON_SEARCH="🔎"; ICON_REPEAT="🔁"; ICON_CHANNEL="📺"; ICON_LIKED="👍"; ICON_HISTORY="🕒"; ICON_SEARCH_HISTORY="📋"; ICON_MISC="⚙️"; ICON_QUIT="❌"; ICON_PREFERENCES="⚙️"; ICON_UPDATE="⬇️"; ICON_LIKE="👍"; ICON_UNLIKE="👎"; ICON_IMPORT="📥"; ICON_SUBSCRIBE="➕"; ICON_UNSUBSCRIBE="➖"; ICON_CLEAR="🗑️"; ICON_BACK="⬅️"; ICON_PLAY="▶️"; ICON_PLAY_AUDIO="🎵"; ICON_DOWNLOAD="⬇️"; ICON_BROWSER="🌐"; ICON_LINK="🔗"; ICON_MAIN_MENU="🏠"; ICON_NO_FILTER="🚫"; ICON_DUR_S="🕒"; ICON_DUR_M="🕔"; ICON_DUR_L="🕤"; ICON_PLAYLIST="🎶"; ICON_SELECT_VIDEO="🎬";
  fi

  if [[ $LIST_LENGTH -gt 99 ]];then LIST_LENGTH=99;fi;
  ROFI_FORMAT='rofi -dmenu -l 20 -width 40 -i -p ';
  FZF_FORMAT="fzf --ansi --cycle --print-query --preview-window=0 --color='gutter:-1' --reverse --tiebreak=begin --border=rounded +m --info=hidden --header-first --prompt=";
  DMENU_FORMAT="dmenu -fn 13 -nb '#2E3546' -sb '#434C5E' -l 20sc -i -p "
  if [[ $PREF_SELECTOR == "rofi" ]]
  then PREF_SELECTOR=$ROFI_FORMAT
  elif [[ $PREF_SELECTOR == "fzf" ]]
  then PREF_SELECTOR=$FZF_FORMAT
  elif [[ $PREF_SELECTOR == "dmenu" ]]
  then PREF_SELECTOR=$DMENU_FORMAT;fi;
 else
  notify 9000 "$SHARE_DIR"/magic-tape.png "Exiting magic-tape"
  echo -e "\e[31mConfigurations not loaded correctly.Please make sure that:\n- You have installed the script correctly using the install.sh.\n- All the variables have assigned acceptable values.$normal"
  exit
 fi
}

function select_duration_filter ()
{
 local duration_prompt
 duration_prompt="$(echo -e "${Cyan}${ICON_NO_FILTER}${normal} Any Duration\n${Cyan}${ICON_DUR_S}${normal} Duration up to 4 mins\n${Cyan}${ICON_DUR_M}${normal} Duration between 4 and 20 mins\n${Cyan}${ICON_DUR_L}${normal} Duration longer than 20 mins\n${Red}${ICON_MAIN_MENU}${normal} Back to Main Menu"|eval "$PREF_SELECTOR""\"Step 1: Select Duration \"")";

    if [[ -z "$duration_prompt" ]] || [[ "$duration_prompt" == *"Back to Main Menu"* ]]; then
        echo "back"
        return
    fi

    case "$duration_prompt" in
        *"Any Duration"*) echo "any" ;;
        *"up to 4 mins"*) echo "short" ;;
        *"between 4 and 20 mins"*) echo "medium" ;;
        *"longer than 20 mins"*) echo "long" ;;
        *) echo "any" ;;
    esac
}

function select_sort_order ()
{
    local sort_prompt
    sort_prompt="$(echo -e "${Green}${ICON_SEARCH}${normal} Sort by Relevance\n${Green}${ICON_HISTORY}${normal} Sort by Upload Date\n${Green}${ICON_TRENDING}${normal} Sort by View Count\n${Green}${ICON_LIKED}${normal} Sort by Rating\n${Red}${ICON_MAIN_MENU}${normal} Back to Main Menu"|eval "$PREF_SELECTOR""\"Step 2: Select Sort Order \"")"

    if [[ -z "$sort_prompt" ]] || [[ "$sort_prompt" == *"Back to Main Menu"* ]]; then
        echo "back"
        return
    fi

    case "$sort_prompt" in
        *"Sort by Relevance"*) echo "relevance" ;;
        *"Sort by Upload Date"*) echo "date" ;;
        *"Sort by View Count"*) echo "views" ;;
        *"Sort by Rating"*) echo "rating" ;;
        *) echo "relevance" ;;
    esac
}

function new_subscription ()
{
  C=${C// /+};C=${C//\'/%27};
  repeat_channel_search=1;
  ITEM=1;
  FEED="/results?search_query="$C"&sp=EgIQAg%253D%253D";
  while [ $repeat_channel_search -eq 1 ];
  do fzf_header="$(echo ${FEED^^}|sed 's/&SP=.*$//;s/^.*SEARCH_QUERY=/search: /;s/[\/\?=&+]/ /g') channels: $ITEM to $(($ITEM + $(($LIST_LENGTH - 1))))";
  ITEM0=$ITEM;
  echo -e "${Gray}Downloading $FEED...${normal}";
  echo -e "$db\n$ITEM\n$ITEM0\n$FEED\n$fzf_header">$HOME/.cache/magic-tape/history/last_action.txt;
  yt-dlp --cookies-from-browser $PREF_BROWSER --flat-playlist --playlist-start $ITEM --playlist-end $(($ITEM + $(($LIST_LENGTH - 1)))) -j "https://www.youtube.com$FEED">$HOME/.cache/magic-tape/json/channel_search.json
  echo -e "${Gray}Completed $FEED${normal}";

  jq '.channel_id' $HOME/.cache/magic-tape/json/channel_search.json|sed 's/"//g'>$HOME/.cache/magic-tape/search/channels/ids.txt;
  jq '.title' $HOME/.cache/magic-tape/json/channel_search.json|sed 's/"//g'>$HOME/.cache/magic-tape/search/channels/titles.txt;
  jq '.description' $HOME/.cache/magic-tape/json/channel_search.json|sed 's/"//g'>$HOME/.cache/magic-tape/search/channels/descriptions.txt;
  jq '.channel_follower_count' $HOME/.cache/magic-tape/json/channel_search.json|sed 's/"//g'>$HOME/.cache/magic-tape/search/channels/subscribers.txt;
  jq '.thumbnails[1].url' $HOME/.cache/magic-tape/json/channel_search.json|sed 's/"//g'>$HOME/.cache/magic-tape/search/channels/img_urls.txt;

  cat /dev/null>$HOME/.cache/magic-tape/search/channels/thumbnails.txt;
  i=1;
   while [ $i -le $(cat $HOME/.cache/magic-tape/search/channels/ids.txt|wc -l) ];
   do  echo "url = \"https:""$(sed -n "${i}p" $HOME/.cache/magic-tape/search/channels/img_urls.txt)\"">>$HOME/.cache/magic-tape/search/channels/thumbnails.txt;
   echo "output = \"$HOME/.cache/magic-tape/jpg/$(sed -n "${i}p" $HOME/.cache/magic-tape/search/channels/ids.txt).jpg\"">>$HOME/.cache/magic-tape/search/channels/thumbnails.txt;
   ((i++));
  done;
  echo -e "${Gray}Downloading channel thumbnails...${normal}";
  curl -s -K $HOME/.cache/magic-tape/search/channels/thumbnails.txt  2>/dev/null&echo -e "${Gray}Background downloading channel thumbnails...${normal}";
  if [ $ITEM -gt 1 ];then echo -e "${Cyan}Previous Page${normal}">>$HOME/.cache/magic-tape/search/channels/titles.txt;fi;
  if [ $(cat $HOME/.cache/magic-tape/search/channels/ids.txt|wc -l) -ge $LIST_LENGTH ];then echo -e "${Cyan}Next Page${normal}">>$HOME/.cache/magic-tape/search/channels/titles.txt;fi;
  echo -e "${Red}Abort Selection${normal}">>$HOME/.cache/magic-tape/search/channels/titles.txt;

  CHAN=" $(cat -n $HOME/.cache/magic-tape/search/channels/titles.txt|sed 's/^. *//g' |fzf\
  --info=hidden \
  --layout=reverse \
  --ansi \
  --height=100% \
  --prompt="Select Channel: " \
  --header="$fzf_header" \
  --preview-window=left,50%\
  --bind=right:accept \
  --expect=shift-left,shift-right\
  --tabstop=1 \
  --no-margin  \
  +m \
  -i \
  --exact --cycle \
  --preview='hght=$(($FZF_PREVIEW_COLUMNS /3));\
  if [[ "$IMAGE_SUPPORT" == "kitty" ]];then clear_image;fi;\
  i=$(echo {}|sed "s/\\t.*$//g");\
  echo $i>$HOME/.cache/magic-tape/search/channels/index.txt;\
  if [[ "$IMAGE_SUPPORT" == "ueberz"* ]];then ll=0; while [ $ll -le $hght ];do echo "";((ll++));done;fi;\
  if [[ "$IMAGE_SUPPORT" == "kitty" ]]&&[[ $kitty_version -le 21 ]];then ll=0; while [ $ll -le $hght ];do echo "";((ll++));done;fi;\
  TITLE_WITH_COLOR="$(sed -n "${i}p" $HOME/.cache/magic-tape/search/channels/titles.txt)";\
  TITLE=$(echo "$TITLE_WITH_COLOR" | sed "s/\x1b\[[0-9;]*m//g");\
  if [[ "$TITLE" == "Previous Page" ]];then draw_preview 1 1 $FZF_PREVIEW_COLUMNS $hght  "$SHARE_DIR"/previous.png;\
  elif [[ "$TITLE" == "Next Page" ]];then draw_preview 1 1 $FZF_PREVIEW_COLUMNS $hght  "$SHARE_DIR"/next.png;\
  elif [[ "$TITLE" == "Abort Selection" ]];then draw_preview 1 1 $FZF_PREVIEW_COLUMNS $hght  "$SHARE_DIR"/abort.png;\
  else draw_preview 1 1 $FZF_PREVIEW_COLUMNS $hght  "$HOME""/.cache/magic-tape/jpg/""$(sed -n "${i}p" $HOME/.cache/magic-tape/search/channels/ids.txt)"".jpg";fi;\
  ll=1; echo -ne "\e[30m"; while [ $ll -le $FZF_PREVIEW_COLUMNS ];do echo -n -e "─";((ll++));done;echo -e "\e[m";\
  echo -e "\n\e[33m$TITLE_WITH_COLOR\e[m"|fold -w $FZF_PREVIEW_COLUMNS -s;\
   if [[ $TITLE != "Abort Selection" ]]&&[[ $TITLE != "Next Page" ]]&&[[ $TITLE != "Previous Page" ]];\
   then SUBS="$(sed -n "${i}p" $HOME/.cache/magic-tape/search/channels/subscribers.txt)";\
  echo -e "\n\e[32mSubscribers: \e[36m$SUBS\e[m";\
  ll=1; echo -ne "\e[30m"; while [ $ll -le $FZF_PREVIEW_COLUMNS ];do echo -n -e "─";((ll++));done;echo -e "\e[m";\
  DESCRIPTION="$(sed -n "${i}p" $HOME/.cache/magic-tape/search/channels/descriptions.txt)";\
  echo -e "\n\x1b[38;5;250m$DESCRIPTION\e[m"|fold -w $FZF_PREVIEW_COLUMNS -s; \
  fi;')";
  clear_image;
  i=$(cat $HOME/.cache/magic-tape/search/channels/index.txt);
  NAME=$(sed -n "${i}p" $HOME/.cache/magic-tape/search/channels/titles.txt);
  NAME=$(echo "$NAME" | sed 's/\x1b\[[0-9;]*m//g');
  if [[ $CHAN == " " ]]; then echo "ABORT!"; NAME="Abort Selection";clear;fi;
  echo -e "${Gray}Channel Selected: $NAME${normal}";
  if [ $ITEM  -ge $LIST_LENGTH ]&&[[ $CHAN == *"shift-left"* ]]; then NAME="Previous Page";fi;
  if [ $ITEM  -le $LIST_LENGTH ]&&[[ $CHAN == *"shift-left"* ]]; then NAME="Abort Selection";fi;
  #if [[ -n $PREVIOUS_PAGE ]]&&[[ $CHAN == *"shift-left"* ]]; then NAME="Previous Page";fi;
  if [[ $CHAN == *"shift-right"* ]]; then NAME="Next Page";fi;
  if [[ $NAME == "Next Page" ]];then ITEM=$(($ITEM + $LIST_LENGTH));fi;
  if [[ $NAME == "Previous Page" ]];then ITEM=$(($ITEM - $LIST_LENGTH));fi;
  if [[ $NAME == "Abort Selection" ]];then repeat_channel_search=0;fi;
  if [[ "$NAME" != "Abort Selection" ]]&&[[ "$NAME" != "Next Page" ]]&&[[ "$NAME" != "Previous Page" ]];
  then SUB_URL="$(sed -n "${i}p" $HOME/.cache/magic-tape/search/channels/ids.txt)";
   repeat_channel_search=0;
   echo -e " ${Green}You will subscribe to this channel:\n${Yellow}$NAME${normal}\nProceed?(Y/y)"; read -N 1 pr;echo -e "\n";
   if [[ $pr == Y ]] || [[ $pr == y ]];
   then  notification_img="$HOME/.cache/magic-tape/jpg/""$(sed -n "${i}p" $HOME/.cache/magic-tape/search/channels/ids.txt)"".jpg";
    if [ -n "$(grep -i $SUB_URL $HOME/.cache/magic-tape/subscriptions/subscriptions.txt)" ];
    then notify $NOTIFICATION_DURATION "$notification_img" "You are already subscribed to $NAME ";
    else echo "$SUB_URL"" ""$NAME">>$HOME/.cache/magic-tape/subscriptions/subscriptions.txt;
     notify $NOTIFICATION_DURATION "$notification_img" "You have subscribed to $NAME ";
     mv "$notification_img" $HOME/.cache/magic-tape/subscriptions/jpg/"$SUB_URL.jpg";
     echo -e "${Red}NOTICE: ${Yellow}In order for this action to take effect in YouTube, you need to subscribe manually from a browser as well.\nDo you want to do it now? (Y/y)${normal}"|fold -w 75 -s;
     read -N 1 pr2;echo -e "\n";
     if [[ $pr2 == Y ]] || [[ $pr2 == y ]];then $LINK_BROWSER "https://www.youtube.com/channel/"$SUB_URL&echo "Opened $LINK_BROWSER";fi;
    fi;
   fi;
  fi;
  done;
}

function channel_feed ()
{
  big_loop=1;
   ITEM=1;
   ITEM0=$ITEM;
   if [[ "$P" == "@"* ]];then FEED="/""$P""/videos";else FEED="/channel/""$P""/videos";fi
   while [ $big_loop -eq 1 ];
   do fzf_header="channel: "$channel_name"  videos $ITEM to $(($ITEM + $(($LIST_LENGTH - 1))))";
   get_feed_json;
   get_data;
   small_loop=1;
   while [ $small_loop -eq 1 ];
   do select_video ;
    if [[ "$TITLE" == "Next Page" ]]||[[ "$TITLE" == "Previous Page" ]];then small_loop=0;fi;
    if [[ "$TITLE" == "Abort Selection" ]];then small_loop=0;big_loop=0;fi;
    if [[ "$TITLE" != "Abort Selection" ]]&&[[ "$TITLE" != "Next Page" ]]&&[[ "$TITLE" != "Previous Page" ]];then select_action;fi;
   done;
  done;
}

function like_video ()
{
 LIKE="$(tac $HOME/.cache/magic-tape/history/watch_history.txt|sed 's/^.*https:\/\/www\.youtube\.com/https:\/\/www\.youtube\.com/g'|cut -d' ' -f2-|eval "$PREF_SELECTOR""\"❤️ Select video to like \"")";
 if [[ -z "$LIKE" ]];
  then empty_query;
 else echo -e "❤️ Add\n${Yellow}"$LIKE"${normal}\nto Liked Videos?(Y/y))";
  read -N 1 alv;echo -e "\n";
  if [[ $alv == Y ]] || [[ $alv == y ]];
  then if [[ -z "$(grep "$LIKE" $HOME/.cache/magic-tape/history/liked.txt)" ]];
   then echo "$(grep "$LIKE" $HOME/.cache/magic-tape/history/watch_history.txt|head -1)" >> $HOME/.cache/magic-tape/history/liked.txt;
    notify $NOTIFICATION_DURATION "$SHARE_DIR"/magic-tape.png "❤️ Video added to Liked Videos.";
   else notify $NOTIFICATION_DURATION "$SHARE_DIR"/magic-tape.png "❤️ Video already added to Liked Videos.";
   fi;
  fi;alv="";
 fi;
}

function import_subscriptions()
{
 echo -e "${Red}Your magic-tape subscriptions will be synced with your YouTube ones.Before initializing this function, make sure you are logged in in your YT account, and you have set up your preferred browser.\nProceed? (Y/y)${normal}"|fold -w 75 -s;
 read -N 1 impsub ;echo -e "\n";
 if [[ $impsub == "Y" ]] || [[ $impsub == "y" ]];
 then  echo -e "${Gray}Downloading subscriptions data...${normal}";
  new_subs=subscriptions_$(date +%F).json;
  yt-dlp --cookies-from-browser $PREF_BROWSER --flat-playlist -j "https://www.youtube.com/feed/channels">$HOME/.cache/magic-tape/json/$new_subs;
  echo -e "${Green}Download Complete.${normal}";
  jq '.id' $HOME/.cache/magic-tape/json/$new_subs|sed 's/"//g'>$HOME/.cache/magic-tape/search/channels/channel_ids.txt;
  jq '.title' $HOME/.cache/magic-tape/json/$new_subs|sed 's/"//g'>$HOME/.cache/magic-tape/search/channels/channel_names.txt;
  jq '.thumbnails[1].url' $HOME/.cache/magic-tape/json/$new_subs|sed 's/"//g'>$HOME/.cache/magic-tape/search/channels/image_urls.txt;
  cat /dev/null>$HOME/.cache/magic-tape/search/channels/thumbnails.txt;
  cp $HOME/.cache/magic-tape/subscriptions/subscriptions.txt $HOME/.cache/magic-tape/subscriptions/subscriptions-$(date +%F).bak.txt;
  cat /dev/null>$HOME/.cache/magic-tape/subscriptions/subscriptions.txt;
  i=1;
  while [ $i -le $(cat $HOME/.cache/magic-tape/search/channels/channel_ids.txt|wc -l) ];
  do echo "$(sed -n "${i}p" $HOME/.cache/magic-tape/search/channels/channel_ids.txt) $(sed -n "${i}p" $HOME/.cache/magic-tape/search/channels/channel_names.txt)">>$HOME/.cache/magic-tape/subscriptions/subscriptions.txt;
   img_path="$HOME/.cache/magic-tape/subscriptions/jpg/$(sed -n "${i}p" $HOME/.cache/magic-tape/search/channels/channel_ids.txt).jpg";
   if [ ! -f  "$img_path" ];
   then echo "url = \"https:$(sed -n "${i}p" $HOME/.cache/magic-tape/search/channels/image_urls.txt)\"">>$HOME/.cache/magic-tape/search/channels/thumbnails.txt;
    echo "output = \"$img_path\"">>$HOME/.cache/magic-tape/search/channels/thumbnails.txt;
   fi;
   ((i++));
  done;
  echo -e "${Gray}Downloading thumbnails...${normal}";
  curl -s -K $HOME/.cache/magic-tape/search/channels/thumbnails.txt 2>/dev/null;
  echo -e "${Gray}Thumbnail download complete.${normal}";
  echo -e "${Green}Your magic-tape subscriptions are now updated.\nA backup copy of your old subscriptions is kept in\n${Yellow}$HOME/.cache/magic-tape/subscriptions/subscriptions-$(date +%F).bak.txt${normal}\n${Green}Press any key to continue: ${normal}";
  read -N 1  imp2;clear;mv $HOME/.cache/magic-tape/json/$new_subs $HOME/.local/share/Trash/files/;
 fi;
}

function draw_line(){
 ll=1; echo -ne $1; while [ $ll -le $cols ];do echo -n -e "─";((ll++));done;echo  -e "$normal"
}

function print_mpv_video_shortcuts()
{
 if [[ "$SHOW_MPV_KEYBINDINGS" == 'yes' ]]
 then
  draw_line "${Gray}"
  echo -e "\n${Yellow}${bold}SHORTCUTS${normal}\n"
  echo -e "  ${Gray}╭─────┬──────────╮ ╭─────┬─────────────╮";
  echo -e "  ${Gray}│${Magenta}${bold}  ␣  ${Gray}│${normal}${Cyan}    Pause ${Gray}│ │${Magenta}${bold}  f  ${Gray}│${normal}${Cyan}  Fullscreen ${Gray}│";
  echo -e "  ${Gray}├─────┼──────────┤ ├─────┼─────────────┤";
  echo -e "  ${Gray}│${Magenta}${bold} 9 0 ${Gray}│${normal}${Cyan}   Volume ${Gray}│ │${Magenta}${bold} [ ] ${Gray}│${normal}${Cyan}  Play Speed ${Gray}│";
  echo -e "  ${Gray}├─────┼──────────┤ ├─────┼─────────────┤";
  echo -e "  ${Gray}│${Magenta}${bold}  m  ${Gray}│${normal}${Cyan}     Mute ${Gray}│ │${Magenta}${bold} 1 2 ${Gray}│${normal}${Cyan}    Contrast ${Gray}│";
  echo -e "  ${Gray}├─────┼──────────┤ ├─────┼─────────────┤";
  echo -e "  ${Gray}│${Magenta}${bold} ← → ${Gray}│${normal}${Cyan} Skip 10\"${Gray} │ │${Magenta}${bold} 3 4 ${Gray}│${normal}${Cyan}  Brightness${Gray} │";
  echo -e "  ${Gray}├─────┼──────────┤ ├─────┼─────────────┤";
  echo -e "  ${Gray}│${Magenta}${bold} ↑ ↓ ${Gray}│${normal}${Cyan} Skip 60\"${Gray} │ │${Magenta}${bold} 7 8 ${Gray}│${normal}${Cyan}  Saturation${Gray} │";
  echo -e "  ${Gray}├─────┼──────────┤ ├─────┼─────────────┤";
  echo -e "  ${Gray}│${Magenta}${bold} , . ${Gray}│${normal}${Cyan}    Frame ${Gray}│ │${Magenta}${bold}  q  ${Gray}│${normal}${Red}        Quit ${Gray}│";
  echo -e "  ${Gray}╰─────┴──────────╯ ╰─────┴─────────────╯";
 fi
}

function misc_menu ()
{
 while [ "$db2" != "q" ] ;
 do fzf_output="$(echo -e "${Yellow}${bold}┏┳┓╻┏━┓┏━╸   ┏┳┓┏━╸┏┓╻╻ ╻${normal}\n${Yellow}${bold}┃┃┃┃┗━┓┃     ┃┃┃┣╸ ┃┗┫┃ ┃${normal}\n${Yellow}${bold}╹ ╹╹┗━┛┗━╸   ╹ ╹┗━╸╹ ╹┗━┛${normal}\n${Cyan}${ICON_PREFERENCES}${normal}  ${Yellow}${bold}P${normal} ${Cyan}SET UP PREFERENCES\n${Cyan}${ICON_UPDATE}${normal}  ${Yellow}${bold}Y${normal} ${Cyan}UPDATE yt-dlp\n${Red}${ICON_LIKE}${normal}  ${Yellow}${bold}l${normal} ${Red}LIKE a video\n${Red}${ICON_UNLIKE}${normal}  ${Yellow}${bold}L${normal} ${Red}UNLIKE a video\n${Green}${ICON_IMPORT}${normal}  ${Yellow}${bold}I${normal} ${Green}Import subscriptions from YouTube\n${Green}${ICON_SUBSCRIBE}${normal}  ${Yellow}${bold}n${normal} ${Green}Subscribe to a new channel\n${Green}${ICON_UNSUBSCRIBE}${normal}  ${Yellow}${bold}u${normal} ${Green}Unsubscribe from a channel\n${Magenta}${ICON_CLEAR}${normal}  ${Yellow}${bold}H${normal} ${Magenta}Clear watch history\n${Magenta}${ICON_CLEAR}${normal}  ${Yellow}${bold}S${normal} ${Magenta}Clear search history\n${Magenta}${ICON_CLEAR}${normal}  ${Yellow}${bold}T${normal} ${Magenta}Clear thumbnail cache\n${Cyan}${ICON_BACK}${normal}  ${Yellow}${bold}q${normal} ${Cyan}Back to Main Menu"|fzf \
--preview-window=0 \
--disabled \
--reverse \
--ansi \
--tiebreak=begin \
 --border=rounded \
 +i \
 +m \
 --color='gutter:-1' \
 --nth=2.. \
 --info=hidden \
 --header-lines=3 \
 --prompt="Enter:" \
 --header-first --cycle  \
 --expect=A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,1,2,3,4,5,6,7,8,9,0,enter )";
   key_press=$(echo "$fzf_output" | head -n 1)
   if [[ "$key_press" == "enter" ]]; then
     db2=$(echo "$fzf_output" | sed -n '2p' | awk '{print $2}')
   else
     db2=$key_press
   fi
  case $db2 in
   "P") eval $PREF_EDITOR $HOME/.config/magic-tape/magic-tape.conf;load_config;if [[ $IMAGE_SUPPORT == "ueberzugpp" ]];then trap exit_upp  HUP INT QUIT TERM EXIT ERR ABRT ;clean_upp; fi;clear_image;
   ;;
   "Y")clear;echo -e "${Red}${bold}NOTICE: ${Yellow}${bold}Updating yt-dlp with this option works only when you have installed it using pip.\nProceed? (Y/y)${normal}";
       read -N 1 pipytdlp;echo -e "\n";if [[ $pipytdlp == Y ]] || [[ $pipytdlp == y ]]; then python3 -m pip install -U "yt-dlp[default]";pipytdlp="";fi; echo -e "${Gray}Press any key to return${normal}";read -N 1 xxx;
   ;;
   "I") clear;
      import_subscriptions;
   ;;
   "n") clear;
      echo -e "🔎 Enter keyword/keyphrase for a channel to search for: \n\n";
      read  C;
      if [[ -z "$C" ]];
      then empty_query;
      else new_subscription;
      fi;
     ;;
     "u") clear;U="$(cat $HOME/.cache/magic-tape/subscriptions/subscriptions.txt|cut -d' ' -f2-|eval "$PREF_SELECTOR""\"❌ Unsubscribe from channel \"")";
        if [[ -z "$U" ]]; then empty_query;
        else echo "$U";
        echo -e "${Red}${bold}Unsubscribe from this channel:\n"${Yellow}$U"${normal}\nProceed? (Y/y))";
         read -N 1 uc;echo -e "\n";
         if [[ $uc == Y ]] || [[ $uc == y ]];
         then notification_img=""$SHARE_DIR"/magic-tape.png";
          sed -i "/$U/d" $HOME/.cache/magic-tape/subscriptions/subscriptions.txt;
          echo -e "${Green}${bold}Unsubscribed from $U ]${normal}";
          notify $NOTIFICATION_DURATION "$notification_img" "You have unsubscribed from $U";
          echo -e "${Red}${bold}NOTICE: ${Yellow}${bold}In order for this action to take effect in YouTube, you need to unsubscribe manually from a browser as well.\nDo you want to do it now? (Y/y)${normal}"|fold -w 75 -s;
          read -N 1 uc2;echo -e "\n";
          if [[ $uc2 == Y ]] || [[ $uc2 == y ]];then $LINK_BROWSER "https://www.youtube.com/feed/channels"&echo "Opened $PREF_BROWSER";fi;
         fi;
        fi;uc="";uc2="";
   ;;
   "H") clear;echo -e "${Green}Clear ${Yellow}${bold}watch history?${normal}(Y/y))";
      read -N 1 cwh;echo -e "\n";
      if [[ $cwh == Y ]] || [[ $cwh == y ]];
      then cat /dev/null > $HOME/.cache/magic-tape/history/watch_history.txt;
       notify $NOTIFICATION_DURATION "$SHARE_DIR"/magic-tape.png "Watch history cleared.";
      fi;cwh="";
   ;;
   "S") clear;echo -e "${Green}Clear ${Yellow}${bold}search history?${normal}(Y/y))";
      read -N 1 csh;echo -e "\n";
      if [[ $csh == Y ]] || [[ $csh == y ]];
      then cat /dev/null > $HOME/.cache/magic-tape/history/search_history.txt;
      notify $NOTIFICATION_DURATION "$SHARE_DIR"/magic-tape.png "Search history cleared.";
      fi;csh="";
   ;;
   "T") clear;echo -e "${Green}Clear ${Yellow}${bold}thumbnail cache?${normal}(Y/y))";
       read -N 1 ctc;echo -e "\n";
       if [[ $ctc == Y ]] || [[ $ctc == y ]];
       then mv $HOME/.cache/magic-tape/jpg/* $HOME/.local/share/Trash/files/
       notify $NOTIFICATION_DURATION "$SHARE_DIR"/magic-tape.png "Thumbnail cache cleared.";
       fi;ctc="";
   ;;
   "l") clear;like_video;
   ;;
   "L") clear;UNLIKE="$(tac $HOME/.cache/magic-tape/history/liked.txt|sed 's/^.*https:\/\/www\.youtube\.com/https:\/\/www\.youtube\.com/g'|cut -d' ' -f2-|eval "$PREF_SELECTOR""\"❌ Select video to unlike \"")";
      if [[ -z "$UNLIKE" ]]; then empty_query;
      else echo -e "${Red}${bold}Unlike video\n${Yellow}"$UNLIKE"?${normal}\n(Y/y))";
       read -N 1 uv;echo -e "\n";
       if [[ $uv == Y ]] || [[ $uv == y ]];
       then notification_img=""$SHARE_DIR"/magic-tape.png";
        #UNLIKE="$(echo "$UNLIKE"|awk '{print $1}'|sed 's/^.*\///')";
        sed -i "/$UNLIKE/d" $HOME/.cache/magic-tape/history/liked.txt;
        notify $NOTIFICATION_DURATION "$notification_img" "❌ You have unliked $UNLIKE";
       fi;
      fi;uv="";
   ;;
   "q") clear;
   ;;
*)clear;echo -e "\n${Red}${ICON_QUIT}${normal} ${Yellow}${bold}$db${normal} is an invalid key, please try again.\n";sleep $TERMINAL_MESSAGE_DURATION;
   ;;
  esac
 done
 db2="";
}
################# UBERZUGPP ###################
function exit_upp () {
 db2="q"
 PLAY=" "
 db="q"
 CHAN=" "
 ueberzugpp cmd -s "$SOCKET" -a exit >/dev/null 2>&1
 #killall ueberzugpp>/dev/null 2>&1
# killall -9 -g magic-tape.sh>/dev/null 2>&1
 kill -9 $magic_tape_pid>/dev/null 2>&1
}

clean_upp() {
 ueberzugpp cmd -s "$SOCKET" -a exit>/dev/null 2>&1&&ueberzugpp layer --no-stdin --silent --use-escape-codes --pid-file /tmp/.magic_tape_upp
 UB_PID=$(cat /tmp/.magic_tape_upp)
 SOCKET=/tmp/ueberzugpp-"$UB_PID".socket
}

function draw_upp () {
    # args: $1=x $2=y $3=max-width $4=max-height $5=path
    # Fine-tuned for fzf --border=double alignment
    local offset_x=2    # shifts image slightly right (fixes left overlap)
    local offset_y=1    # optional, keeps vertical consistent
    local pad_right=2   # expands width to fill right gap

    local x=$(( ${1:-0} + offset_x ))
    local y=$(( ${2:-0} + offset_y ))
    local max_w=$(( ${3:-40} + pad_right ))
    local max_h=${4:-20}

    local img="$5"

    ueberzugpp cmd -s "$SOCKET" -i fzfpreview -a add \
        -x "$x" -y "$y" \
        --max-width "$max_w" \
        --max-height "$max_h" \
        -f "$img"
}

################# UBERZUG ######################
declare -r -x UEBERZUG_FIFO_MAGIC_TAPE="$(mktemp --dry-run )"
function start_ueberzug {
    mkfifo "${UEBERZUG_FIFO_MAGIC_TAPE}"
    <"${UEBERZUG_FIFO_MAGIC_TAPE}" \
        ueberzug layer --parser bash --silent &
    # prevent EOF
    3>"${UEBERZUG_FIFO_MAGIC_TAPE}" \
        exec
}

function finalise {
    3>&- \
        exec
    &>/dev/null \
        rm "${UEBERZUG_FIFO_MAGIC_TAPE}"
    &>/dev/null \
        kill $(jobs -p)
}
######################################################
function clear_image (){
 if [[ "$IMAGE_SUPPORT" == "kitty" ]];then kitty icat --transfer-mode file --clear 2>/dev/null;fi;
 if [[ "$IMAGE_SUPPORT" == "ueberzug" ]];then finalise;start_ueberzug;fi;
 if [[ "$IMAGE_SUPPORT" == "ueberzugpp" ]];then clean_upp;fi;
}

function draw_uber {
#sample draw_uber 35 35 90 3 /path/image.jpg
    >"${UEBERZUG_FIFO_MAGIC_TAPE}" declare -A -p cmd=( \
        [action]=add [identifier]="preview" \
        [x]="$1" [y]="$2" \
        [width]="$3" [height]="$4" \
        [scaler]=fit_contain [scaling_position_x]=10 [scaling_position_y]=10 \
        [path]="$5")
}

function draw_preview {
 #sample draw_preview 90 3 35 35 /path/image.jpg
 if [[ "$IMAGE_SUPPORT" == "kitty" ]]
 then
  if [[ $kitty_version -le 22 ]]
  then
   kitty icat  --transfer-mode file --place $3x$4@$1x$2 --scale-up   "$5"
  else
#   kitty icat --transfer-mode=file --use-window-size $(($3-5)),$(($3/2)),480,360 --unicode-placeholder --align=left --scale-up "$5" 2>/dev/null
   kitty icat --clear --transfer-mode=memory --unicode-placeholder --stdin=no --align=left --place="$3x$4@0x0" "$5" | sed '$d' | sed $'$s/$/\e[m/'
  fi
 fi
# if [[ "$IMAGE_SUPPORT" == "kitty" ]];then kitty icat  --transfer-mode file --place $3x$4@$1x$2 --scale-up --unicode-placeholder  "$5";fi;
if [[ "$IMAGE_SUPPORT" == "ueberzugpp" ]]; then
    thumb_ratio=$(identify "$5" | awk '{print $3}')
    thumb_w="${thumb_ratio%x*}"
    thumb_h="${thumb_ratio##*x}"

    # scale proportionally within given geometry ($3 x $4)
    if [[ $thumb_w -ge $thumb_h ]]; then
        max_x="$3"
        max_h=$(($thumb_h * $max_x / $thumb_w))
    else
        max_h="$4"
        max_x=$(($thumb_w * $max_h / $thumb_h))
    fi

    draw_upp "$1" "$2" "$max_x" "$max_h" "$5"
fi;
 if [[ "$IMAGE_SUPPORT" == "ueberzug" ]];then draw_uber $1 $2 $3 $4 $5;fi;
 if [[ "$IMAGE_SUPPORT" == "chafa" ]];then chafa --format=symbols -c full -s  $3 $5;fi;
}

function get_feed_json ()
{
 echo -e "${Gray}Downloading $FEED...${normal}";
 echo -e "$db\n$ITEM\n$ITEM0\n$FEED\n$fzf_header">$HOME/.cache/magic-tape/history/last_action.txt;
 #if statement added to fix json problem. If the problem re-appears, uncomment the if statement, and comment  following line
 #if [ $db == "f" ]||[ $db == "t" ]||[ $db == "y" ];then LIST_LENGTH=$(($LIST_LENGTH * 2 ));else LIST_LENGTH="$(grep 'LIST_LENGTH:' $HOME/.config/magic-tape/magic-tape.conf|sed 's/^#.*//g;s/^.*: //')";fi;
###LIST_LENGTH="$(grep 'LIST_LENGTH:' $HOME/.config/magic-tape/magic-tape.conf|sed 's/^#.*//g;s/^.*: //')";

 local local_ytdlp_filter_args=""
 if [[ -n "$YTDLP_MATCH_FILTER_ARG" ]]; then
     local_ytdlp_filter_args="--match-filter \"$YTDLP_MATCH_FILTER_ARG\""
 fi

 local ytdlp_url
 if [[ "$FEED" == "TRENDING_PAGE" ]]; then
    ytdlp_url="youtube:trending"
 else
    ytdlp_url="https://www.youtube.com$FEED"
 fi

 local ytdlp_cmd="yt-dlp --cookies-from-browser \"$PREF_BROWSER\" --flat-playlist --extractor-args youtubetab:approximate_date --playlist-start \"$ITEM0\" --playlist-end \"$(($ITEM0 + $(($LIST_LENGTH - 1))))\" -j \"$ytdlp_url\" $local_ytdlp_filter_args"
 eval "$ytdlp_cmd" > "$HOME/.cache/magic-tape/json/video_search.json"

 echo -e "${Gray}Completed $FEED.${normal}";
 #correct back LIST_LENGTH value(fix json problem);
 #if [ $db == "f" ]||[ $db == "t" ];then LIST_LENGTH=$(($LIST_LENGTH / 2 ));fi;
}

function get_playlist_videos_json ()
{
 echo -e "${Gray}Downloading $FEED...${normal}";
 echo -e "$db\n$ITEM\n$ITEM0\n$FEED\n$fzf_header">$HOME/.cache/magic-tape/history/last_action.txt;

 local ytdlp_url="https://www.youtube.com$FEED"

 # Build arguments array for safety instead of using eval
 local -a ytdlp_args
 ytdlp_args=(
    --ignore-config
    --flat-playlist
    --cookies-from-browser "$PREF_BROWSER"
    --extractor-args "youtubetab:approximate_date"
    --playlist-start "$ITEM0"
    --playlist-end "$(($ITEM0 + $(($LIST_LENGTH - 1))))"
    -j "$ytdlp_url"
 )
 if [[ -n "$YTDLP_MATCH_FILTER_ARG" ]]; then
     ytdlp_args+=(--match-filter "$YTDLP_MATCH_FILTER_ARG")
 fi

 yt-dlp "${ytdlp_args[@]}" > "$HOME/.cache/magic-tape/json/video_search.json"

 echo -e "${Gray}Completed $FEED.${normal}";
}

function get_data ()
{
 #fix json problem first seen Apr 12 2023, where each item in the json file takes two lines, not one. While and until this stands, this one-liner corrects the issue. Also LIST_LENGTH=$(($LIST_LENGTH * 2 )) in get_feed_json function, exactly because of this issue
 #if [ $db == "f" ]||[ $db == "t" ];then even=2;while [ $even -le $(cat $HOME/.cache/magic-tape/json/video_search.json|wc -l) ];do echo "$(head -$even $HOME/.cache/magic-tape/json/video_search.json|tail +$even)">>$HOME/.cache/magic-tape/json/video_search_temp.json;even=$(($even +2));done;mv $HOME/.cache/magic-tape/json/video_search_temp.json $HOME/.cache/magic-tape/json/video_search.json;fi;

 jq '.id' $HOME/.cache/magic-tape/json/video_search.json|sed 's/\\"/⁆/g;s/"//g;s/⁆/"/g'>$HOME/.cache/magic-tape/search/video/ids.txt;
 jq '.title' $HOME/.cache/magic-tape/json/video_search.json|sed 's/\\"/⁆/g;s/"//g;s/⁆/"/g'>$HOME/.cache/magic-tape/search/video/titles.txt;
 jq '.duration_string' $HOME/.cache/magic-tape/json/video_search.json|sed 's/\\"/⁆/g;s/"//g;s/⁆/"/g'>$HOME/.cache/magic-tape/search/video/lengths.txt;
 jq '.url // .webpage_url' $HOME/.cache/magic-tape/json/video_search.json|sed 's/\\"/⁆/g;s/"//g;s/⁆/"/g'>$HOME/.cache/magic-tape/search/video/urls.txt;
 jq '.timestamp' $HOME/.cache/magic-tape/json/video_search.json>$HOME/.cache/magic-tape/search/video/timestamps.txt;
 jq '.description' $HOME/.cache/magic-tape/json/video_search.json>$HOME/.cache/magic-tape/search/video/descriptions.txt;
 jq '.view_count' $HOME/.cache/magic-tape/json/video_search.json|sed 's/\\"/⁆/g;s/"//g;s/⁆/"/g'>$HOME/.cache/magic-tape/search/video/views.txt;
 jq '.channel_id // .uploader_id' $HOME/.cache/magic-tape/json/video_search.json|sed 's/\\"/⁆/g;s/"//g;s/⁆/"/g'>$HOME/.cache/magic-tape/search/video/channel_ids.txt;
 jq '.channel // .uploader' $HOME/.cache/magic-tape/json/video_search.json|sed 's/\\"/⁆/g;s/"//g;s/⁆/"/g'>$HOME/.cache/magic-tape/search/video/channel_names.txt;
 jq '((.thumbnails | map(select(.height == 480)) | .[0].url) // (.thumbnails | map(select(.height == 320)) | .[0].url)) // .thumbnails[-1].url // .thumbnail // .thumbnails[0].url' $HOME/.cache/magic-tape/json/video_search.json|sed 's/\\"/⁆/g;s/"//g;s/⁆/"/g'>$HOME/.cache/magic-tape/search/video/image_urls.txt;
 jq '.live_status' $HOME/.cache/magic-tape/json/video_search.json>$HOME/.cache/magic-tape/search/video/live_status.txt;
 if [[ $db == "c" ]];
 then jq '.playlist_uploader' $HOME/.cache/magic-tape/json/video_search.json|sed 's/"//g'>$HOME/.cache/magic-tape/search/video/channel_names.txt;
  jq '.playlist_uploader_id' $HOME/.cache/magic-tape/json/video_search.json|sed 's/"//g'>$HOME/.cache/magic-tape/search/video/channel_ids.txt;
  fi;
 cat /dev/null>$HOME/.cache/magic-tape/search/video/thumbnails.txt;
 cat /dev/null>$HOME/.cache/magic-tape/search/video/shared.txt;
 i=1;
 while [ $i -le $(cat $HOME/.cache/magic-tape/search/video/titles.txt|wc -l) ];
 do img_path="$HOME/.cache/magic-tape/jpg/img-$(sed -n "${i}p" $HOME/.cache/magic-tape/search/video/ids.txt).jpg";
  if [ ! -f  "$img_path" ]; then
    img_url=$(sed -n "${i}p" "$HOME/.cache/magic-tape/search/video/image_urls.txt")
    if [[ "$img_url" == "//"* ]]; then
      img_url="https:$img_url"
    fi
    if [[ -n "$img_url" ]] && [[ "$img_url" != "null" ]]; then
        echo "url = \"$img_url\"" >> "$HOME/.cache/magic-tape/search/video/thumbnails.txt";
        echo "output = \"$img_path\"" >> "$HOME/.cache/magic-tape/search/video/thumbnails.txt";
    fi
  fi;
  ### parse approx date
  timestamp="$(sed -n "${i}p" $HOME/.cache/magic-tape/search/video/timestamps.txt)";
  if [[ "$timestamp" != "null" ]];then
    now=$(date +%s)
    diff=$((now - $timestamp))
    days=$((diff / 86400))
    hours=$(((diff % 86400) / 3600))
    minutes=$(((diff % 3600) / 60))
    d=$(date -d @$timestamp '+%Y-%m-%d')
    if [ $diff -lt 60 ]; then
      approximate_date="$minutes minute(s) ago"
    elif [ $diff -lt 3600 ]; then
      [ $minutes -eq 1 ] && approximate_date="$d (1 minute ago)" || approximate_date="$d ($minutes minutes ago)"
    elif [ $days -eq 0 ]; then
      [ $hours -eq 1 ] && approximate_date="$d (1 hour ago)" || approximate_date="$d ($hours hours ago)"
    elif [ $days -eq 1 ]; then approximate_date="$d (yesterday)"
    elif [ $days -lt 7 ]; then approximate_date="$d ($days days ago)"
    elif [ $days -lt 30 ]; then
      weeks=$((days / 7))
      [ $weeks -eq 1 ] && approximate_date="$d (1 week ago)" || approximate_date="$d ($weeks weeks ago)"
    elif [ $days -lt 365 ]; then
      months=$((days / 30))
      [ $months -eq 1 ] && approximate_date="1 month ago" || approximate_date="$months months ago"
    else
      years=$((days / 365))
      [ $years -eq 1 ] && approximate_date="1 year ago" || approximate_date="$years years ago"
    fi
  else approximate_date="$(sed -n "${i}p" $HOME/.cache/magic-tape/search/video/live_status.txt|sed 's/_/ /g;s/"//g')";
  fi;
  echo $approximate_date>>$HOME/.cache/magic-tape/search/video/shared.txt;
  ((i++));
 done;
 echo -e "${Gray}Downloading thumbnails...${normal}";
 curl -s -K $HOME/.cache/magic-tape/search/video/thumbnails.txt 2>/dev/null& echo -e "${Gray}Background thumbnails download.${normal}";
 if [ $ITEM -gt 1 ];then echo "Previous Page">>$HOME/.cache/magic-tape/search/video/titles.txt;fi;
 if [ $(cat $HOME/.cache/magic-tape/search/video/ids.txt|wc -l) -ge $LIST_LENGTH ];then echo "Next Page">>$HOME/.cache/magic-tape/search/video/titles.txt;fi;
 echo "Abort Selection">>$HOME/.cache/magic-tape/search/video/titles.txt;
}

function select_video ()
{
 PLAY="";
 PLAY=" $(cat -n $HOME/.cache/magic-tape/search/video/titles.txt|sed 's/^. *//g' |fzf\
 --info=hidden \
 --layout=reverse \
 --ansi \
 --height=100% \
 --prompt="$ICON_SELECT_VIDEO Select video: " \
 --header="$fzf_header" \
 --preview-window=left,40% \
 --tabstop=1 \
 --no-margin  \
 --bind=right:accept \
 --expect=shift-left,shift-right \
 +m \
 -i \
 --exact --cycle \
 --preview='
 hght=$(($FZF_PREVIEW_COLUMNS /3));\
 if [[ "$IMAGE_SUPPORT" == "kitty" ]];then clear_image;fi;\
 i=$(echo {}|cut -b -2);echo $i>$HOME/.cache/magic-tape/search/video/index.txt;\
 if [[ "$IMAGE_SUPPORT" == "ueberz"* ]];then ll=0; while [ $ll -le $hght ];do echo "";((ll++));done;fi;\
 if [[ "$IMAGE_SUPPORT" == "kitty" ]]&&[[ $kitty_version -le 21 ]];then ll=0; while [ $ll -le $hght ];do echo "";((ll++));done;fi;\
 TITLE_WITH_COLOR="$(sed -n "${i}p" $HOME/.cache/magic-tape/search/video/titles.txt)";\
 TITLE=$(echo "$TITLE_WITH_COLOR" | sed "s/\x1b\[[0-9;]*m//g");\
 channel_name="$(sed -n "${i}p" $HOME/.cache/magic-tape/search/video/channel_names.txt)";\
 channel_jpg="$(sed -n "${i}p" $HOME/.cache/magic-tape/search/video/channel_ids.txt)"".jpg";\
 if [[ "$TITLE" == "Previous Page" ]];then draw_preview 1 1 $FZF_PREVIEW_COLUMNS $hght "$SHARE_DIR"/previous.png;\
 elif [[ "$TITLE" == "Next Page" ]];then draw_preview 1 1 $FZF_PREVIEW_COLUMNS $hght "$SHARE_DIR"/next.png;\
 elif [[ "$TITLE" == "Abort Selection" ]];then draw_preview 1 1 $FZF_PREVIEW_COLUMNS $hght "$SHARE_DIR"/abort.png;\
 else \
  img_path="$HOME/.cache/magic-tape/jpg/img-""$(sed -n "${i}p" $HOME/.cache/magic-tape/search/video/ids.txt)"".jpg";\
  if [ -f "$img_path" ]; then \
    draw_preview 1 1 $FZF_PREVIEW_COLUMNS $hght "$img_path"; \
  else \
    echo -e "\n\n      loading thumbnail..."; \
  fi; \
 fi;\
 ll=1; echo -ne "\e[30m"; while [ $ll -le $FZF_PREVIEW_COLUMNS ];do echo -n -e "─";((ll++));done;echo -e "\e[m";\
 echo -e "\n\e[33m$TITLE_WITH_COLOR\e[m" |fold -w $FZF_PREVIEW_COLUMNS -s ; \
 ll=1; echo -ne "\e[30m"; while [ $ll -le $FZF_PREVIEW_COLUMNS ];do echo -n -e "─";((ll++));done;echo -e "\e[m";\
 if [[ $TITLE != "Abort Selection" ]]&&[[ $TITLE != "Previous Page" ]]&&[[ $TITLE != "Next Page" ]];\
 then  LENGTH="$(sed -n "${i}p" $HOME/.cache/magic-tape/search/video/lengths.txt)";\
  SHARED="$(sed -n "${i}p" $HOME/.cache/magic-tape/search/video/shared.txt)";\
  if [[ $SHARED == "is upcoming" ]];then echo -e "\n\e[32mShared: \e[31m$SHARED\e[m";else echo -e "\n\e[32mShared: \e[36m$SHARED\e[m";fi;\
  if [[ $LENGTH != "null" ]];then echo -e "\e[32mLength: \e[36m$LENGTH\e[m";fi;\
  VIEWS="$(sed -n "${i}p" $HOME/.cache/magic-tape/search/video/views.txt)";\
  if [[ $VIEWS != "null" ]];then printf "\e[32mViews :\e[36m %'\''d\n" $VIEWS;fi;\
  if [[ $db != "c" ]] && [[ "$channel_name" != "null" ]] && [[ -n "$channel_name" ]];\
  then ll=1; echo -ne "\e[30m"; while [ $ll -le $FZF_PREVIEW_COLUMNS ];do echo -n -e "─";((ll++));done;echo -e "\e[m";\
   echo -e "\n\e[32mChannel: \e[33m$channel_name\e[m" |fold -w $FZF_PREVIEW_COLUMNS -s;\
  fi;\
  DESCRIPTION="$(sed -n "${i}p" $HOME/.cache/magic-tape/search/video/descriptions.txt)";\
  if [[ $DESCRIPTION != "null" ]];
  then ll=1; echo -ne "\e[30m"; while [ $ll -le $FZF_PREVIEW_COLUMNS ];do echo -n -e "─";((ll++));done;echo -e "\e[m";\
   echo -e "\n\x1b[38;5;250m$DESCRIPTION\e[m"|fold -w $FZF_PREVIEW_COLUMNS -s; \
  fi;
 fi;')";
 clear_image;
 i=$(cat $HOME/.cache/magic-tape/search/video/index.txt);
  notification_img="$HOME/.cache/magic-tape/jpg/img-"$(sed -n "${i}p" $HOME/.cache/magic-tape/search/video/ids.txt)".jpg";
 play_now="$(sed -n "${i}p" $HOME/.cache/magic-tape/search/video/urls.txt)";
 TITLE=$(sed -n "${i}p" $HOME/.cache/magic-tape/search/video/titles.txt);
 TITLE=$(echo "$TITLE" | sed 's/\x1b\[[0-9;]*m//g');
 channel_name="$(sed -n "${i}p" $HOME/.cache/magic-tape/search/video/channel_names.txt)";
 channel_id="$(sed -n "${i}p" $HOME/.cache/magic-tape/search/video/channel_ids.txt)";
 if [ $ITEM  -ge $LIST_LENGTH ]&&[[ $PLAY == *"shift-left"* ]]; then TITLE="Previous Page";fi;
 if [ $ITEM  -le $LIST_LENGTH ]&&[[ $PLAY == *"shift-left"* ]]; then TITLE="Abort Selection";fi;
 if [[ $PLAY == *"shift-right"* ]]; then TITLE="Next Page";fi;
 if [[ $TITLE == "Next Page" ]];
 then ITEM=$(($ITEM + $LIST_LENGTH));
  #change implemented when the 2-lines-per-item-in-the-json-file issue appeared
  #if [[ $db == "f" ]]||[[ $db == "t" ]]; then ITEM0=$(($ITEM0 + $LIST_LENGTH * 2));else ITEM0=$ITEM;fi;
  ITEM0=$ITEM;
 fi;
 if [[ $TITLE == "Previous Page" ]];
 then ITEM=$(($ITEM - $LIST_LENGTH));
  #change implemented when the 2-lines-per-item-in-the-json-file issue appeared
  #if [[ $db == "f" ]]||[[ $db == "t" ]]; then ITEM0=$(($ITEM0 - $LIST_LENGTH * 2));else ITEM0=$ITEM;fi;
  ITEM0=$ITEM;
 fi;
 if [[ $TITLE == "Abort Selection" ]];then big_loop=0;fi;
 if [[ $PLAY == " " ]]; then echo "ABORT!"; TITLE="Abort Selection";big_loop=0;clear;fi;
 PLAY="";
}

function download_video ()
{
 cd "$HOME""$DOWNLOAD_DIRECTORY";
 echo -e "${Gray}Directory: ""$HOME""$DOWNLOAD_DIRECTORY";
 echo -e "${Gray}Downloading $play_now${normal}...]";
 notify $NOTIFICATION_DURATION "$SHARE_DIR"/download.png "Video Downloading: $TITLE";
 yt-dlp "$play_now";
 notify $NOTIFICATION_DURATION "$SHARE_DIR"/magic-tape.png "Video Downloading of $TITLE is now complete.";
 echo -e "${Green}Video Downloading of${Yellow}${bold} $TITLE ${Green}is now complete.${normal}";
 sleep $TERMINAL_MESSAGE_DURATION;
 cd ;
 clear;
}

function download_audio ()
{
 cd "$HOME""$DOWNLOAD_DIRECTORY";
 echo -e "${Gray}Directory: ""$HOME""$DOWNLOAD_DIRECTORY";
 echo -e "${Gray}Downloading audio  of $play_now...${normal}";
 notify $NOTIFICATION_DURATION "$SHARE_DIR"/download.png "Audio Downloading: $TITLE";
 yt-dlp --extract-audio --audio-quality 0 --embed-thumbnail "$play_now";
 notify $NOTIFICATION_DURATION "$SHARE_DIR"/magic-tape.png "Audio Downloading of $TITLE is now complete.";
 echo -e "${Green}Audio Downloading of${Yellow}${bold} $TITLE ${Green}is now complete.${normal}";
 sleep $TERMINAL_MESSAGE_DURATION;
 cd ;
 clear;
}

function print_comment()
{
  echo -e "$1 ${Yellow}${COMMENT_AUTHORS[$2]//\"/} ${Gray}wrote ${COMMENT_TIME_TEXT[$2]//@#@#/ }: ${COMMENT_LIKE_COUNT[$2]//@#@#/ }"|sed 's/🖒 0//'
  COMMENT_TEXT[$2]="${COMMENT_TEXT[$2]/\"/}" #get rid of first "
  COMMENT_TEXT[$2]="${COMMENT_TEXT[$2]:0:-1}" #get rid of last "
  COMMENT_TEXT[$2]="${COMMENT_TEXT[$2]//\\\"/\"}" #substitute all \" with "
  echo -e "${Gray}> $3${COMMENT_TEXT[$2]//@#@#/ }"|fold -s -w $cols
}

function get_comment_arrays()
{
 unset COMMENT_AUTHORS
 unset COMMENT_TIME_TEXT
 unset COMMENT_LIKE_COUNT
 unset COMMENT_TEXT
 COMMENT_AUTHORS=($(echo $(jq ".comments[].author" $HOME/.cache/magic-tape/comments/comments.info.json)))
 COMMENT_TIME_TEXT=($(echo $(jq -r ".comments[]._time_text" $HOME/.cache/magic-tape/comments/comments.info.json|sed 's/ /@#@#/g')))
 COMMENT_LIKE_COUNT=($(echo $(jq ".comments[].like_count" $HOME/.cache/magic-tape/comments/comments.info.json|sed 's/^/🖒@#@#/g')))
 COMMENT_TEXT=($(echo $(jq  ".comments[].text" $HOME/.cache/magic-tape/comments/comments.info.json|sed 's/ /@#@#/g')))
}

function get_pinned_index()
{
 pindex="$(jq '.comments[].is_pinned' ~/.cache/magic-tape/comments/comments.info.json|grep -n "true")"
 if [[ -n "$pindex" ]]
 then
  pindex="${pindex/:*/}"
  ((pindex--))
 fi
}

function print_pinned_comment()
{

 if [[ -n "$pindex" ]]
 then
  draw_line "${Gray}" 
  print_comment "${Red}🖈" "$pindex" "${Gray}"
  draw_line "${Gray}"
 fi
}

function load_comments()
{
 if [[ $COMMENTS_TOGGLE == "yes" ]]
 then
  cols=$(tput cols)
  echo -e "${Gray}""Loading description & comments... Please wait."
  if [[ $COMMENTS_SORT != "old" ]]
  then
   yt-dlp -q --write-comments --no-download --extractor-args "youtube:max_comments=$COMMENTS_MAX,all,$COMMENT_REPLIES_MAX;comment_sort=$COMMENTS_SORT" --write-info-json "$play_now" -o $HOME/.cache/magic-tape/comments/comments>/dev/null 2>&1;
   get_comment_arrays
   com_line=0
   com_count="$(jq '.comment_count' $HOME/.cache/magic-tape/comments/comments.info.json)"
   get_pinned_index
   draw_line "${Gray}";  draw_line "${Gray}"
   echo -e "\n${Yellow}${bold}DESCRIPTION${normal}\n\n${Green}$(jq '.description' $HOME/.cache/magic-tape/comments/comments.info.json)"
   draw_line "${Gray}";  draw_line "${Gray}"
   echo -e "\n${Yellow}${bold}COMMENTS${normal}${Gray} ($com_count)"
   if [[ $com_count -eq 0 ]];then echo -e "No comments";else echo -e "View $COMMENTS_SORT comments first:\n";fi
   if [[ $PINNED_COMMENTS == "first" ]]
   then
    print_pinned_comment;
   fi
   while [ $com_line -le $((com_count-1)) ]
   do
    if [[ $com_line != $pindex ]]
    then
      print_comment "${Gray}$((com_line+1)) " "$com_line" "${Cyan}"
     ((com_line++))
     draw_line "${Gray}"
    else
     ((com_line++))
    fi
   done
   if [[ $PINNED_COMMENTS == "last" ]]
   then
    print_pinned_comment
   fi
  else
   yt-dlp -q --write-comments --no-download --extractor-args "youtube:max_comments=all,all,$COMMENT_REPLIES_MAX;comment_sort=new" --write-info-json "$play_now" -o $HOME/.cache/magic-tape/comments/comments>/dev/null 2>&1;
   com_count="$(jq '.comment_count' $HOME/.cache/magic-tape/comments/comments.info.json)"
   get_comment_arrays
   draw_line "${Gray}";  draw_line "${Gray}"
   echo -e "\n${Yellow}${bold}DESCRIPTION${normal}\n\n${Green}$(jq '.description' $HOME/.cache/magic-tape/comments/comments.info.json)"|fold -s -w $cols
   draw_line "${Gray}";  draw_line "${Gray}"
   if [[ $com_count -gt $COMMENTS_MAX ]];then com_last=$((com_count-COMMENTS_MAX));else com_last=0;fi
      echo -e "\n${Yellow}${bold}COMMENTS${normal}${Gray} ($((com_count-com-last)))"
   if [[ $com_count -eq 0 ]];then echo -e "No comments";else echo -e "View $COMMENTS_SORT comments first:\n";fi
   get_pinned_index
   if [[ $PINNED_COMMENTS == "first" ]]
   then
    print_pinned_comment;
   fi
   com_line=$((com_count-1))
   c_i=0
   while [ $com_line -ge $com_last ]
   do
    if [[ $com_line != $pindex ]]
    then
     print_comment "${Gray}$((c_i+1))" "$com_line" "${Cyan}"
     ((com_line--))
     ((c_i++))
     draw_line "${Gray}"
    else
     ((com_line--))
    fi
   done
   if [[ $PINNED_COMMENTS == "last" ]]
   then
    print_pinned_comment
   fi

###################
  fi
 fi
 print_mpv_video_shortcuts
}

function message_audio_video ()
{
 echo -e "${Gray}Playing: $play_now\nTitle  : $TITLE\nChannel: $channel_name${normal}";
 if [[ -n "$play_now" ]] && [[ -n "$TITLE" ]] && [[ -z "$(tail -1 $HOME/.cache/magic-tape/history/watch_history.txt|grep "$play_now" )" ]];
 then echo "$channel_id"" ""$channel_name"" ""$play_now"" ""$TITLE">>$HOME/.cache/magic-tape/history/watch_history.txt;
 fi;
 notify $NOTIFICATION_DURATION "$notification_img" "Playing: $TITLE";
 }

function select_action ()
{
 clear;
 # Build the menu options string dynamically
 local menu_options="${Green}${ICON_PLAY}${normal} Play Best Video\n${Green}${ICON_PLAY_AUDIO}${normal} Play Best Audio\n${Green}${ICON_PLAY}${normal} Play Video 720p\n${Green}${ICON_PLAY}${normal} Play Video 360p\n${Green}${ICON_PLAY}${normal} Play Video 144p\n${Cyan}${ICON_DOWNLOAD}${normal} Download Video\n${Cyan}${ICON_DOWNLOAD}${normal} Download Audio\n${Red}${ICON_LIKE}${normal} Like Video"
 
 # Conditionally add channel options if channel_name is not "null" or empty
 if [[ "$channel_name" != "null" ]] && [[ -n "$channel_name" ]]; then
    menu_options+="\n${Yellow}${ICON_CHANNEL}${normal} Browse Feed of channel \"$channel_name\"\n${Yellow}${ICON_SUBSCRIBE}${normal} Subscribe to channel \"$channel_name\""
 fi

 # Conditionally add the Refresh option if browsing a playlist
 if [[ "$FEED" == *"/playlist?list="* ]]; then
    menu_options+="\n${Cyan}${normal} Refresh Playlist Cache"
 fi
 
 menu_options+="\n${Magenta}${ICON_BROWSER}${normal}Open in browser\n${Magenta}${ICON_LINK}${normal} Copy link\n${Cyan}${ICON_BACK}${normal} Back\n${Cyan}${ICON_MAIN_MENU}${normal} Back to Main Menu"

ACTION="$(echo -e "$menu_options"|eval "$PREF_SELECTOR"\"Select action \")";
 case $ACTION in
   *"Play Best Video"*) message_audio_video;load_comments&mpv --msg-level=all=no "$play_now";play_now="";TITLE="";
  ;;
  *"Play Best Audio"*) message_audio_video;load_comments&mpv --ytdl-raw-options=format=ba "$play_now";play_now="";TITLE="";
  ;;
  *"Play Video 720p"*) message_audio_video;load_comments&mpv --msg-level=all=no --ytdl-raw-options=format="22/bv*[height<=720]+ba/b[height<=720] / wv*+ba/w" "$play_now";play_now="";TITLE="";
  ;;
  *"Play Video 360p"*) message_audio_video;load_comments&mpv --msg-level=all=no --ytdl-raw-options=format="18/bv*[height<=360]+ba/b[height<=480] / wv*+ba/w" "$play_now";play_now="";TITLE="";
  ;;
  *"Play Video 144p"*) message_audio_video;load_comments&mpv  --msg-level=all=no --ytdl-raw-options=format="bv*[height<=144]+ba/b[height<=360] / wv*+ba/w" "$play_now";play_now="";TITLE="";
  ;;
  *"Download Video"*) clear;download_video;echo -e "\n${Green}Video Download complete.\n${normal}";
  ;;
  *"Download Audio"*) clear;download_audio;echo -e "\n${Green}Audio Download complete.${normal}\n";
  ;;
  *"Like Video"*) clear;
   if [[ -z "$(grep "$play_now" $HOME/.cache/magic-tape/history/liked.txt)" ]];
   then echo "$channel_id"" ""$channel_name"" ""$play_now"" ""$TITLE">>$HOME/.cache/magic-tape/history/liked.txt;
   notify $NOTIFICATION_DURATION "$SHARE_DIR"/magic-tape.png "❤️ Video added to Liked Videos.";
   else notify $NOTIFICATION_DURATION "$SHARE_DIR"/magic-tape/png "❤️ Video already added to Liked Videos.";
   fi;
  ;;
  *"Refresh Playlist Cache"*)
      local playlist_id=$(echo "$FEED" | sed 's/\/playlist?list=//')
      # Use a wildcard to find all page caches for this playlist
      local cache_files_pattern="$HOME/.cache/magic-tape/json/playlist-${playlist_id}-p*.json"
      # Check if any files match the pattern before trying to delete
      if ls $cache_files_pattern 1> /dev/null 2>&1; then
        rm $cache_files_pattern
        notify $NOTIFICATION_DURATION "$SHARE_DIR"/magic-tape.png "Cache cleared. Re-open playlist to refresh."
      else
        notify $NOTIFICATION_DURATION "$SHARE_DIR"/magic-tape.png "No cache found for this playlist."
      fi
      ;;
  *"Browse Feed of channel"*) clear;db="c"; P="$channel_id";
   channel_feed;
  ;;
  *"Subscribe to channel"*) clear;
   if [ -n "$(grep $channel_id $HOME/.cache/magic-tape/subscriptions/subscriptions.txt)" ];
   then notify $NOTIFICATION_DURATION $HOME/.cache/magic-tape/subscriptions/jpg/$channel_id".jpg" "You are already subscribed to $channel_name ";
   else C=${channel_name// /+};C=${C//\'/%27};
    if [[ "$C" == "null" ]]; then notify $NOTIFICATION_DURATION "$SHARE_DIR"/magic-tape.png "❌ You cannot subscribe to this channel (null)";
    else echo -e "${Gray}Downloading data of $channel_name${normal}${Green} channel...${normal}";
     yt-dlp --cookies-from-browser $PREF_BROWSER --flat-playlist --playlist-start 1 --playlist-end 10 -j "https://www.youtube.com/results?search_query="$C"&sp=EgIQAg%253D%253D"|grep "$channel_id">$HOME/.cache/magic-tape/json/channel_search.json;
     channel_thumbnail_url="$(jq '.thumbnails[1].url' $HOME/.cache/magic-tape/json/channel_search.json|sed 's/"//g')";
     echo -e "${Gray}Dowloading thumbnail of $channel_name channel...${normal}";
     curl -s -o $HOME/.cache/magic-tape/subscriptions/jpg/$channel_id".jpg" "https:""$channel_thumbnail_url" 2>/dev/null;
     echo -e "${Gray}Done.${normal}";
     echo "$channel_id"" ""$channel_name">>$HOME/.cache/magic-tape/subscriptions/subscriptions.txt;
     notify $NOTIFICATION_DURATION $HOME/.cache/magic-tape/subscriptions/jpg/$channel_id".jpg" "You have subscribed to $channel_name ";
     echo -e "${Red}${bold}NOTICE: ${Yellow}${bold}In order for this action to take effect in YouTube, you need to subscribe manually from a browser as well.\nDo you want to do it now? (Y/y)${normal}"|fold -w 75 -s;
     read -N 1 sas;echo -e "\n";
     if [[ $sas == Y ]] || [[ $sas == y ]];then $LINK_BROWSER "https://www.youtube.com/channel/"$channel_id&echo -e "${Gray}Opened $PREF_BROWSER${normal}";fi;
    fi;
   fi;
  ;;
  *"Open in browser"*)clear;notify $NOTIFICATION_DURATION "$SHARE_DIR"/magic-tape.png "🌐 Opening video in browser..."& $LINK_BROWSER "$play_now";
  ;;
  *"Copy link"*) clear; copy_to_clipboard "$play_now" && notify $NOTIFICATION_DURATION "$SHARE_DIR"/magic-tape.png "🔗 Link copied to clipboard.";
  ;;
  *"Back"*) clear; # No action needed, just return to select_video
  ;;
  *"Back to Main Menu"*) clear; exec "$0"; # Restart the script
  ;;
   "") clear; # User pressed ESC, go back to video list
   ;;
  *)echo -e "\n😕${Yellow}${bold}$db${normal} ${Green}is an invalid key, please try again.\n"; sleep $TERMINAL_MESSAGE_DURATION;clear;
  ;;
 esac
 ACTION="";
 kill "$(jobs -l|grep 'load_comments'|awk '{print $2}')">/dev/null 2>&1;
 sleep .5
}

function empty_query ()
{
 clear;
 echo -e "${Red}${ICON_QUIT}${normal} Selection cancelled...";
 sleep $TERMINAL_MESSAGE_DURATION;
}
###############################################################################
SHARE_DIR=$HOME/.local/share/magic-tape/png
magic_tape_pid==$(ps -e|grep magic-tape.sh|tail -2|head -1|awk '{print $1}')
kitty_version=$(kitty -v|awk '{print $2}'|sed 's/0.//;s/\..*//')
export -f draw_preview draw_uber clear_image start_ueberzug finalise clean_upp draw_upp
load_config
export IMAGE_SUPPORT UEBERZUG_FIFO_MAGIC_TAPE SOCKET Green Yellow Red Magenta Cyan bold normal $FZF_PREVIEW_COLUMNS $FZF_PREVIEW_LINES SHARE_DIR kitty_version
#trap exit_upp HUP INT QUIT TERM EXIT ERR ABRT
db=""
load_config
if [[ $IMAGE_SUPPORT == "ueberzugpp" ]];then trap exit_upp  HUP INT QUIT TERM EXIT ERR ABRT ;clean_upp; fi
clear_image
while [ "$db" != "q" ]
do fzf_output="$(echo -e "${Yellow}${bold}┏┳┓┏━┓┏━╸╻┏━╸   ╺┳╸┏━┓┏━┓┏━╸${normal}\n${Yellow}${bold}┃┃┃┣━┫┃╺┓┃┃  ╺━╸ ┃ ┣━┫┣━┛┣╸ ${normal}\n${Yellow}${bold}╹ ╹╹ ╹┗━┛╹┗━╸    ╹ ╹ ╹╹  ┗━╸${normal} \n ${Red}${ICON_FEED}${normal}  ${Yellow}${bold}f${normal} ${Red}to browse Subscriptions Feed${normal}\n ${Red}${ICON_ALGORITHM}${normal}  ${Yellow}${bold}y${normal} ${Red}to browse YT Algorithm Feed${normal}\n ${Red}${ICON_PLAYLIST}${normal}  ${Yellow}${bold}t${normal} ${Red}to browse Your Playlists${normal}\n ${Green}${ICON_SEARCH}${normal}  ${Yellow}${bold}s${normal} ${Green}to Search for a key word/phrase${normal}\n ${Green}${ICON_REPEAT}${normal}  ${Yellow}${bold}r${normal} ${Green}to Repeat previous action${normal}\n ${Green}${ICON_CHANNEL}${normal}  ${Yellow}${bold}c${normal} ${Green}to select a Channel Feed${normal}\n ${Magenta}${ICON_LIKED}${normal}  ${Yellow}${bold}l${normal} ${Magenta}to browse your Liked Videos${normal}\n ${Magenta}${ICON_HISTORY}${normal}  ${Yellow}${bold}h${normal} ${Magenta}to browse your Watch History${normal}\n ${Magenta}${ICON_SEARCH_HISTORY}${normal}  ${Yellow}${bold}j${normal} ${Magenta}to browse your Search History${normal}\n ${Cyan}${ICON_MISC}${normal}  ${Yellow}${bold}m${normal} ${Cyan}for Miscellaneous Menu${normal}\n ${Cyan}${ICON_QUIT}${normal}  ${Yellow}${bold}q${normal} ${Cyan}to Quit${normal}"|fzf \
--preview-window=0 \
--disabled \
--color='gutter:-1' \
--reverse \
--ansi \
--tiebreak=begin \
--border=rounded \
+i \
+m \
--nth=2.. \
--info=hidden \
--header-lines=3 \
--prompt="Enter:" \
--header-first --cycle \
--expect=A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,1,2,3,4,5,6,7,8,9,0,enter )"
   key_press=$(echo "$fzf_output" | head -n 1)
   if [[ "$key_press" == "enter" ]]; then
     db=$(echo "$fzf_output" | sed -n '2p' | awk '{print $2}')
   else
     db=$key_press
   fi
 YTDLP_MATCH_FILTER_ARG=""
 case $db in
  "f") clear;
     big_loop=1;
     ITEM=1;
     ITEM0=1;
     FEED="/feed/subscriptions";
     while [ $big_loop -eq 1 ];
     do fzf_header="$(echo ${FEED^^}|sed 's/[\/\?=]/ /g') videos $ITEM to $(($ITEM + $(($LIST_LENGTH - 1))))";
      get_feed_json;
      get_data;
      small_loop=1;
      while [ $small_loop -eq 1 ];
      do select_video ;
       if [[ "$TITLE" == "Next Page" ]]||[[ "$TITLE" == "Previous Page" ]];then small_loop=0;fi;
       if [[ "$TITLE" == "Abort Selection" ]];then small_loop=0;big_loop=0;fi;
       if [[ "$TITLE" != "Abort Selection" ]]&&[[ "$TITLE" != "Next Page" ]]&&[[ "$TITLE" != "Previous Page" ]];then select_action;fi;
      done;
     done;
     clear;clear_image;
  ;;
  "y") clear;
     big_loop=1;
     ITEM=1;
     ITEM0=1;
     FEED="";
     while [ $big_loop -eq 1 ];
     do fzf_header="YT algorithm suggestions, videos $ITEM to $(($ITEM + $(($LIST_LENGTH - 1))))";
      get_feed_json;
      get_data;
      small_loop=1;
      while [ $small_loop -eq 1 ];
      do select_video ;
       if [[ "$TITLE" == "Next Page" ]]||[[ "$TITLE" == "Previous Page" ]];then small_loop=0;fi;
       if [[ "$TITLE" == "Abort Selection" ]];then small_loop=0;big_loop=0;fi;
       if [[ "$TITLE" != "Abort Selection" ]]&&[[ "$TITLE" != "Next Page" ]]&&[[ "$TITLE" != "Previous Page" ]];then select_action;fi;
      done;
     done;
     clear;
  ;;
  "t") clear;
     # --- STAGE 1: Select a Playlist ---
     echo -e "${Gray}Downloading playlist feed...${normal}";
     yt-dlp --ignore-errors --cookies-from-browser "$PREF_BROWSER" --flat-playlist -j "https://www.youtube.com/feed/playlists" > "$HOME/.cache/magic-tape/json/playlist_list.json" 2>/dev/null
     echo -e "${Gray}Completed.${normal}";

     jq -r '.id' "$HOME/.cache/magic-tape/json/playlist_list.json" > "$HOME/.cache/magic-tape/search/video/playlist_ids.txt"
     jq -r '.title' "$HOME/.cache/magic-tape/json/playlist_list.json" > "$HOME/.cache/magic-tape/search/video/playlist_titles.txt"
     jq -r '.video_count' "$HOME/.cache/magic-tape/json/playlist_list.json" > "$HOME/.cache/magic-tape/search/video/playlist_counts.txt"
     jq -r '.thumbnails[0].url' "$HOME/.cache/magic-tape/json/playlist_list.json" > "$HOME/.cache/magic-tape/search/video/playlist_thumbs.txt"

     # Create download list for playlist thumbnails
     cat /dev/null > "$HOME/.cache/magic-tape/search/video/playlist_thumb_downloads.txt"
     i=1
     playlist_count=$(wc -l < "$HOME/.cache/magic-tape/search/video/playlist_ids.txt")
     while [ $i -le $playlist_count ]; do
       playlist_id=$(sed -n "${i}p" "$HOME/.cache/magic-tape/search/video/playlist_ids.txt")
       img_path="$HOME/.cache/magic-tape/jpg/playlist-${playlist_id}.jpg"
       if [ ! -f "$img_path" ]; then
         thumb_url=$(sed -n "${i}p" "$HOME/.cache/magic-tape/search/video/playlist_thumbs.txt")
         if [[ -n "$thumb_url" ]] && [[ "$thumb_url" != "null" ]]; then
           echo "url = \"$thumb_url\"" >> "$HOME/.cache/magic-tape/search/video/playlist_thumb_downloads.txt"
           echo "output = \"$img_path\"" >> "$HOME/.cache/magic-tape/search/video/playlist_thumb_downloads.txt"
         fi
       fi
       ((i++))
     done
     # Start background download only if there are thumbnails to download
     if [ -s "$HOME/.cache/magic-tape/search/video/playlist_thumb_downloads.txt" ]; then
       curl -s -K "$HOME/.cache/magic-tape/search/video/playlist_thumb_downloads.txt"
     fi

     # Add an abort option to the list
     echo "Abort Selection" > "$HOME/.cache/magic-tape/search/video/playlist_titles_with_abort.txt"
     cat "$HOME/.cache/magic-tape/search/video/playlist_titles.txt" >> "$HOME/.cache/magic-tape/search/video/playlist_titles_with_abort.txt"

     # Use fzf to get the line number directly
     selected_index=$(cat -n "$HOME/.cache/magic-tape/search/video/playlist_titles_with_abort.txt" | fzf \
        --ansi \
        --layout=reverse \
        --prompt="🔎 Select Playlist: " \
        --header="Your Playlists" \
        --preview-window=left,40% \
        --cycle \
        --preview='\
            hght=$(($FZF_PREVIEW_COLUMNS /3));\
            i=$(echo {} | awk "{print \$1}");\
            if [[ $i -eq 1 ]]; then # Abort option\
                draw_preview 1 1 $FZF_PREVIEW_COLUMNS $hght "$SHARE_DIR"/abort.png;\
                echo -e "\nReturn to the main menu.";\
            else\
                # Adjust index to match original file (since we added "Abort" at the top)\
                preview_i=$((i - 1));\
                playlist_id=$(sed -n "${preview_i}p" "$HOME/.cache/magic-tape/search/video/playlist_ids.txt");\
                img_path="$HOME/.cache/magic-tape/jpg/playlist-${playlist_id}.jpg";\
                \
                if [ -f "$img_path" ]; then\
                    draw_preview 1 1 $FZF_PREVIEW_COLUMNS $hght "$img_path";\
                fi;\
\
                TITLE=$(sed -n "${preview_i}p" "$HOME/.cache/magic-tape/search/video/playlist_titles.txt");\
                COUNT=$(sed -n "${preview_i}p" "$HOME/.cache/magic-tape/search/video/playlist_counts.txt");\
                echo -e "\n\e[33m$TITLE\e[m\n\nVideo Count: $COUNT";\
            fi\
        ' | awk '{print $1}' ); clear_image;

     # Abort if nothing selected or "Abort" is chosen (line 1)
     if [[ -z "$selected_index" ]] || [[ "$selected_index" -eq 1 ]]; then
         clear;
         continue;
     fi

     # Adjust index for the 'Abort' line and get the ID and title
     actual_index=$((selected_index - 1))
     selected_playlist_id=$(sed -n "${actual_index}p" "$HOME/.cache/magic-tape/search/video/playlist_ids.txt")
     selected_playlist_title=$(sed -n "${actual_index}p" "$HOME/.cache/magic-tape/search/video/playlist_titles.txt")

     # --- STAGE 2: Browse Videos in the Selected Playlist (with Caching) ---
     generic_cache_file="$HOME/.cache/magic-tape/json/video_search.json"
     
     big_loop=1;
     ITEM=1;
     ITEM0=1;
     FEED="/playlist?list=$selected_playlist_id";

     while [ $big_loop -eq 1 ]; do
        fzf_header="Playlist: $selected_playlist_title | Videos $ITEM to $(($ITEM + $(($LIST_LENGTH - 1))))";
        
        # Use a unique cache file for each page, based on the starting item number
        video_cache_file="$HOME/.cache/magic-tape/json/playlist-${selected_playlist_id}-p${ITEM}.json"

        # If a cache file exists but is empty, remove it to force a refresh.
        if [ -f "$video_cache_file" ] && [ ! -s "$video_cache_file" ]; then
            rm "$video_cache_file"
        fi

        if [ -f "$video_cache_file" ]; then
            echo -e "${Gray}Loading playlist page from cache...${normal}";
            cp "$video_cache_file" "$generic_cache_file"
        else
            # Fetch from network
            echo -e "${Gray}Fetching playlist page, creating cache...${normal}";
            get_playlist_videos_json; # Fetches and writes to generic_cache_file
            # Only create a cache file if the download was successful (file is not empty)
            if [ -s "$generic_cache_file" ]; then
                cp "$generic_cache_file" "$video_cache_file" # Save the fetched data
            fi
        fi

        get_data;
        
        small_loop=1;
        while [ $small_loop -eq 1 ];
        do select_video ;
         if [[ "$TITLE" == "Next Page" ]]||[[ "$TITLE" == "Previous Page" ]];then small_loop=0;fi;
         if [[ "$TITLE" == "Abort Selection" ]];then small_loop=0;big_loop=0;fi;
         if [[ "$TITLE" != "Abort Selection" ]]&&[[ "$TITLE" != "Next Page" ]]&&[[ "$TITLE" != "Previous Page" ]];then select_action;fi;
        done;
     done;
     clear;
  ;;
  "s") clear;
     P="$(tac "$HOME/.cache/magic-tape/history/search_history.txt" 2>/dev/null | sed 's/+/ /g' | awk '!seen[$0]++' | fzf --layout=reverse --ansi --cycle --print-query --prompt="${ICON_SEARCH} Search YT: " | tail -n 1)"
     if [[ -z "$P" ]];
      then empty_query;
     else
      P_for_history=${P// /+}
      if [ -f "$HOME/.cache/magic-tape/history/search_history.txt" ]; then
        grep -Fxv "${P_for_history}" "$HOME/.cache/magic-tape/history/search_history.txt" > "$HOME/.cache/magic-tape/history/search_history.tmp"
        mv "$HOME/.cache/magic-tape/history/search_history.tmp" "$HOME/.cache/magic-tape/history/search_history.txt"
      fi
      echo "$P_for_history" >> "$HOME/.cache/magic-tape/history/search_history.txt"

      P=${P// /+};
      
      # Prompt user to select between Video or Playlist search
      search_type_prompt="$(echo -e "${Cyan}${ICON_SELECT_VIDEO}${normal} Search for Videos\n${Cyan}${ICON_PLAYLIST}${normal} Search for Playlists\n${Red}${ICON_MAIN_MENU}${normal} Back to Main Menu"|eval "$PREF_SELECTOR""\"Select Search Type \"")"

      if [[ -z "$search_type_prompt" ]] || [[ "$search_type_prompt" == *"Back to Main Menu"* ]]; then
          clear
          continue
      fi

      if [[ "$search_type_prompt" == *"Search for Playlists"* ]]; then
          FILTER="&sp=EgIQAw%3D%3D"
          FILT_PROMPT="Search for playlist"
      else
          # Step 1: Get duration filter
          duration_choice=$(select_duration_filter)
          if [[ "$duration_choice" == "back" ]]; then
              clear
              continue
          fi

          # Step 2: Get sort order
          sort_choice=$(select_sort_order)
          if [[ "$sort_choice" == "back" ]]; then
              clear
              continue
          fi
          
          # Step 3: Determine the final SP code based on the two choices
          case "$duration_choice" in
              "any")
                  case "$sort_choice" in
                      "relevance") FILTER="&sp=EgQQARgE";;
                      "date") FILTER="&sp=CAISAhAB";;
                      "views") FILTER="&sp=CAMSAhAB";;
                      "rating") FILTER="&sp=CAESAhAB";;
                  esac
                  ;;
              "short")
                  YTDLP_MATCH_FILTER_ARG="duration <= 240"
                  case "$sort_choice" in
                      "relevance") FILTER="&sp=EgQQARgB";;
                      "date") FILTER="&sp=CAISBEgQQARgB";;
                      "views") FILTER="&sp=CAMSBEgQQARgB";;
                      "rating") FILTER="&sp=CAESBEgQQARgB";;
                  esac
                  ;;
              "medium")
                  YTDLP_MATCH_FILTER_ARG="duration >= 240 & duration <= 1200"
                  case "$sort_choice" in
                      "relevance") FILTER="&sp=EgQQARgD";;
                      "date") FILTER="&sp=CAISBEgQQARgD";;
                      "views") FILTER="&sp=CAMSBEgQQARgD";;
                      "rating") FILTER="&sp=CAESBEgQQARgD";;
                  esac
                  ;;
              "long")
                  YTDLP_MATCH_FILTER_ARG="duration > 1200"
                  case "$sort_choice" in
                      "relevance") FILTER="&sp=EgQQARgC";;
                      "date") FILTER="&sp=CAISBEgQQARgC";;
                      "views") FILTER="&sp=CAMSBEgQQARgC";;
                      "rating") FILTER="&sp=CAESBEgQQARgC";;
                  esac
                  ;;
          esac
          FILT_PROMPT="Search" # This variable seems to be used for the fzf header.
      fi

      if [[ "$FILT_PROMPT" == *"Search for playlist"* ]]; then
        # Logic for searching for and then browsing a playlist
        ITEM=1;
        ITEM0=1;
        FEED="/results?search_query=$P$FILTER"
        get_feed_json; # This gets the list of playlists
        get_data;      # This parses them

        fzf_header="Select a playlist to browse"
        select_video # Use select_video to pick a playlist from the search results

        if [[ "$TITLE" != "Abort Selection" ]]&&[[ "$TITLE" != "Next Page" ]]&&[[ "$TITLE" != "Previous Page" ]]; then
            # Extract playlist ID and title from the selection
            # The playlist ID is in the 'play_now' url, and title is in 'TITLE'
            selected_playlist_id=$(echo "$play_now" | sed 's/.*list=//')
            selected_playlist_title=$TITLE

            # Now, use the same logic as the 't' block to browse *inside* the playlist
            generic_cache_file="$HOME/.cache/magic-tape/json/video_search.json"
            big_loop=1;
            ITEM=1;
            ITEM0=1;
            FEED="/playlist?list=$selected_playlist_id";

            while [ $big_loop -eq 1 ]; do
               fzf_header="Playlist: $selected_playlist_title | Videos $ITEM to $(($ITEM + $(($LIST_LENGTH - 1))))";

               # Use a unique cache file for each page
               video_cache_file="$HOME/.cache/magic-tape/json/playlist-${selected_playlist_id}-p${ITEM}.json"

               if [ -f "$video_cache_file" ] && [ ! -s "$video_cache_file" ]; then
                   rm "$video_cache_file"
               fi

               if [ -f "$video_cache_file" ]; then
                   echo -e "${Gray}Loading playlist page from cache...${normal}";
                   cp "$video_cache_file" "$generic_cache_file"
               else
                   echo -e "${Gray}Fetching playlist page, creating cache...${normal}";
                   get_playlist_videos_json;
                   if [ -s "$generic_cache_file" ]; then
                       cp "$generic_cache_file" "$video_cache_file"
                   fi
               fi

               get_data;

               small_loop=1;
               while [ $small_loop -eq 1 ];
               do select_video ;
                if [[ "$TITLE" == "Next Page" ]]||[[ "$TITLE" == "Previous Page" ]];then small_loop=0;fi;
                if [[ "$TITLE" == "Abort Selection" ]];then small_loop=0;big_loop=0;fi;
                if [[ "$TITLE" != "Abort Selection" ]]&&[[ "$TITLE" != "Next Page" ]]&&[[ "$TITLE" != "Previous Page" ]];then select_action;fi;
               done;
            done;
        fi
      else
        # Original logic for normal video search
        big_loop=1;
        ITEM=1;
        ITEM0=1;
        FEED="/results?search_query=""$P""$FILTER";
        while [ $big_loop -eq 1 ];
        do fzf_header="Search: $(echo ${FEED^^}|sed 's/&SP=.*$//;s/^.*SEARCH_QUERY=//;s/[\/\?=&+]/ /g') videos: $ITEM to $(($ITEM + $(($LIST_LENGTH - 1))))";
         get_feed_json;
         get_data;
         small_loop=1;
         while [ $small_loop -eq 1 ];
         do select_video ;
          if [[ "$TITLE" == "Next Page" ]]||[[ "$TITLE" == "Previous Page" ]];then small_loop=0;fi;
          if [[ "$TITLE" == "Abort Selection" ]];then small_loop=0;big_loop=0;fi;
          if [[ "$TITLE" != "Abort Selection" ]]&&[[ "$TITLE" != "Next Page" ]]&&[[ "$TITLE" != "Previous Page" ]];then select_action;fi;
         done;
        done;
      fi;
     fi;
     clear;
  ;;
  "r") clear;
     db="$(head -1 $HOME/.cache/magic-tape/history/last_action.txt)";
     ITEM="$(sed -n "2p" $HOME/.cache/magic-tape/history/last_action.txt)";
     ITEM0="$(sed -n "3p" $HOME/.cache/magic-tape/history/last_action.txt)";
     FEED="$(sed -n "4p" $HOME/.cache/magic-tape/history/last_action.txt)";
     fzf_header="$(sed -n "5p" $HOME/.cache/magic-tape/history/last_action.txt)";
     big_loop=1;
     first=1;
     while [ $big_loop -eq 1 ];
     do if [ $first -eq 0 ];then fzf_header="$(echo ${FEED^^}|sed 's/&SP=.*$//;s/^.*SEARCH_QUERY=/search: /;s/[\/\?=]/ /g') videos $ITEM to $(($ITEM + $(($LIST_LENGTH - 1))))";get_feed_json;get_data;fi;
        small_loop=1;
        while [ $small_loop -eq 1 ];
        do select_video ;
         first=0;
         if [[ "$TITLE" == "Next Page" ]]||[[ "$TITLE" == "Previous Page" ]];then small_loop=0;fi;
         if [[ "$TITLE" == "Abort Selection" ]];then small_loop=0;big_loop=0;fi;
         if [[ "$TITLE" != "Abort Selection" ]]&&[[ "$TITLE" != "Next Page" ]]&&[[ "$TITLE" != "Previous Page" ]];then select_action;fi;
        done;
        first=0;
     done;
     clear;
  ;;
  "c") clear;
     c_loop=1
     while [[ $c_loop -eq 1 ]]; do
       channel_search="";
       if [[ -f $HOME/.cache/magic-tape/subscriptions/subscriptions.txt ]];
       then channel_search=yes;
       else echo -e " ${Yellow}There are no subscriptions locally imported from YouTube. Do you wish to import your subscriptions now?(Y/y)";
        read -N 1 import_subs_prompt ;echo;
        if [[ $import_subs_prompt == Y ]]||[[ $import_subs_prompt == y ]];
        then import_subscriptions;channel_search=yes;
        else channel_search=no; c_loop=0;
        fi;
       fi;

       if [[ $channel_search == yes ]];
       then
        selected_line="$( (echo -e "back_to_menu ${Cyan}${ICON_BACK} Back to Main Menu${normal}"; cat "$HOME/.cache/magic-tape/subscriptions/subscriptions.txt") | fzf \
          --ansi \
          --layout=reverse \
          --height=100% \
          --prompt="🔎 Select channel: " \
          --with-nth=2.. \
          --preview-window=left,40% \
          --preview='
              hght=$(($FZF_PREVIEW_COLUMNS / 3));
              line="{}";
              clean_line=$(echo "$line" | sed "s/\x1b\[[0-9;]*m//g");
              channel_id=$(echo "$clean_line" | cut -d" " -f1 | tr -d "\047");
              channel_name=$(echo "$clean_line" | cut -d" " -f2-);
              img_path="$HOME/.cache/magic-tape/subscriptions/jpg/${channel_id}.jpg";

              if [[ "$IMAGE_SUPPORT" == "kitty" ]]; then clear_image; fi;
              if [[ "$IMAGE_SUPPORT" == "ueberz"* ]];then ll=0; while [ $ll -le $hght ];do echo "";((ll++));done;fi;
              if [[ "$IMAGE_SUPPORT" == "kitty" ]]&&[[ $kitty_version -le 21 ]];then ll=0; while [ $ll -le $hght ];do echo "";((ll++));done;fi;

              if [[ "$channel_id" == "back_to_menu" ]]; then
                  draw_preview 1 1 $FZF_PREVIEW_COLUMNS $hght "$SHARE_DIR"/abort.png;
              elif [ -f "$img_path" ]; then
                  draw_preview 1 1 $FZF_PREVIEW_COLUMNS $hght "$img_path";
              else
                  draw_preview 1 1 $FZF_PREVIEW_COLUMNS $hght "$SHARE_DIR"/magic-tape.png;
              fi;

              ll=1; echo -ne "\e[30m"; while [ $ll -le $FZF_PREVIEW_COLUMNS ];do echo -n -e "─";((ll++));done;echo -e "\e[m";
              echo -e "\n\e[33m$(echo "$line" | cut -d" " -f2-)\e[m" | fold -w $FZF_PREVIEW_COLUMNS -s;
          ' || true
        )";
        clear_image;

        if [[ -z "$selected_line" ]]; then
          # User pressed ESC in channel list, so exit to main menu
          c_loop=0
        else
          clean_line=$(echo "$selected_line" | sed "s/\x1b\[[0-9;]*m//g");
          P=$(echo "$clean_line" | awk '{print $1}');
          if [[ "$P" == "back_to_menu" ]]; then
            # User selected "Back to Main Menu" in channel list
            c_loop=0
          else
            # User selected a channel, show its feed
            channel_name=$(echo "$clean_line" | cut -d' ' -f2-);
            echo -e "${Gray}Selected channel: $channel_name"${normal};
            channel_feed;
            # After channel_feed returns (e.g., from ESC in video list),
            # this loop will iterate again, showing the channel list.
          fi
        fi;
       else
         # This case is for when channel_search is not "yes".
         c_loop=0
       fi;
     done;
     clear; # Clean up screen before showing main menu again
  ;;
  "h") clear;
     TITLE="$(echo -e "$(tac $HOME/.cache/magic-tape/history/watch_history.txt|sed 's/^.*https:\/\/www\.youtube\.com/https:\/\/www\.youtube\.com/g'|cut -d' ' -f2-)\n${Cyan}${ICON_BACK}${normal} Back to Main Menu"|eval "$PREF_SELECTOR""\"🔎 Select previous video \"" || true)";
     if [[ "$TITLE" == *"${ICON_BACK} Back to Main Menu"* ]]||[[ -z "$TITLE" ]];
     then empty_query;
     else  HISTORY_TITLE="$(echo "$TITLE"|sed 's/[][}{*\]//g')";
      channel_id="$(sed 's/[][}{*\]//g' $HOME/.cache/magic-tape/history/watch_history.txt|grep "$HISTORY_TITLE" |head -1|awk '{print $1}')";
      channel_name="$(sed 's/[][}{*\]//g' $HOME/.cache/magic-tape/history/watch_history.txt|grep "$HISTORY_TITLE"|head -1|sed 's/https:\/\/www\.youtube\.com.*$//'|cut -d' ' -f2-)";
      play_now="$(sed 's/[][}{*\]//g' $HOME/.cache/magic-tape/history/watch_history.txt|grep "$HISTORY_TITLE"|head -1|sed 's/^.*https:\/\/www\.youtube\.com/https:\/\/www\.youtube\.com/g'|awk '{print $1}')";
      notification_img="$HOME/.cache/magic-tape/jpg/img-"${play_now##*=}".jpg";
      select_action;
     fi;
     clear;
  ;;
  "j") clear;
     P="$(echo -e "$(tac $HOME/.cache/magic-tape/history/search_history.txt|sed 's/+/ /g;s/\//')\n${Cyan}${ICON_BACK}${normal} Back to Main Menu"|eval "$PREF_SELECTOR""\"🔎 Select key word/phrase \"" || true)";
     if [[ "$P" == *"${ICON_BACK} Back to Main Menu"*  ]]||[[ -z "$P" ]];
     then empty_query;
     else P=${P// /+};
      big_loop=1;
      ITEM=1;
      ITEM0=$ITEM;
      search_filter;
      FEED="/results?search_query=""$P""$FILTER";
      while [ $big_loop -eq 1 ];
              do fzf_header="$(echo "$FILT_PROMPT"|sed 's/ .*/ /')""$(echo ${FEED^^}|sed 's/&SP=.*$//;s/^.*SEARCH_QUERY=/search: /g;s/[\/\?=&+]/ /g') videos: $ITEM to $(($ITEM + $(($LIST_LENGTH - 1))))";       get_feed_json;
       get_data;
       small_loop=1;
       while [ $small_loop -eq 1 ];
       do select_video ;
        if [[ "$TITLE" == "Next Page" ]]||[[ "$TITLE" == "Previous Page" ]];then small_loop=0;fi;
        if [[ "$TITLE" == "Abort Selection" ]];then small_loop=0;big_loop=0;fi;
        if [[ "$TITLE" != "Abort Selection" ]]&&[[ "$TITLE" != "Next Page" ]]&&[[ "$TITLE" != "Previous Page" ]];then select_action;fi;
       done;
      done;
      fi;
     clear;
  ;;
  "l") clear;
     TITLE="$(echo -e "$(tac $HOME/.cache/magic-tape/history/liked.txt|sed 's/^.*https:\/\/www\.youtube\.com/https:\/\/www\.youtube\.com/g'|cut -d' ' -f2-)\n${Cyan}${ICON_BACK}${normal} Back to Main Menu"|eval "$PREF_SELECTOR""\"❤️ Select liked video \"" || true)";
     if [[ "$TITLE" == *"${ICON_BACK} Back to Main Menu"* ]]||[[ -z "$TITLE" ]];
     then empty_query;
     else TITLE=${TITLE//\*/\\*};
     channel_id="$(grep "$TITLE" $HOME/.cache/magic-tape/history/liked.txt|head -1|awk '{print $1}')";
     channel_name="$(grep "$TITLE" $HOME/.cache/magic-tape/history/liked.txt|head -1|sed 's/https:\/\/www\.youtube\.com.*$//'|cut -d' ' -f2-)";
     play_now="$(grep "$TITLE" $HOME/.cache/magic-tape/history/liked.txt|head -1|sed 's/^.*https:\/\/www\.youtube\.com/https:\/\/www\.youtube\.com/g'|awk '{print $1}')";
      notification_img="$HOME/.cache/magic-tape/jpg/img-"${play_now##*=}".jpg";
      select_action;
     fi;
     clear;
  ;;
  "m") clear;misc_menu;
  ;;
  "q") notify $NOTIFICATION_DURATION "$SHARE_DIR"/magic-tape.png "Exited magic-tape";
  ;;
  *)clear;echo -e "\n${Yellow}${bold}$db${normal} is an invalid key, please try again.\n";sleep $TERMINAL_MESSAGE_DURATION;
  ;;
 esac
done

