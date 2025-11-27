#!/bin/bash
# 🎬 ia-search — Interactive Internet Archive browser & downloader
# Features: Top Collections paging, caching, vim text viewer, search mode with smart Esc, and smooth transitions.

# --- Player Config ---
VIDEO_PLAYER="mpv"
AUDIO_PLAYER="mpv"
IMAGE_VIEWER="nsxiv"
PDF_VIEWER="zathura"
VIDEO_DOWNLOADER="yt-dlp"

# --- API Config ---
API_URL="https://archive.org/advancedsearch.php"

# --- Cache Config ---
CACHE_FILE="$HOME/.cache/ia-search-collections.json"
mkdir -p "$(dirname "$CACHE_FILE")"
CACHE_EXPIRY=$((60*60*24))  # 24 hours

# --- Show Collections ---
show_collections() {
    local PAGE_SIZE=50
    local page=0

    fetch_collections() {
        echo "📚 Fetching top collections from Internet Archive..."
        json=$(curl -sG "$API_URL" \
            --data-urlencode "q=mediatype:collection" \
            --data-urlencode "fl[]=identifier" \
            --data-urlencode "fl[]=title" \
            --data-urlencode "fl[]=description" \
            --data-urlencode "sort[]=downloads desc" \
            --data-urlencode "rows=500" \
            --data-urlencode "output=json")
        echo "$json" > "$CACHE_FILE"
    }

    if [ -f "$CACHE_FILE" ] && [ $(( $(date +%s) - $(stat -c %Y "$CACHE_FILE") )) -lt $CACHE_EXPIRY ]; then
        echo "📚 Loading collections from cache..."
        json=$(cat "$CACHE_FILE")
    else
        fetch_collections
    fi

    mapfile -t all_entries < <(echo "$json" | jq -r '.response.docs[] | "\(.title) [\(.identifier)]"')
    local total_pages=$(( (${#all_entries[@]} + PAGE_SIZE - 1) / PAGE_SIZE ))

    while true; do
        local start=$(( page * PAGE_SIZE ))
        local end=$(( start + PAGE_SIZE - 1 ))
        [ $end -ge ${#all_entries[@]} ] && end=$((${#all_entries[@]} - 1))

        local page_entries=("${all_entries[@]:start:end-start+1}")

        choices=("[🔍 Search all collections]" "[🔄 Refresh cache]" "")
        choices+=("${page_entries[@]}")
        choices+=("" "[➡️ Next page]" "[❌ Exit]")

        selection=$(printf '%s\n' "${choices[@]}" | fzf \
            --prompt="📂 Select collection (Page $((page+1))/$total_pages) > " \
            --height=100% \
            --reverse \
            --border)

        case "$selection" in
            "[🔄 Refresh cache]")
                fetch_collections
                mapfile -t all_entries < <(echo "$json" | jq -r '.response.docs[] | "\(.title) [\(.identifier)]"')
                total_pages=$(( (${#all_entries[@]} + PAGE_SIZE - 1) / PAGE_SIZE ))
                page=0
                echo "✅ Cache refreshed."
                ;;
            "[🔍 Search all collections]")
                search_mode
                continue
                ;;
            "[➡️ Next page]")
                ((page++))
                if [ $page -ge $total_pages ]; then
                    echo "⚠️  No more pages."
                    ((page--))
                fi
                ;;
            "[❌ Exit]"|"")
                echo "👋 Exiting."
                exit 0
                ;;
            *)
                collection=$(echo "$selection" | sed -E 's/.*\[(.*)\]$/\1/')
                browse_collection "$collection"
                ;;
        esac
    done
}

# --- Search Mode ---
search_mode() {
    local query identifier

    while true; do
        query=$(printf '' | fzf --prompt="🔍 Type search query (ESC to return to main) > " --print-query --height=10 --reverse --border | head -n1)
        [ -z "$query" ] && return 0

        while true; do
            echo "🔎 Searching for \"$query\" ..."
            identifier=$(ia search "$query" --itemlist | fzf --prompt="🎥 Select an item from '$query' (ESC to new search) > " --height=100% --reverse --border)
            if [ -z "$identifier" ]; then
                break
            fi
            open_item "$identifier"
        done
    done
}

# --- Browse Collection ---
browse_collection() {
    local coll="$1"
    echo "📁 Browsing collection: $coll"
    identifier=$(ia search "collection:$coll" --itemlist | fzf --prompt="🎞️ Select item from $coll > " --height=100% --reverse --border)
    [ -z "$identifier" ] && echo "🚫 No item selected." && return
    open_item "$identifier"
}

# --- Open / Play / Download Item ---
open_item() {
    local identifier="$1"
    echo "📂 Fetching file list for: $identifier ..."
    file_list=$(ia list "$identifier")
    filename=$(echo "$file_list" | fzf --prompt="📁 Select a file to open > " --height=100% --reverse --border)
    [ -z "$filename" ] && echo "🚫 No file selected." && return

    case "$filename" in
        *.mp4|*.mkv|*.avi|*.webm|*.flv|*.ogv|*.mp3|*.ogg|*.flac|*.wav|*.m4a)
            action_label="▶️ Play" ;;
        *) action_label="📂 Open" ;;
    esac

    action=$(echo -e "$action_label\n⬇️ Download" | fzf --prompt="🎬 Choose action for $filename > " --height=100% --reverse --border)
    [ -z "$action" ] && echo "🚫 No action selected." && return

    filename_encoded=$(echo "$filename" | sed 's/ /%20/g')
    url="https://archive.org/download/$identifier/$filename_encoded"

    if [ "$action" == "▶️ Play" ] || [ "$action" == "📂 Open" ]; then
        case "$filename" in
            *.mp4|*.mkv|*.avi|*.webm|*.flv|*.ogv)
                echo "🎞️ Playing video..."
                video_basename=$(echo "$filename" | sed 's/\.[^.]*$//')
                
                sub_file=$(echo "$file_list" | grep -Fx -e "${video_basename}.srt" -e "${video_basename}.ass" | head -n1)

                # Create a temporary log file to monitor mpv status
                mpv_log=$(mktemp)

                if [ -n "$sub_file" ]; then
                    sub_encoded=$(echo "$sub_file" | sed 's/ /%20/g')
                    sub_url="https://archive.org/download/$identifier/$sub_encoded"
                    # Redirect stderr/stdout to log file so we can grep it
                    $VIDEO_PLAYER "$url" --sub-file="$sub_url" > "$mpv_log" 2>&1 &
                else
                    $VIDEO_PLAYER "$url" > "$mpv_log" 2>&1 &
                fi 
                
                pid=$!

                # --- Real-time Launch Monitor ---
                # This loop waits until mpv prints "VO:" (Video Output) or "AO:" (Audio Output) to the log.
                # This confirms that buffering is done and the window is actually ready.
                (
                    # Timeout after 200 ticks (approx 20 seconds) to prevent hanging on slow networks
                    for ((i=0; i<200; i++)); do
                        # If mpv crashes, stop waiting
                        if ! kill -0 "$pid" 2>/dev/null; then break; fi
                        
                        # Check the log for "VO:" or "AO:" (Success signals)
                        if grep -q -E "^(VO|AO):" "$mpv_log"; then break; fi
                        
                        echo -n "."
                        sleep 0.1
                    done
                ) | pv -p -t -e -N "🚀 Launching mpv" -s 200 > /dev/null

                # Clean up
                rm -f "$mpv_log"
                ;;

            *.mp3|*.ogg|*.flac|*.wav|*.m4a)
                echo "🎧 Playing audio..."
                $AUDIO_PLAYER "$url" >/dev/null 2>&1 & ;;
            *.png|*.jpg|*.jpeg|*.gif|*.bmp)
                temp_file=$(mktemp)
                curl -sL "$url" | pv > "$temp_file"
                [ -s "$temp_file" ] && ($IMAGE_VIEWER "$temp_file" >/dev/null 2>&1; rm "$temp_file") & ;;
            *.pdf)
                temp_file=$(mktemp)
                curl -sL "$url" | pv > "$temp_file"
                [ -s "$temp_file" ] && ($PDF_VIEWER "$temp_file" >/dev/null 2>&1; rm "$temp_file") & ;;
            *.txt|*.md|*.rst|*.csv|*.log|*.tex|*.sh|*.py|*.c|*.cpp|*.h|*.java|*.js|*.ts|*.json|*.xml|*.yaml|*.yml|*.ini|*.conf|*.cfg)
                temp_file=$(mktemp)
                curl -sL "$url" -o "$temp_file"
                if [ -s "$temp_file" ]; then
                    vim "$temp_file"
                    rm -f "$temp_file"
                else
                    echo "🚫 Failed to fetch $filename"
                fi ;;
            *)
                xdg-open "$url" >/dev/null 2>&1 &
                ;;
        esac
    elif [ "$action" == "⬇️ Download" ]; then
        case "$filename" in
            *.mp4|*.mkv|*.avi|*.webm|*.flv|*.ogv)
                $VIDEO_DOWNLOADER "$url" ;;
            *)
                curl -L -o "$filename" "$url" ;;
        esac
        echo "✅ Done."
    fi
}

# --- Main ---
show_collections
echo "👋 Goodbye."
exit 0
