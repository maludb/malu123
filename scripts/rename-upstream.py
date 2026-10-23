#!/usr/bin/env python3
"""Text part of the GridCraft -> Malu123 rename (see rename-upstream.sh).

Usage: rename-upstream.py [--list] FILE...     rewrites the files in place; --list prints the mapping.

The mapping is ordered: specific tokens first, then the generic case variants. A few phrases that
credit upstream are protected so they survive the generic rules. Idempotent: running it twice
changes nothing.
"""
import sys

# Phrases kept verbatim (they credit upstream or point at upstream resources).
PROTECT = [
    "storytold_gridcraft",
    "GridCraft contributors",
    "GridCraft authors",
    "upstream GridCraft",
    "fork of GridCraft",
    "forked from GridCraft",
    "credit the upstream",
    "GridCraft name",
    "GridCraft is copyright",
    "like GridCraft",
    # upstream issue, PR, release and file links stay upstream's; the bare repo path becomes ours
    "storytold/gridcraft#",
    "storytold/gridcraft/issues/",
    "storytold/gridcraft/pull/",
    "storytold/gridcraft/releases",
    "storytold/gridcraft/blob/",
    "storytold/gridcraft/tree/",
    "storytold/gridcraft/commit",
    '"repo": "storytold/gridcraft"',
]

# Ordered replacements. Earlier entries win where they overlap with later ones.
MAP = [
    # identity strings that are not a plain word swap
    ("ai.storyteller.gridcraft", "org.maluos.malu123"),
    ("GridCraft on getartcraft.com", "Malu123 on GitHub"),
    ("getartcraft.com/apps/gridcraft", "github.com/maludb/malu123"),
    ("https://getartcraft.com/apps", "https://github.com/maludb"),
    ("https://getartcraft.com/", "https://maluos.com/"),
    ("Learning Machines LLC", "MaluOS"),
    ("storytold/gridcraft", "maludb/malu123"),
    ("Library/Application Support/GridCraft", "Library/Application Support/Malu123"),
    # the generic case variants
    ("GRIDCRAFT", "MALU123"),
    ("GridCraft", "Malu123"),
    ("Gridcraft", "Malu123"),
    ("gridcraft", "malu123"),
]


def rewrite(text: str) -> str:
    holes = {}
    for i, p in enumerate(PROTECT):
        key = f"\x00P{i}\x00"
        if p in text:
            text = text.replace(p, key)
            holes[key] = p
    for old, new in MAP:
        text = text.replace(old, new)
    for key, p in holes.items():
        text = text.replace(key, p)
    return text


def main(argv):
    if argv and argv[0] == "--list":
        for old, new in MAP:
            print(f"{old} -> {new}")
        return 0
    changed = 0
    for path in argv:
        try:
            raw = open(path, "rb").read()
            text = raw.decode("utf-8")
        except (OSError, UnicodeDecodeError):
            continue
        out = rewrite(text)
        if out != text:
            open(path, "wb").write(out.encode("utf-8"))
            changed += 1
    print(f"rename-upstream.py: {changed} file(s) rewritten")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
