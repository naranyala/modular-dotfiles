#!/usr/bin/env python3
import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk

class HelloPlugin(Gtk.Label):
    def __init__(self):
        super().__init__(label="Hello XFCE!")

if __name__ == "__main__":
    win = Gtk.Window()
    win.add(HelloPlugin())
    win.show_all()
    Gtk.main()

