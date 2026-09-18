# George Theme

George is a GNUstep theme in the Mac OS 8 Platinum look, as Greg Landweber's
Aaron extension drew it: gray window frames with embossed title bars, square
widgets with cut corners, sunken wells for anything that holds content, and
the Chicago UI font.

Every part is drawn in code. Aaron's own resources were used as a reference
only; none of its artwork is shipped here.

## Installation

1. Build the theme bundle:
   ```bash
   gmake
   ```
2. Install it (to the SYSTEM domain, which is where the GNUmakefile points):
   ```bash
   sudo -E gmake install
   ```
   The theme lands in `$(GNUSTEP_LIBRARY)/Themes/George.theme`, and its three
   UI faces in `/System/Library/Fonts/ChicagoKare`, `.../Geneva92` and
   `.../Monaco9` so that fontconfig finds them.
3. Select it:
   ```bash
   defaults write NSGlobalDomain GSTheme George
   ```
   Log out and back in so the WindowManager picks it up as well.

## Accent color

The accent color follows Aaron's color schemes and is chosen with a default:

```bash
defaults write NSGlobalDomain GeorgeColor emerald
```

Available schemes are `lavender` (the default), `gold`, `emerald`,
`turquoise`, `crimson`, `magenta`, `sapphire` and `silver`. The scheme is read
once per process, so applications pick a new one up when they restart.

## What is where

| File | What it draws |
| --- | --- |
| `GeorgePlatinum.m` | Pixel fill helper, gray levels, the eight color schemes |
| `George.m` | Every GSTheme hook, routed to a Platinum part |
| `George+Parts.m` | Push buttons, checkboxes, radio buttons, scroll bar parts, wells, panels, grooves, slider knobs, the grow box, the barber pole |
| `George+TitleBar.m` | Title bars, their ridges and texture, the three widgets |
| `George+Frame.m` | The thick draggable border around the client |
| `George+Menu.m` | Menu bar, menus, items, separators |
| `George+TabView.m` | Tabs and their pane |
| `George+Icons.m` | Folders, documents, volumes, the trash and the icon tile |
| `GeorgeScrollerCells.m` | The cells NSScroller draws its parts through |
| `NSFont+George.m` | The three interface faces, and the size they are asked for |

`AppearanceMetrics.h` holds the layout constants; do not hardcode metrics in
the drawing code.

## Fonts

Mac OS 8 and 9 set their interface in three faces, and George asks for the
same three:

| Role | Mac OS | George |
| --- | --- | --- |
| System font: every control, menu, window title and button | Charcoal 12 | Chicago Kare |
| Small system font: labels, tool tips, floating window titles | Geneva 10, Finder labels Geneva 9 | Geneva 9.2 |
| Fixed pitch | Monaco 9 | Monaco 9 |

Charcoal was the system font from Mac OS 8.5 on, but it was cut to Chicago's
metrics - the guidelines call Chicago "the metric standard upon which Charcoal
is based" - and no liberally licensed revival of it exists, so Chicago stands
in, which is what Aaron drew in the first place. The small system font is only
for where space is limited, which is what the guidelines say and where GNUstep
asks for its label, tool tip and palette fonts. `+userFontOfSize:` is left
alone: the font someone writes documents in is their choice, not the theme's.

None of the three has a bold cut, and none is ever asked for one: every face
holds a single member, so `+boldSystemFontOfSize:`, the font manager and a
descriptor carrying the bold trait all come back with the regular face rather
than with a smeared copy of it. Platinum emphasises with the embossed title and
with Geneva's bold-free small text, not with weight. `t_GeorgeFonts` holds that
where a display is there to resolve fonts with.

All three faces are bitmaps built on an em of sixteen pixels, where Chicago 12
fills the em and Geneva 9 and Monaco 9 sit inside it. `NSFont+George.m` snaps
every size that is asked for to a whole em, because at any other size the
pixels of the face land between device pixels and every stem comes out a
different width.

## Icons

The icons are the Platinum artwork of Mac OS 8, turned into shapes. Every
colour of every icon was traced along the edge of its pixels and the corners
put back onto the lines they were drawn from, so what the theme carries is
outlines rather than pixels: at the size the artwork was drawn the picture is
the one Mac OS 8 showed, and at any other size it is drawn again instead of
being enlarged.

`Tools/makeiconshapes.py` does the tracing, out of the Appearance Extension of
a Mac OS 8 install CD, and writes `GeorgeIconShapes.h`; `George+Icons.m` walks
those shapes and fills them. Three details make it work: the pieces of one
colour that do not touch are kept apart and each is filled even-odd, so a ring
keeps its hole and a piece lying in that hole is not cancelled out; the
simplification distance sits just above the 0.82 of a staircase and well below
a whole pixel, so a drawn diagonal becomes a straight line while a real step,
such as the tab of a folder, stays; and every piece is kept, down to the
single pixels of the dither along a diagonal, because those carry the band
along the top of a folder and the highlight on its fold.

| Name | What is drawn |
| --- | --- |
| `common_Folder` | the folder |
| `common_GSFolder` | the System Folder |
| `common_LibraryFolder` | the Extensions folder |
| `common_ApplicationFolder` | the folder of tools |
| `common_DocsFolder` | the Documents folder |
| `common_DownloadFolder` | the folder with the download arrow |
| `common_ImageFolder` | the folder of pictures |
| `common_MusicFolder` | the folder of sounds |
| `common_VideoFolder` | the folder of movies |
| `common_Desktop` | the folder of the desktop |
| `common_HomeDirectory`, `common_Home2_48`, `common_Home` | the folder of users; the small one is the same drawing at another size, not artwork of its own |
| `common_RecyclerEmpty`, `common_RecyclerFull` | the trash, empty and full |
| `common_Unknown` | the generic document |
| `common_UnknownApplication` | the generic application |
| `common_UnknownTool` | the system extension |
| `common_MultipleSelection` | the generic document, stacked |
| `common_Root_Apple`, `common_Root_PC` | the hard disk and the other drive |
| `common_Tile` | the plinth an icon stands on, drawn like a control |

Mac OS 8 had no icon for a folder of applications, for a home directory or for
a selection of several files, so the nearest icon of the era stands in: the
folder of tools, the folder of users, and the document stacked three deep.

`Test/gallery.app` shows the whole set in its Icons window.

## Window manager

The Gershwin WindowManager draws title bars and window borders itself and asks
the current theme for the artwork. George answers the selectors it looks for:
`-drawsTitlebarButtons`, `-titlebarButtonRectForButton:titlebarWidth:styleMask:`,
`-drawtitleRect:forStyleMask:state:andTitle:`,
`-drawCloseButtonInRect:state:active:` and its two siblings,
`-windowFrameBorderWidth` and `-windowFrameBorderColorAtDepth:edge:active:`.
Those names are part of that contract; changing them loses the decorations.

## Tests

`Tests/` holds the ObjectTesting tools. They run headless:

```bash
cd Tests && gmake
for t in ./obj/t_*; do "$t"; done
```

`t_GeorgePlatinum` covers the gray levels, the pixel size of the decorations
and the color schemes; `t_GeorgeTitleBar` covers what the window manager asks
for: the widget slots for each style mask and scale factor, and the colors of
the border around the client.
`t_GeorgeFonts` covers the size the bitmap faces are asked for, and
`t_GeorgeIcons` that every icon name is answered by the theme's own drawing.

`Test/gallery.app` is a window holding every control George draws, plus a
preview of an active, an inactive and a floating title bar, and a second
window with the icons, for looking at the artwork:

```bash
cd Test && gmake
./gallery.app/gallery -GSTheme /Developer/Library/Sources/gershwin-george-theme/George.theme
```

## Build requirements

- GNUstep (gnustep-make, gnustep-base, gnustep-gui)
- clang

## License

BSD 2-Clause, see `LICENSE`. The bundled faces keep their own licenses, which
ship beside them in `Resources/Fonts` and are installed with them:

| Face | By | License |
| --- | --- | --- |
| Chicago Kare | Duane King, after Susan Kare's Chicago | MIT |
| Geneva 9.2 | "Techstar01", cloned from "Geneva 9.1" by Kelsey Higham (OFL), itself cloned from "Geneva 9" by Kelsey Higham (CC BY 3.0) | CC BY-SA 3.0 |
| Monaco 9 | "Techstar01", cloned from "Monaco" by Jamie Place (CC BY-SA 3.0) | CC BY-SA 3.0 |

The FontStructions
[Geneva 9.2](https://fontstruct.com/fontstructions/show/1744455) and
[Monaco 9](https://fontstruct.com/fontstructions/show/1744750) by "Techstar01"
are licensed under a Creative Commons Attribution Share Alike license
(http://creativecommons.org/licenses/by-sa/3.0/).
