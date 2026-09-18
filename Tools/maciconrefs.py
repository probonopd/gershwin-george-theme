#!/usr/bin/env python3
"""Writes PNGs of the Mac OS 8 icons, to draw the theme's own icons from.

    pip install machfs rsrcfork pillow
    python3 Tools/maciconrefs.py "/path/to/macos8.iso" [outdir]

The icons are the 32x32 colour icons (icl8 with their ICN# mask) of the
Appearance Extension, which is where Mac OS 8 keeps the Platinum artwork.
They are reference only: George draws its icons as shapes in George+Icons.m,
and these PNGs are what those shapes were measured against.
"""

import io
import os
import sys

import machfs
import rsrcfork
from PIL import Image

# Where the HFS volume of the install CD starts. The partition map counts in
# 512 byte blocks although the driver descriptor says 2048, so this is found
# by looking for the 'BD' of the master directory block rather than computed.
HFS_OFFSET = 0x78800

ICONS = [
    ("Folder", -3999), ("SystemFolder", -3983), ("ExtensionsFolder", -3950),
    ("ToolsFolder", -3959), ("DocumentsFolder", -3975),
    ("DownloadFolder", -3979), ("PictureFolder", -3946),
    ("SoundFolder", -3961), ("MovieFolder", -3955), ("MonitorFolder", -3964),
    ("UsersFolder", -3812), ("TrashEmpty", -3993), ("TrashFull", -3984),
    ("Document", -4000), ("Application", -3996), ("Extension", -16415),
    ("HardDisk", -3995), ("OtherDisk", -3817),
]


def mac_palette():
    """The Macintosh 256 colour table: the cube without black, the four
    ramps, then black."""
    levels = [255, 204, 153, 102, 51, 0]
    pal = [(r, g, b) for r in levels for g in levels for b in levels][:215]
    ramp = [238, 221, 187, 170, 136, 119, 85, 68, 34, 17]
    for v in ramp: pal.append((v, 0, 0))
    for v in ramp: pal.append((0, v, 0))
    for v in ramp: pal.append((0, 0, v))
    for v in ramp: pal.append((v, v, v))
    pal.append((0, 0, 0))
    return pal


def main():
    iso = sys.argv[1] if len(sys.argv) > 1 else "macos8.iso"
    out = sys.argv[2] if len(sys.argv) > 2 else "."
    palette = mac_palette()

    volume = machfs.Volume()
    volume.read(open(iso, "rb").read()[HFS_OFFSET:])
    fork = rsrcfork.ResourceFile(io.BytesIO(
        volume["System Folder"]["Extensions"]["Appearance Extension"].rsrc))

    os.makedirs(out, exist_ok=True)
    for name, rid in ICONS:
        pixels = fork[b'icl8'][rid].data
        # the second half of the ICN# is the mask, the first half the 1 bit icon
        mask = fork[b'ICN#'][rid].data[128:]
        image = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
        put = image.load()
        for y in range(32):
            for x in range(32):
                if (mask[y * 4 + x // 8] >> (7 - (x % 8))) & 1:
                    put[x, y] = (*palette[pixels[y * 32 + x]], 255)
        image.save(os.path.join(out, "ref_%s.png" % name))
    print("wrote %d reference icons to %s" % (len(ICONS), out))


main()
