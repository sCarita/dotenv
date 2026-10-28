#!/usr/bin/env python3
"""Read one keypress locally so terminal key encodings can be diagnosed."""
import os
import select
import sys
import termios
import tty

if not sys.stdin.isatty():
    raise SystemExit("Run this directly in an interactive terminal.")

print("Press Shift+Enter once (or Ctrl+C to cancel). No input is saved.", flush=True)
fd = sys.stdin.fileno()
previous = termios.tcgetattr(fd)
try:
    tty.setraw(fd)
    captured = os.read(fd, 32)
    while select.select([fd], [], [], 0.1)[0]:
        captured += os.read(fd, 32)
finally:
    termios.tcsetattr(fd, termios.TCSADRAIN, previous)

if captured == b"\x03":
    raise SystemExit("\nCancelled.")

print("\nKey bytes:", repr(captured))
print("Hex:", captured.hex(" "))
