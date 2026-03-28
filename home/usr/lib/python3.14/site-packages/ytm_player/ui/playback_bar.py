"""the playback bar and footer you always see."""

from __future__ import annotations

import logging

from rich.text import Text
from textual.app import ComposeResult
from textual.containers import Horizontal, Vertical
from textual.events import Click, MouseScrollDown, MouseScrollUp
from textual.message import Message
from textual.reactive import reactive
from textual.widget import Widget

from ytm_player.services.queue import RepeatMode
from ytm_player.ui.theme import get_theme
from ytm_player.ui.widgets.album_art import AlbumArt
from ytm_player.ui.widgets.progress_bar import PlaybackProgress
from ytm_player.utils.formatting import extract_artist, truncate

logger = logging.getLogger(__name__)

# icons for playback
_ICON_PLAYING = "\u25b6"
_ICON_PAUSED = "\u23f8"
_ICON_STOPPED = "\u25a0"

_ICON_VOLUME = "\U0001f50a"

_ICON_REPEAT_OFF = "\U0001f501"
_ICON_REPEAT_ALL = "\U0001f501"
_ICON_REPEAT_ONE = "\U0001f502"

_ICON_SHUFFLE_OFF = "\U0001f500"
_ICON_SHUFFLE_ON = "\U0001f500"


# --- track info widget ---


class _TrackInfo(Widget):
    """shows the title, artist, and album in one line"""

    DEFAULT_CSS = """
    _TrackInfo {
        height: 1;
        width: 1fr;
    }
    """

    title: reactive[str] = reactive("")
    artist: reactive[str] = reactive("")
    album: reactive[str] = reactive("")
    is_playing: reactive[bool] = reactive(False)
    is_paused: reactive[bool] = reactive(False)

    def render(self) -> Text:
        theme = get_theme()
        result = Text()

        # the play/pause icon
        if self.is_playing and not self.is_paused:
            result.append(f" {_ICON_PLAYING} ", style=f"bold {theme.primary}")
        elif self.is_paused:
            result.append(f" {_ICON_PAUSED} ", style=f"bold {theme.warning}")
        else:
            result.append(f" {_ICON_STOPPED} ", style=theme.muted_text)

        if self.title:
            max_w = max(10, self.size.width - 30)
            title_w = min(len(self.title), max_w // 2)
            artist_w = min(len(self.artist), max_w // 3)
            album_w = max_w - title_w - artist_w - 8

            # isolate track info for right-to-left text
            result.append("\u2066")
            result.append(truncate(self.title, title_w), style=f"bold {theme.foreground}")
            if self.artist:
                result.append(" \u2014 ", style=theme.muted_text)
                result.append(truncate(self.artist, artist_w), style=theme.secondary)
            if self.album:
                result.append(" \u2014 ", style=theme.muted_text)
                result.append(truncate(str(self.album or ""), max(0, album_w)), style=theme.muted_text)
            result.append("\u2069")
        else:
            result.append("No track playing", style=theme.muted_text)

        return result


# --- control widgets ---


class _VolumeDisplay(Widget):
    """shows volume, scroll to change it"""

    DEFAULT_CSS = """
    _VolumeDisplay {
        height: 1;
        width: auto;
        min-width: 9;
    }
    """

    volume: reactive[int] = reactive(80)

    def render(self) -> Text:
        return Text(f" {_ICON_VOLUME} {self.volume:>3}%", style=get_theme().secondary)

    async def on_mouse_scroll_up(self, event: MouseScrollUp) -> None:
        event.stop()
        app = self.app
        if hasattr(app, "player") and app.player:
            await app.player.change_volume(5)

    async def on_mouse_scroll_down(self, event: MouseScrollDown) -> None:
        event.stop()
        app = self.app
        if hasattr(app, "player") and app.player:
            await app.player.change_volume(-5)


class _RepeatButton(Widget):
    """click to change repeat mode"""

    DEFAULT_CSS = """
    _RepeatButton {
        height: 1;
        width: auto;
        min-width: 7;
        padding: 0 1;
    }
    _RepeatButton:hover {
        background: $border;
    }
    """

    repeat_mode: reactive[str] = reactive("off")

    def render(self) -> Text:
        theme = get_theme()
        if self.repeat_mode == "all":
            return Text(f"{_ICON_REPEAT_ALL} all", style=f"bold {theme.success}")
        elif self.repeat_mode == "one":
            return Text(f"{_ICON_REPEAT_ONE} one", style=f"bold {theme.warning}")
        return Text(f"{_ICON_REPEAT_OFF} off", style=theme.muted_text)

    async def on_click(self, event: Click) -> None:
        event.stop()
        app = self.app
        if hasattr(app, "queue"):
            mode = app.queue.cycle_repeat()
            try:
                bar = app.query_one("#playback-bar", PlaybackBar)
                bar.update_repeat(mode)
                app.notify(f"Repeat: {mode.value}", timeout=2)
            except Exception:
                logger.debug("Failed to update repeat mode display on click", exc_info=True)


class _ShuffleButton(Widget):
    """click to toggle shuffle"""

    DEFAULT_CSS = """
    _ShuffleButton {
        height: 1;
        width: auto;
        min-width: 7;
        padding: 0 1;
    }
    _ShuffleButton:hover {
        background: $border;
    }
    """

    shuffle_on: reactive[bool] = reactive(False)

    def render(self) -> Text:
        theme = get_theme()
        if self.shuffle_on:
            return Text(f"{_ICON_SHUFFLE_ON} on ", style=f"bold {theme.success}")
        return Text(f"{_ICON_SHUFFLE_OFF} off", style=theme.muted_text)

    async def on_click(self, event: Click) -> None:
        event.stop()
        app = self.app
        if hasattr(app, "queue"):
            app.queue.toggle_shuffle()
            enabled = app.queue.shuffle_enabled
            try:
                bar = app.query_one("#playback-bar", PlaybackBar)
                bar.update_shuffle(enabled)
                state = "on" if enabled else "off"
                app.notify(f"Shuffle: {state}", timeout=2)
            except Exception:
                logger.debug("Failed to update shuffle state display on click", exc_info=True)


# --- the main playback bar ---


class PlaybackBar(Widget):
    """the bar at the bottom with track info and progress"""

    class TrackRightClicked(Message):
        """when you right-click the bar"""

        def __init__(self, track: dict) -> None:
            super().__init__()
            self.track = track

    DEFAULT_CSS = """
    PlaybackBar {
        dock: bottom;
        height: 4;
        background: $playback-bar-bg;
        border-top: solid $border;
    }
    PlaybackBar #pb-outer {
        height: 100%;
        width: 1fr;
    }
    PlaybackBar #pb-art {
        width: 10;
        height: 3;
        margin: 0 1 0 0;
    }
    PlaybackBar #pb-content {
        width: 1fr;
        height: auto;
    }
    PlaybackBar #pb-top-row {
        height: 1;
        width: 1fr;
    }
    PlaybackBar #pb-bottom-row {
        height: 1;
        width: 1fr;
    }
    PlaybackBar #pb-track-info {
        width: 1fr;
    }
    PlaybackBar #pb-progress {
        width: 1fr;
    }
    """

    def compose(self) -> ComposeResult:
        with Horizontal(id="pb-outer"):
            yield AlbumArt(id="pb-art")
            with Vertical(id="pb-content"):
                with Horizontal(id="pb-top-row"):
                    yield _TrackInfo(id="pb-track-info")
                    yield _VolumeDisplay(id="pb-volume")
                    yield _RepeatButton(id="pb-repeat")
                    yield _ShuffleButton(id="pb-shuffle")
                with Horizontal(id="pb-bottom-row"):
                    _t = get_theme()
                    yield PlaybackProgress(
                        bar_style="block",
                        filled_color=_t.progress_filled,
                        empty_color=_t.progress_empty,
                        time_color=_t.secondary,
                        id="pb-progress",
                    )

    def on_click(self, event: Click) -> None:
        """right-clicking opens the menu"""
        if event.button != 3:
            return
        app = self.app
        track = None
        if hasattr(app, "player") and app.player and app.player.current_track:
            track = app.player.current_track
        elif hasattr(app, "queue") and app.queue.current_track:
            track = app.queue.current_track
        if track:
            self.post_message(self.TrackRightClicked(track))

    # --- update methods ---

    def update_track(self, track: dict | None) -> None:
        """update the track info"""
        info = self.query_one("#pb-track-info", _TrackInfo)
        art = self.query_one("#pb-art", AlbumArt)

        if track is None:
            info.title = ""
            info.artist = ""
            info.album = ""
            info.is_playing = False
            info.is_paused = False
            art.clear_track()
            return

        info.title = track.get("title", "")
        info.artist = extract_artist(track)
        info.album = str(track.get("album") or "")
        art.set_track(track.get("thumbnail_url", ""))

    def update_playback_state(self, *, is_playing: bool, is_paused: bool) -> None:
        """update play/pause icons"""
        info = self.query_one("#pb-track-info", _TrackInfo)
        info.is_playing = is_playing
        info.is_paused = is_paused

    def update_position(self, position: float, duration: float | None = None) -> None:
        """update where we are in the song"""
        progress = self.query_one("#pb-progress", PlaybackProgress)
        progress.update_position(position, duration)

    def update_volume(self, volume: int) -> None:
        """update the volume number"""
        vol = self.query_one("#pb-volume", _VolumeDisplay)
        vol.volume = volume

    def update_repeat(self, mode: RepeatMode) -> None:
        """update the repeat icon"""
        rep = self.query_one("#pb-repeat", _RepeatButton)
        rep.repeat_mode = mode.value

    def update_shuffle(self, enabled: bool) -> None:
        """update the shuffle icon"""
        shuf = self.query_one("#pb-shuffle", _ShuffleButton)
        shuf.shuffle_on = enabled


# --- the footer bar ---


class _FooterButton(Widget):
    """a simple footer button"""

    DEFAULT_CSS = """
    _FooterButton {
        height: 1;
        width: auto;
        padding: 0 1;
    }
    _FooterButton:hover {
        background: $border;
    }
    """

    is_active: reactive[bool] = reactive(False)
    is_dimmed: reactive[bool] = reactive(False)

    def __init__(self, label: str, action: str, **kwargs: object) -> None:
        super().__init__(**kwargs)
        self._label = label
        self._action = action

    def render(self) -> Text:
        theme = get_theme()
        if self.is_active:
            return Text(self._label, style=f"bold {theme.primary}")
        if self.is_dimmed:
            return Text(self._label, style="dim")
        return Text(self._label, style=theme.muted_text)

    async def on_click(self, event: Click) -> None:
        event.stop()
        app = self.app
        match self._action:
            case (
                "help"
                | "library"
                | "search"
                | "queue"
                | "browse"
                | "liked_songs"
                | "recently_played"
            ):
                await app.navigate_to(self._action)  # type: ignore[attr-defined]
            case "play_pause":
                if hasattr(app, "_toggle_play_pause"):
                    await app._toggle_play_pause()
            case "prev":
                await app._play_previous()  # type: ignore[attr-defined]
            case "next":
                await app._play_next()  # type: ignore[attr-defined]
            case "spotify_import":
                from ytm_player.ui.popups.spotify_import import SpotifyImportPopup

                app.push_screen(SpotifyImportPopup())


class FooterBar(Widget):
    """the footer with all the links"""

    DEFAULT_CSS = """
    FooterBar {
        dock: bottom;
        height: 1;
        background: $background;
    }
    FooterBar #footer-inner {
        height: 1;
        width: 1fr;
    }
    FooterBar #footer-help {
        dock: right;
    }
    """

    # nav links
    _PAGE_ACTIONS = {
        "library",
        "search",
        "browse",
        "queue",
        "help",
    }

    def compose(self) -> ComposeResult:
        with Horizontal(id="footer-inner"):
            # Playback controls (icon-only).
            yield _FooterButton("\u23ee", "prev")
            yield _FooterButton("\u23ef", "play_pause")
            yield _FooterButton("\u23ed", "next")
            # Page navigation.
            yield _FooterButton("Library", "library", id="footer-library")
            yield _FooterButton("Search", "search", id="footer-search")
            yield _FooterButton("Browse", "browse", id="footer-browse")
            yield _FooterButton("Queue", "queue", id="footer-queue")
            # spotify stuff
            yield _FooterButton("Import", "spotify_import")
            # help button
            yield _FooterButton("?", "help", id="footer-help")

    def set_active_page(self, page_name: str) -> None:
        """highlight whichever page we're on"""
        for action in self._PAGE_ACTIONS:
            try:
                btn = self.query_one(f"#footer-{action}", _FooterButton)
                btn.is_active = action == page_name
            except Exception:
                logger.debug(
                    "Failed to update footer button for action '%s'", action, exc_info=True
                )
