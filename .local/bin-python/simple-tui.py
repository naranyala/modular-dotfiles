#!/usr/bin/env python3
"""
menu.py – simple ncurses menu in Python

* Disk Usage  -> runs `df -h`
* Processes   -> runs `htop`
* Exit        -> leaves the program
"""

import curses
import subprocess
import sys
from typing import List

def draw_menu(stdscr: "curses._CursesWindow", highlight: int, options: List[str]) -> None:
    """Erase the screen and redraw the options, highlighting the selected one."""
    stdscr.clear()
    h, w = stdscr.getmaxyx()

    for idx, text in enumerate(options):
        x = 2                     # column where the text starts
        y = idx + 2               # start a couple of rows down for a nicer look

        # Highlight the current selection
        if idx == highlight:
            stdscr.attron(curses.A_REVERSE)
            stdscr.addstr(y, x, text)
            stdscr.attroff(curses.A_REVERSE)
        else:
            stdscr.addstr(y, x, text)

    # Optional: show a short instruction line at the bottom
    stdscr.attron(curses.A_DIM)
    stdscr.addstr(h - 2, 2, "Use ↑/↓ to move – ENTER to select")
    stdscr.attroff(curses.A_DIM)

    stdscr.refresh()


def run_external(cmd: List[str]) -> None:
    """
    Run an external command while temporarily restoring the terminal
    to its normal state (so tools like `htop` can take over the screen).

    After the command finishes we re‑enter curses mode.
    """
    # Leave curses mode – this puts the terminal back in the state the
    # child process expects (echo enabled, line buffering, etc.).
    curses.endwin()

    # Execute the external program.  Using a list avoids shell quoting issues.
    try:
        subprocess.run(cmd, check=False)  # `htop` will run interactively
    except FileNotFoundError:
        print(f"Command not found: {cmd[0]}", file=sys.stderr)
        input("Press ENTER to continue...")  # pause so the user can see the error
    finally:
        # Re‑initialise curses so we can continue drawing the menu.
        # The wrapper that called `main()` will have already created the
        # stdscr window; we just need to restore the common settings.
        stdscr = curses.initscr()
        curses.cbreak()
        curses.noecho()
        stdscr.keypad(True)
        curses.curs_set(0)   # hide the cursor again


def main(stdscr: "curses._CursesWindow") -> None:
    """Main loop – show menu, handle navigation, launch commands."""
    # Basic curses setup
    curses.curs_set(0)          # hide the cursor
    stdscr.keypad(True)         # translate special keys (arrows, etc.)
    curses.noecho()
    curses.cbreak()

    options = ["Disk Usage", "Processes", "Exit"]
    highlight = 0               # index of the currently highlighted entry

    while True:
        draw_menu(stdscr, highlight, options)
        key = stdscr.getch()

        # Navigation
        if key == curses.KEY_UP and highlight > 0:
            highlight -= 1
        elif key == curses.KEY_DOWN and highlight < len(options) - 1:
            highlight += 1
        # Selection – accept both the Enter key and its carriage‑return variant
        elif key in (curses.KEY_ENTER, ord('\n'), ord('\r')):
            if highlight == 0:           # Disk Usage
                run_external(["df", "-h"])
            elif highlight == 1:         # Processes
                run_external(["htop"])
            elif highlight == 2:         # Exit
                break
        # Optional: allow quitting with the ESC key
        elif key == 27:  # ESC
            break

    # Clean shutdown – curses.wrapper will also call `curses.endwin()` for us,
    # but calling it explicitly does no harm.
    curses.endwin()


if __name__ == "__main__":
    # `curses.wrapper` takes care of initialising curses, calling `main`,
    # and restoring the terminal even if an exception occurs.
    curses.wrapper(main)
