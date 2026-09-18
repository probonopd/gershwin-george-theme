# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

`George.theme`, a GNUstep `GSTheme` bundle in the Mac OS 8 Platinum look
(reference: Greg Landweber's Aaron 1.6.1, artwork reimplemented, nothing of
Aaron's shipped). Principal class `George`, subclass of `GSTheme`. No nibs, no
image assets: every control is pixel art drawn in code.

## Build, test, run

```bash
gmake                     # builds George.theme in the source tree
sudo -E gmake install     # SYSTEM domain only (set in GNUmakefile)
gmake clean
```

Install also drops the three UI faces into `/System/Library/Fonts/<face>`
(`GNUmakefile.postamble`), because fontconfig only finds them there.

Tests (ObjectTesting, headless, no display needed):

```bash
cd Tests && gmake
./obj/t_GeorgeFonts           # one test tool
for t in ./obj/t_*; do "$t"; done
```

Visual check without installing:

```bash
cd Test && gmake
./gallery.app/gallery -GSTheme /Developer/Library/Sources/gershwin-george-theme/George.theme
```

`gallery.app` shows every control plus active/inactive/floating title bar
previews. Any app takes `-GSTheme <path to George.theme>`, so the build tree
can be driven directly; installing is only needed for the session-wide theme
(`defaults write NSGlobalDomain GSTheme George`, then log out/in so the
WindowManager picks it up too).

## Architecture

- `George.m` is wiring only. It implements the `GSTheme` hooks and routes each
  to a Platinum part in a category. Put drawing there, not here.
- `George+Parts.m` - controls: push/bevel buttons, checkbox and radio images,
  scroll arrows/knob/slot, wells, raised panels, grooves, slider knob, grow
  box, barber pole.
- `George+TitleBar.m` / `George+Frame.m` / `George+Menu.m` / `George+TabView.m`
  - the corresponding surfaces. `George+Frame.m` has no header; it implements
  the `George (Frame)` category declared in `George.h`.
- `GeorgePlatinum.m` - the drawing primitive `GeorgeFill()`, `GeorgeGray()`,
  `GeorgeUnit()`, and Aaron's eight color schemes via `GeorgeSchemeColor()`.
  Also defines `GSWScaleFactorValue`, the storage the `AppearanceMetrics.h`
  inline functions need.
- `George+Icons.m` - the file icons: shapes traced from the Mac OS 8 artwork
  by `Tools/makeiconshapes.py` into `GeorgeIconShapes.h` (a byte stream of
  colour, loop count, then each loop's corners in the 32 unit square).
  `GeorgeDrawIcon` fills each shape even-odd with antialiasing on, so an icon
  is drawn at whatever size it is asked for. Shapes are per connected piece,
  biggest first; `common_Tile` is the one icon drawn like a control.
  `-registerFileIcons` is called from `-activate`.
- `GeorgeScrollerCells.m` - `NSScroller` draws through cells, so these three
  `NSButtonCell` subclasses hand drawing back to George.
- `NSFont+George.m` - swizzles the `NSFont` UI-font class methods at `+load`
  time; a theme has no hook for the system font. Roles follow the Mac OS 8
  guidelines: system/menu/title/control content to Chicago Kare, label/tool
  tip/palette to Geneva 9.2, fixed pitch to Monaco 9, and `+userFontOfSize:`
  untouched. Every size is snapped to a whole `METRICS_FONT_PLATINUM_EM`
  (16 px), the em all three bitmap faces are built on; at any other size they
  render blurred. It logs and falls back to the GNUstep font per family that
  is not installed.

### Drawing convention

Everything is laid out in Platinum pixels from the top-left corner of a
reference rect and drawn with
`GeorgeFill(ref, flipped, unit, x, y, w, h, color)`, which snaps every edge to
whole points so neighbouring fills tile seamlessly. Files define a local
`FILL(...)` macro over it.

- Controls draw at `unit = 1` (they sit in an already-scaled context).
- Window decorations (title bar, frame) draw at `unit = GeorgeUnit()`, the
  scale factor rounded to a whole number - pixel art needs whole rows.
- `flipped` follows the view; `George+TitleBar.m` passes `NO`.

### Window manager contract

The Gershwin WindowManager draws window decorations itself and asks the theme
for the artwork through duck-typed selectors declared in the
`George (WindowManager)` and `George (Frame)` categories in `George.h`:
`-drawsTitlebarButtons`, `-titlebarButtonRectForButton:titlebarWidth:styleMask:`,
`-drawtitleRect:forStyleMask:state:andTitle:`, `-drawCloseButtonInRect:state:active:`
(plus Minimize/Maximize), `-windowFrameBorderWidth`,
`-windowFrameBorderColorAtDepth:edge:active:`. Renaming any of these silently
loses the decorations. `t_GeorgeTitleBar` is the regression net for the
geometry and colors those return.

### Metrics and colors

- `AppearanceMetrics.h` is the shared Gershwin metrics header (copy of the one
  in gershwin-eau-theme). Never hardcode layout values in drawing code; add a
  constant there instead. Platinum-specific ones are the
  `METRICS_TITLEBAR_PLATINUM_*`, `METRICS_WINDOW_PLATINUM_BORDER` and
  `METRICS_FONT_PLATINUM_EM` block.
- `-[George colors]` builds one `System` color list on top of `[super colors]`
  and overrides the Platinum grays and the scheme-derived selection colors.
  Control images are registered in `-activate`, not earlier - images can only
  be registered once the theme is current.
- The accent scheme comes from the `GeorgeColor` user default and is read once
  per process, so tests can only observe the default (lavender), and apps need
  a restart after changing it.

### Tests

`Tests/GNUmakefile.preamble` shows the two linking styles used here:
`t_GeorgePlatinum` and `t_GeorgeFonts` `#include` the one `.m` they cover to
reach its C helpers in-process; `t_GeorgeTitleBar` links the whole theme except
`NSFont+George.m`, which is left out because its `+load` swizzle is irrelevant
to the geometry.
`t_GeorgeFonts`' bold set and `t_GeorgeIcons` need a display to resolve fonts
and draw images with, so both check for one and `SKIP` the set without it.

Headless tests must set `GSScaleFactor` in defaults and call
`GSWScaleFactorInvalidate()` before asking for anything scaled - there is no
main screen to fall back to.
