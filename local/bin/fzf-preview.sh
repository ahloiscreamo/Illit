#!/usr/bin/env bash

# fzf-preview - A basic preview script for fzf
# Copyright (C) 2025 niksingh710 <nik.singh710@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, version 3.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

set -o errexit
set -o nounset
set -o pipefail

FZF_PREVIEW_IMAGE_HANDLER="${FZF_PREVIEW_IMAGE_HANDLER:-sixel}"

LOCATION="$1"
EXTENSION="${LOCATION##*.}"
EXTENSION="${EXTENSION,,}"
MIME_TYPE=$(file --mime-type -b "$LOCATION")

test -d "$HOME/.cache/fzf" || mkdir -p "$HOME/.cache/fzf"
# unique non-existent cache file path
# Utilised to cache the thumbnail of the file when needed
CACHE_FILE="$HOME/.cache/fzf/thumbnail.$(echo -n "$(readlink -f "$1")" | sha256sum | awk '{print $1}')"

# functions to handle specific type of files
handle_text() {
  case "$EXTENSION" in
  md) glow --style=auto "$LOCATION" ;;
  htm | html) w3m -T text/html -dump "$LOCATION" ;;
  *) bat -p --color=always "$LOCATION" ;;
  esac
}

resolve_symlink() {
  TARGET="$(readlink "$LOCATION")"

  # To better show nix store paths instead of a long string

  # Match paths starting with /nix/store/<hash>/<optional path>
  if [[ "$TARGET" =~ ^/nix/store/([a-z0-9]{32}-[^/]+)(/.*)?$ ]]; then
    FULL_HASH="${BASH_REMATCH[1]}"
    PATH_TO_FILE="${BASH_REMATCH[2]}"
    echo -e "Symlink to a nix store path"
    echo -e "hash: \e[34m$FULL_HASH\e[0m"
    echo -e "place: \e[34m/nix/store\e[0m"
    if [[ -n "$PATH_TO_FILE" ]]; then
      echo -e "path: \e[34m${PATH_TO_FILE:1}\e[0m" # Remove leading slash
    else
      echo -e "path: \e[34m<root of hash>\e[0m"
    fi
  else
    echo -e "Symbolic link to: \e[34m$TARGET\e[0m"
  fi
}

# shellcheck disable=SC2120
handle_image() {
  # Image handling can be done in multiple ways

  image=${1:-$LOCATION}

  case "$FZF_PREVIEW_IMAGE_HANDLER" in
  sixel)
    chafa -f sixel -s "${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}" "$image" --animate false
    mediainfo "$image" # image related data appended after the image
    ;;
  kitty)
    kitten icat --clear --transfer-mode=memory --unicode-placeholder --stdin=no --place="${FZF_PREVIEW_COLUMNS}x$((FZF_PREVIEW_LINES - 1))@0x0" "$image" | sed '$d' | sed $'$s/$/\e[m/'
    mediainfo "$image" # image related data appended after the image
    ;;
  symbols)
    chafa -f symbols -s "${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}" "$image" --animate false
    mediainfo "$image" # image related data appended after the image
    ;;
  *)
    # Fallback for unsupported handlers
    echo "Error: Unsupported handler '$FZF_PREVIEW_IMAGE_HANDLER'. Supported handlers are 'sixel' and 'symbols'."
    return 2
    ;;
  esac
}

handle_mime() {
  # Handles file/folder type via MIME_TYPE
  case "$MIME_TYPE" in
  text/*) handle_text ;;
  application/json) bat "$LOCATION" | jq ;;
  inode/directory) eza -T -L 2 "$LOCATION" ;;
  inode/symlink) resolve_symlink ;;
  application/x-executable | application/x-pie-executable | application/x-sharedlib) readelf --wide --demangle=auto --all "$LOCATION" ;;
  application/x-x509-ca-cert) openssl x509 -text -noout -in "$LOCATION" ;;
  image/*) handle_image ;;
  video/*)
    ffmpegthumbnailer -i "$LOCATION" -o "${CACHE_FILE}.jpg" -s 1200
    handle_image "${CACHE_FILE}.jpg"
    ;;
  application/pdf)
    pdftoppm -jpeg -f 1 -singlefile "$LOCATION" "$CACHE_FILE"
    handle_image "${CACHE_FILE}.jpg"
    ;;
  *) handle_extension ;;
  esac
}

handle_extension() {
  case "$EXTENSION" in
  a | ace | alz | arc | arj | bz | bz2 | cab | cpio | deb | gz | jar | lha | lz | lzh | lzma | lzo | \
    rpm | rz | t7z | tar | tbz | tbz2 | tgz | tlz | txz | tZ | tzo | war | xpi | xz | Z | zip | rar)
    atool --list -- "$LOCATION" && exit 0
    exit 1
    ;;
  7z)
    7z l -p -- "$LOCATION" && exit 0
    exit 1
    ;;
  o) nm "$LOCATION" ;;
  iso) iso-info --no-header -l "$LOCATION" ;;
  odt | ods | odp | sxw) odt2txt "$LOCATION" ;;
  doc) catdoc "$LOCATION" ;;
  docx) docx2txt "$LOCATION" - ;;
  xls | xlsx)
    ssconvert --export-type=Gnumeric_stf:stf_csv "$LOCATION" "fd://1" | bat --language=csv
    ;;
  wav | mp3 | flac | m4a | wma | ape | ac3 | og[agx] | spx | opus | as[fx] | mka)
    exiftool "$LOCATION"
    ;;
  esac
}

handle_mime
