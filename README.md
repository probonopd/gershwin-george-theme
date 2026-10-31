# OpenLook Theme

OpenLook is a GNUstep theme in the Mac OS 8 Platinum style, reinterpreted with a
cooler OpenLook-inspired palette: steel grays, low-saturation blues, and a
light ivory surface that keeps the classic beveled window chrome while fitting
more naturally in a modern GNUstep desktop.

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
   The theme lands in `$(GNUSTEP_LIBRARY)/Themes/OpenLook.theme`, and its three
   UI faces in `/System/Library/Fonts/ChicagoKare`, `.../Geneva92` and
   `.../Monaco9` so that fontconfig finds them.
3. Select it:
   ```bash
   defaults write NSGlobalDomain GSTheme OpenLook
   ```
   Log out and back in so the WindowManager picks it up as well.

## Accent color

The accent color follows the OpenLook-inspired schemes and defaults to:

```bash
defaults write NSGlobalDomain GeorgeColor openlook
```

Available schemes are `openlook` (the default), `openlook-ivory`, and
`openlook-ink`. The scheme is read once per process, so applications pick a
new one up when they restart.

## What is where

| File | What it draws |
| --- | --- |
| `GeorgePlatinum.m` | Pixel fill helper, gray levels, the OpenLook-inspired color schemes |
| `George.m` | Every GSTheme hook, routed to a Platinum/OpenLook part |
| `George+Parts.m` | Push buttons, checkboxes, radio buttons, scroll bar parts, wells, panels, grooves, slider knobs, the grow box, the barber pole |
| `George+TitleBar.m` | Title bars, their ridges and texture, the three widgets |
| `George+Frame.m` | The thick draggable border around the client |
| `George+Menu.m` | Menus and menu bar |
| `George+Icons.m` | File and folder icons drawn from traced shapes and a cooler icon palette |
| `AppearanceMetrics.h` | Theme metrics and scale-factor logic |

## Notes

The OpenLook pass is intentionally restrained: it preserves the original
Platinum-era geometry and bevel structure, but shifts the palette toward cooler
steel blues and softened grays so the theme reads as a coherent, integrated
desktop skin rather than a warm Mac OS 8 clone.
