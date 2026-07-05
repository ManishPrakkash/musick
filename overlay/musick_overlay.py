#!/usr/bin/env python3
import os

# GNOME Wayland strictly prohibits window positioning. We must force X11 (XWayland) 
# so the widget can position itself at the bottom-left correctly.
if os.environ.get("XDG_SESSION_TYPE") == "wayland":
    desktop = os.environ.get("XDG_CURRENT_DESKTOP", "").lower()
    if "gnome" in desktop or "ubuntu" in desktop:
        os.environ["GDK_BACKEND"] = "x11"

import gi
gi.require_version("Gtk", "3.0")
try:
    gi.require_version("GtkLayerShell", "0.1")
    from gi.repository import GtkLayerShell
    HAS_LAYER_SHELL = True
except ValueError:
    HAS_LAYER_SHELL = False
from gi.repository import Gtk, Gdk, GLib, GdkPixbuf, Pango

CACHE_DIR=os.path.expanduser("~/.cache/musick")
STATE_FILE=os.path.join(CACHE_DIR,"state")
INFO_FILE=os.path.join(CACHE_DIR,"info")
COVER_FILE=os.path.join(CACHE_DIR,"cover.jpg")
TRACK_FILE=os.path.join(CACHE_DIR,"track_id")
CONFIG_FILE=os.path.expanduser("~/.config/musick/musick.conf")

DEFAULTS={"margin_left":"58","margin_bottom":"62","cover_size":"112","title_font_size":"24","artist_font_size":"17","title_max_chars":"36","artist_max_chars":"36","title_opacity":"0.95","artist_opacity":"0.68","refresh_ms":"500"}

def read_file(path):
    try:
        with open(path,"r",encoding="utf-8") as f: return f.read().strip()
    except Exception: return ""

def read_info():
    try:
        with open(INFO_FILE,"r",encoding="utf-8") as f: lines=f.read().splitlines()
        return (lines[0] if len(lines)>0 else "", lines[1] if len(lines)>1 else "", lines[2] if len(lines)>2 else "")
    except Exception:
        return "","",""

def load_config():
    cfg=DEFAULTS.copy()
    if os.path.exists(CONFIG_FILE):
        try:
            with open(CONFIG_FILE,"r",encoding="utf-8") as f:
                for raw in f:
                    line=raw.strip()
                    if not line or line.startswith("#") or "=" not in line: continue
                    k,v=line.split("=",1); cfg[k.strip()]=v.strip()
        except Exception:
            pass
    return cfg

class MusicOverlay(Gtk.Window):
    def __init__(self):
        super().__init__(type=Gtk.WindowType.TOPLEVEL)
        self.cfg=load_config()
        self.margin_left=int(self.cfg["margin_left"]); self.margin_bottom=int(self.cfg["margin_bottom"])
        self.cover_size=int(self.cfg["cover_size"]); self.title_font_size=int(self.cfg["title_font_size"]); self.artist_font_size=int(self.cfg["artist_font_size"])
        self.title_max_chars=int(self.cfg["title_max_chars"]); self.artist_max_chars=int(self.cfg["artist_max_chars"])
        self.title_opacity=float(self.cfg["title_opacity"]); self.artist_opacity=float(self.cfg["artist_opacity"]); self.refresh_ms=int(self.cfg["refresh_ms"])
        self.set_name("musick-overlay"); self.set_decorated(False); self.set_resizable(False); self.set_app_paintable(True)
        self.set_skip_taskbar_hint(True); self.set_skip_pager_hint(True); self.stick()
        screen=self.get_screen(); visual=screen.get_rgba_visual()
        if visual and screen.is_composited(): self.set_visual(visual)
        if HAS_LAYER_SHELL and GtkLayerShell.is_supported():
            GtkLayerShell.init_for_window(self)
            GtkLayerShell.set_layer(self, GtkLayerShell.Layer.BACKGROUND)
            GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.LEFT, True)
            GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.BOTTOM, True)
            GtkLayerShell.set_margin(self, GtkLayerShell.Edge.LEFT, self.margin_left)
            GtkLayerShell.set_margin(self, GtkLayerShell.Edge.BOTTOM, self.margin_bottom)
            GtkLayerShell.set_namespace(self, "musick-overlay")
            GtkLayerShell.set_exclusive_zone(self, 0)
        else:
            self.set_type_hint(Gdk.WindowTypeHint.DOCK)
            self.set_keep_below(True)
            self.set_gravity(Gdk.Gravity.SOUTH_WEST)
            self.set_position(Gtk.WindowPosition.NONE)
            self.connect("size-allocate", self.on_size_allocate)
        self.last_title=""; self.last_artist=""; self.last_track_id=""; self.cover_loaded=False
        self.build_ui(); self.apply_css()
        GLib.timeout_add(self.refresh_ms, self.refresh); self.refresh()

    def on_size_allocate(self, widget, allocation):
        display = Gdk.Display.get_default()
        monitor = display.get_primary_monitor()
        if monitor:
            geom = monitor.get_geometry()
            x = geom.x + self.margin_left
            y = geom.y + geom.height - allocation.height - self.margin_bottom
            self.move(x, y)

    def build_ui(self):
        self.outer=Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=22); self.outer.set_name("music-card")
        self.cover=Gtk.Image(); self.cover.set_pixel_size(self.cover_size)
        self.cover.set_size_request(self.cover_size, self.cover_size)
        self.cover.set_halign(Gtk.Align.CENTER); self.cover.set_valign(Gtk.Align.CENTER)
        self.text_box=Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6); self.text_box.set_valign(Gtk.Align.CENTER)
        self.title=Gtk.Label(label=""); self.title.set_xalign(0); self.title.set_name("music-title"); self.title.set_max_width_chars(self.title_max_chars); self.title.set_ellipsize(Pango.EllipsizeMode.END)
        self.artist=Gtk.Label(label=""); self.artist.set_xalign(0); self.artist.set_name("music-artist"); self.artist.set_max_width_chars(self.artist_max_chars); self.artist.set_ellipsize(Pango.EllipsizeMode.END)
        self.text_box.pack_start(self.title, False, False, 0); self.text_box.pack_start(self.artist, False, False, 0)
        self.outer.pack_start(self.cover, False, False, 0); self.outer.pack_start(self.text_box, True, True, 0); self.add(self.outer)

    def apply_css(self):
        css = f"""
#musick-overlay {{
  background: transparent;
}}
#music-card {{
  background: transparent;
  border: none;
  box-shadow: none;
}}
#music-title {{
  color: rgba(255,255,255,{self.title_opacity});
  font-size: {self.title_font_size}px;
  font-weight: 700;
}}
#music-artist {{
  color: rgba(255,255,255,{self.artist_opacity});
  font-size: {self.artist_font_size}px;
  font-weight: 500;
}}
""".encode("utf-8")
        provider=Gtk.CssProvider(); provider.load_from_data(css)
        Gtk.StyleContext.add_provider_for_screen(Gdk.Screen.get_default(), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)

    def clear_cover(self):
        self.cover.clear(); self.cover_loaded=False

    def load_cover(self):
        if not os.path.exists(COVER_FILE):
            self.clear_cover(); return
        try:
            pixbuf=GdkPixbuf.Pixbuf.new_from_file_at_scale(COVER_FILE, self.cover_size, self.cover_size, True)
            self.cover.set_from_pixbuf(pixbuf); self.cover.show(); self.cover.queue_draw(); self.queue_draw(); self.cover_loaded=True
        except Exception as e:
            try:
                with open(os.path.join(CACHE_DIR, "error.log"), "a", encoding="utf-8") as f: f.write(f"Load error: {e}\n")
            except: pass
            self.clear_cover()

    def refresh(self):
        state=read_file(STATE_FILE)
        if state!="show":
            self.hide(); self.clear_cover(); self.last_track_id=""; return True
        title,artist,_=read_info(); track_id=read_file(TRACK_FILE)
        if not title:
            self.hide(); self.clear_cover(); self.last_track_id=""; return True
        if title!=self.last_title: self.title.set_text(title); self.last_title=title
        if artist!=self.last_artist: self.artist.set_text(artist if artist else "Unknown Artist"); self.last_artist=artist
        if track_id and track_id!=self.last_track_id:
            self.last_track_id=track_id; self.load_cover()
        elif not self.cover_loaded and os.path.exists(COVER_FILE):
            self.load_cover()
        self.show_all(); return True

def main():
    win=MusicOverlay(); win.connect("destroy", Gtk.main_quit); Gtk.main()

if __name__=="__main__":
    main()
