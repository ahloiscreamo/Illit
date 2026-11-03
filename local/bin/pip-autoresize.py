#!/usr/bin/env python3
import time
import i3ipc

processed_ids = set()


def handle(i3, e):
    c = e.container
    if c.name != "Picture in picture" or c.id in processed_ids:
        return
    processed_ids.add(c.id)

    # Float first so the window takes its natural (video) size instead of a tile size
    i3.command(f"[con_id={c.id}] floating enable")

    # Let the client commit its real size, then read it
    time.sleep(0.15)
    con = i3.get_tree().find_by_id(c.id)
    if not con:
        return

    if con.rect.height > con.rect.width:
        i3.command(f"[con_id={c.id}] resize set width 540 px height 960 px")
    else:
        i3.command(f"[con_id={c.id}] resize set width 1280 px height 720 px")

    i3.command(f"[con_id={c.id}] move position center")


def main():
    i3 = i3ipc.Connection()
    i3.on("window::new", handle)
    i3.on("window::title", handle)
    i3.main()


if __name__ == "__main__":
    main()
