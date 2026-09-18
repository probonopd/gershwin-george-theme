#!/usr/bin/env python3
"""Writes GeorgeIconShapes.h: the Mac OS 8 icons as shapes.

    pip install machfs rsrcfork pillow
    python3 Tools/makeiconshapes.py "/path/to/macos8.iso"

Each colour of an icon is traced along the boundary of its pixels and then
simplified, which puts the vertices back on the straight lines the artist
drew: the result is the same picture at the size it was drawn at, and a
drawing that stays smooth at any other size.
"""

import io
import sys

import machfs
import rsrcfork
from PIL import Image

# Where the HFS volume of the install CD starts. The partition map counts in
# 512 byte blocks although the driver descriptor says 2048, so this is found
# by looking for the 'BD' of the master directory block rather than computed.
HFS_OFFSET = 0x78800
# Just over the 0.82 a two by one staircase stands off its line, and well
# under the whole pixel a real step of the drawing stands off.
FACE_EPSILON = 0.85
# A line one pixel wide would go with it, so those are kept as they are.
EDGE_EPSILON = 0.3
# Thinner than this and a shape is a line rather than a face.
THIN = 1.6
# Every piece of the drawing counts, down to the single pixels of the dither
# along its diagonals: dropping those is what thins the band along the top of
# a folder and loses the highlight on its fold.
MIN_AREA = 1.0

ICONS = [
    ("Folder", -3999, "the generic folder"),
    ("SystemFolder", -3983, "the System Folder"),
    ("ExtensionsFolder", -3950, "the Extensions folder"),
    ("ToolsFolder", -3959, "the folder of tools"),
    ("DocumentsFolder", -3975, "the Documents folder"),
    ("DownloadFolder", -3979, "the folder with the download arrow"),
    ("PictureFolder", -3946, "the folder of pictures"),
    ("SoundFolder", -3961, "the folder of sounds"),
    ("MovieFolder", -3955, "the folder of movies"),
    ("MonitorFolder", -3964, "the folder of the desktop"),
    ("UsersFolder", -3812, "the folder of users"),
    ("TrashEmpty", -3993, "the empty trash"),
    ("TrashFull", -3984, "the full trash"),
    ("Document", -4000, "the generic document"),
    ("Application", -3996, "the generic application"),
    ("Extension", -16415, "the system extension"),
    ("HardDisk", -3995, "the hard disk"),
    ("OtherDisk", -3817, "the other drive"),
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


def icon_image(fork, rid, side, palette):
    colour, mono = (b'icl8', b'ICN#') if side == 32 else (b'ics8', b'ics#')
    pixels = fork[colour][rid].data
    mask = fork[mono][rid].data[side * side // 8:]
    stride = side // 8
    img = Image.new("RGBA", (side, side), (0, 0, 0, 0))
    put = img.load()
    for y in range(side):
        for x in range(side):
            if (mask[y * stride + x // 8] >> (7 - (x % 8))) & 1:
                put[x, y] = (*palette[pixels[y * side + x]], 255)
    return img


def loops(cells):
    """The boundary loops of a set of pixels, walked along the edges between
    the pixels that are in it and the ones that are not."""
    edges = {}
    for (x, y) in cells:
        if (x, y - 1) not in cells: edges.setdefault((x, y), []).append((x + 1, y))
        if (x + 1, y) not in cells: edges.setdefault((x + 1, y), []).append((x + 1, y + 1))
        if (x, y + 1) not in cells: edges.setdefault((x + 1, y + 1), []).append((x, y + 1))
        if (x - 1, y) not in cells: edges.setdefault((x, y + 1), []).append((x, y))
    out = []
    while edges:
        start = next(iter(edges))
        loop, cur = [start], start
        while True:
            nxt = edges[cur].pop()
            if not edges[cur]:
                del edges[cur]
            loop.append(nxt)
            if nxt == start:
                break
            cur = nxt
            if cur not in edges:
                break
        out.append(loop)
    return out


def rdp(points, eps):
    if len(points) < 3:
        return points
    ax, ay = points[0]
    bx, by = points[-1]
    dx, dy = bx - ax, by - ay
    norm = (dx * dx + dy * dy) ** 0.5
    worst, idx = -1.0, 0
    for i in range(1, len(points) - 1):
        px, py = points[i]
        if norm:
            d = abs(dy * px - dx * py + bx * ay - by * ax) / norm
        else:
            d = ((px - ax) ** 2 + (py - ay) ** 2) ** 0.5
        if d > worst:
            worst, idx = d, i
    if worst > eps:
        return rdp(points[:idx + 1], eps)[:-1] + rdp(points[idx:], eps)
    return [points[0], points[-1]]


def simplify(loop, eps):
    """Puts the corners of a loop back on the lines the artist drew. At eps a
    little over 0.82 the staircase of a diagonal drawn two across and one down
    collapses onto its line, while a step of a whole pixel - a folder tab, the
    corner of a badge - is too far off to be touched."""
    pts = loop[:-1] if loop[0] == loop[-1] else list(loop)
    if len(pts) < 4:
        return list(loop)
    # start at an extreme point: the split of a closed loop pins its ends, and
    # a corner is the only place where that does no harm
    start = min(range(len(pts)), key=lambda i: (pts[i][1], pts[i][0]))
    pts = pts[start:] + pts[:start] + [pts[start]]
    return rdp(pts, eps)


def area_of(points):
    n = len(points)
    return abs(sum(points[i][0] * points[(i + 1) % n][1]
                   - points[(i + 1) % n][0] * points[i][1]
                   for i in range(n))) / 2.0


def thickness_of(loop):
    """Twice the area over the perimeter: about a pixel for a drawn line, and
    more the fatter the shape is."""
    pts = loop[:-1] if loop[0] == loop[-1] else loop
    n = len(pts)
    perimeter = sum(abs(pts[i][0] - pts[(i + 1) % n][0])
                    + abs(pts[i][1] - pts[(i + 1) % n][1]) for i in range(n))
    if not perimeter:
        return 0.0
    return 2.0 * area_of(pts) / perimeter


def components(cells):
    """The pixels of one colour, split into the pieces that touch."""
    left = set(cells)
    out = []
    while left:
        start = left.pop()
        piece = {start}
        stack = [start]
        while stack:
            x, y = stack.pop()
            for n in ((x+1, y), (x-1, y), (x, y+1), (x, y-1)):
                if n in left:
                    left.discard(n)
                    piece.add(n)
                    stack.append(n)
        out.append(piece)
    return out


def shapes_of(img):
    """One shape per piece of one colour: its outline and the loops of its
    holes, to be filled even-odd. Pieces that do not touch are kept apart, or
    a piece sitting in the hole of another would cancel it out.

    The shapes come back biggest first, so that a face is laid down before the
    lines drawn over it."""
    groups = {}
    px = img.load()
    for y in range(img.size[1]):
        for x in range(img.size[0]):
            r, g, b, a = px[x, y]
            if a:
                groups.setdefault((r, g, b), set()).add((x, y))
    out = []
    for colour, cells in groups.items():
        for piece in components(cells):
            rings = []
            for loop in loops(piece):
                fat = thickness_of(loop) >= THIN
                pts = simplify(loop, FACE_EPSILON if fat else EDGE_EPSILON)
                if pts[0] == pts[-1]:
                    pts = pts[:-1]
                if len(pts) >= 3:
                    rings.append(pts)
            if rings and area_of(rings[0]) >= MIN_AREA:
                out.append((len(piece), colour, rings))
    out.sort(key=lambda s: -s[0])
    return [(colour, rings) for _, colour, rings in out]


def main():
    iso = sys.argv[1] if len(sys.argv) > 1 else "macos8.iso"
    palette = mac_palette()
    volume = machfs.Volume()
    volume.read(open(iso, "rb").read()[HFS_OFFSET:])
    fork = rsrcfork.ResourceFile(io.BytesIO(
        volume["System Folder"]["Extensions"]["Appearance Extension"].rsrc))

    art = []
    for name, rid, note in ICONS:
        art.append((name, rid, note, 32,
                    shapes_of(icon_image(fork, rid, 32, palette))))

    colours = []
    for _, _, _, _, shapes in art:
        for colour, _ in shapes:
            if colour not in colours:
                colours.append(colour)
    colours.sort(key=lambda c: (sum(c), c))

    out = ['''/*
 * Copyright (c) 2026 Simon Peter
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

/* The Platinum icons of Mac OS 8 as shapes: every colour of the artwork
 * traced along the edge of its pixels and simplified back onto the straight
 * lines it was drawn from, so the theme draws the icons rather than showing a
 * picture of them. Generated by Tools/makeiconshapes.py.
 *
 * An icon is a run of shapes, drawn in the order they are given: a colour out
 * of GeorgeIconPalette, how many loops it has, and then each loop as its
 * number of corners followed by the corners themselves, in the square the
 * icon was drawn in, counted from its top left. The loops of a shape are
 * filled even-odd, so a loop inside another one is a hole. */

#ifndef GEORGE_ICON_SHAPES_H
#define GEORGE_ICON_SHAPES_H

#define GEORGE_ICON_END 255
''']
    out.append("/* The colours of the artwork, out of the Macintosh 256"
               " colour table. */")
    out.append("static const unsigned int GeorgeIconPalette[] = {")
    line = "  "
    for c in colours:
        entry = "0x%02X%02X%02X," % c
        if len(line) + len(entry) > 76:
            out.append(line.rstrip())
            line = "  "
        line += entry + " "
    out.append(line.rstrip().rstrip(","))
    out.append("};")
    out.append("")

    points = 0
    for name, rid, note, side, shapes in art:
        out.append("/* %s, %d */" % (note, rid))
        out.append("static const unsigned char GeorgeIcon%s[] = {" % name)
        out.append("  %d, /* the square it is drawn in */" % side)
        for colour, rings in shapes:
            out.append("  %d, %d," % (colours.index(colour), len(rings)))
            for pts in rings:
                points += len(pts)
                line = "    %d," % len(pts)
                for (x, y) in pts:
                    piece = " %d,%d," % (x, y)
                    if len(line) + len(piece) > 76:
                        out.append(line)
                        line = "     "
                    line += piece
                out.append(line.rstrip())
        out.append("  GEORGE_ICON_END")
        out.append("};")
        out.append("")
    out.append("#endif /* GEORGE_ICON_SHAPES_H */")
    open("GeorgeIconShapes.h", "w").write("\n".join(out) + "\n")
    print("wrote GeorgeIconShapes.h: %d icons, %d colours, %d shapes, %d corners"
          % (len(art), len(colours),
             sum(len(s) for _, _, _, _, s in art), points))


main()
