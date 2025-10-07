#!/usr/bin/env python3
import os, sys, subprocess, shutil, glob, mutagen, json, tempfile, time
from mutagen.flac import FLAC
from mutagen.mp3 import MP3
from mutagen.id3 import ID3

MPD_MUSIC_DIR = "/mnt/Kingston/Music"
FALLBACK = os.path.expanduser("~/.config/kunst_kitty/fallback.png")
TMP = "/tmp/kunst_cover.jpg"

def get_current_song():
    try:
        rel = subprocess.check_output(
            ["mpc", "--format", "%file%", "current"],
            text=True, stderr=subprocess.DEVNULL
        ).strip()
        return os.path.join(MPD_MUSIC_DIR, rel) if rel else None
    except subprocess.CalledProcessError:
        return None

def extract_cover(song):
    if not song or not os.path.isfile(song):
        return FALLBACK
    try:
        audio = mutagen.File(song)
        if isinstance(audio, FLAC) and audio.pictures:
            with open(TMP, "wb") as f:
                f.write(audio.pictures[0].data)
            return TMP
        if isinstance(audio, MP3):
            tags = ID3(song)
            for tag in tags.values():
                if tag.FrameID == "APIC":
                    with open(TMP, "wb") as f:
                        f.write(tag.data)
                    return TMP
    except Exception:
        pass

    folder = os.path.dirname(song)
    for ext in ("*.jpg", "*.png", "*.jpeg"):
        matches = glob.glob(os.path.join(folder, ext))
        if matches:
            return matches[0]
    return FALLBACK

def show_cover(proc, path):
    cols, rows = shutil.get_terminal_size(fallback=(80, 24))
    data = {
        "action": "add",
        "identifier": "cover",
        "x": 0,
        "y": 0,
        "max_width": cols,
        "max_height": rows,
        "path": path,
        "scaler": "fit_contain"
    }
    proc.stdin.write(json.dumps(data) + "\n")
    proc.stdin.flush()

def clear_cover(proc):
    data = {"action": "remove", "identifier": "cover"}
    proc.stdin.write(json.dumps(data) + "\n")
    proc.stdin.flush()

def main():
    print("kunst_ueberzug — running (Ctrl+C to quit)")
    last = None

    # Start ueberzug layer in background
    proc = subprocess.Popen(
        ["ueberzug", "layer", "--silent"],
        stdin=subprocess.PIPE, text=True
    )

    try:
        while True:
            song = get_current_song()
            if song and song != last:
                cover = extract_cover(song)
                clear_cover(proc)
                show_cover(proc, cover)
                last = song
            subprocess.run(["mpc", "idle", "player"], stdout=subprocess.DEVNULL)
    except KeyboardInterrupt:
        clear_cover(proc)
        proc.terminate()
        pass

if __name__ == "__main__":
    main()
