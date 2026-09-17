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
   The theme lands in `$(GNUSTEP_LIBRARY)/Themes/George.theme`, and the
   Chicago Kare UI font in `/System/Library/Fonts/ChicagoKare` so that
   fontconfig finds it.
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
| `GeorgeScrollerCells.m` | The cells NSScroller draws its parts through |
| `NSFont+George.m` | Chicago Kare as the interface font |

`AppearanceMetrics.h` holds the layout constants; do not hardcode metrics in
the drawing code.

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

`Test/gallery.app` is a window holding every control George draws, plus a
preview of an active, an inactive and a floating title bar, for looking at the
artwork:

```bash
cd Test && gmake
./gallery.app/gallery -GSTheme /Developer/Library/Sources/gershwin-george-theme/George.theme
```

## Build requirements

- GNUstep (gnustep-make, gnustep-base, gnustep-gui)
- clang

## License

BSD 2-Clause, see `LICENSE`. The bundled Chicago Kare font is MIT, see
`Resources/Fonts/ChicagoKare-LICENSE.txt`.
