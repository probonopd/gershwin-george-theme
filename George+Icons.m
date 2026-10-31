/*
 * Copyright (c) 2026 Simon Peter
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

/* The file icons: the Platinum artwork of Mac OS 8, drawn as the shapes it is
 * made of. Every colour of every icon was traced along the edge of its pixels
 * and simplified back onto the straight lines it was drawn from (see
 * GeorgeIconShapes.h and Tools/makeiconshapes.py), so an icon is the same
 * picture at the size it was drawn at, and a drawing rather than a blur at
 * any other.
 *
 * The one icon that is not artwork is the tile a viewer stands an icon on:
 * that is a Platinum surface, and is drawn the way the controls are. */

#import "George+Icons.h"
#import "GeorgePlatinum.h"
#import "GeorgeIconShapes.h"

static const CGFloat GeorgeIconTileSpace = 64.0;
/* Two shapes that touch share an edge, and antialiasing lets the background
 * through it; each shape is grown by half of this to close the seam. */
static const CGFloat GeorgeIconSeam = 0.12;

@interface George (IconsPrivate)
- (NSImage *)imageWithSize:(NSSize)size drawSelector:(SEL)selector;
@end

static NSColor *IconColor(unsigned int rgb)
{
  CGFloat r = ((rgb >> 16) & 0xFF) / 255.0;
  CGFloat g = ((rgb >> 8) & 0xFF) / 255.0;
  CGFloat b = (rgb & 0xFF) / 255.0;
  CGFloat max = MAX(r, MAX(g, b));
  CGFloat min = MIN(r, MIN(g, b));
  CGFloat saturation = (max > 0.0001) ? ((max - min) / max) : 0.0;

  /* The original Platinum palette is a bit too warm and saturated for the
   * OpenLook pass. Flatten the neutrals slightly and cool the blue channel so the
   * icons read as part of the rest of the UI instead of a separate Mac OS 8
   * palette. */
  if (saturation < 0.22)
    {
      r = MIN(1.0, r + 0.04);
      g = MIN(1.0, g + 0.04);
      b = MIN(1.0, b + 0.04);
    }
  else
    {
      r = MIN(1.0, r * 0.97);
      g = MIN(1.0, g * 1.02);
      b = MIN(1.0, b * 1.08);
    }

  if (b > r && b > g)
    {
      r *= 0.96;
      g *= 1.04;
      b = MIN(1.0, b * 1.10);
    }

  return [NSColor colorWithCalibratedRed: r green: g blue: b alpha: 1.0];
}

/* The shapes are written with y counted from the top, the way the artwork was
 * laid out; this is the only place that knows better. */
static NSPoint IconAt(NSRect r, CGFloat u, CGFloat x, CGFloat y)
{
  return NSMakePoint(NSMinX(r) + x * u, NSMaxY(r) - y * u);
}

static void GeorgeDrawIcon(NSRect r, const unsigned char *icon)
{
  CGFloat side = icon[0];
  CGFloat u = MIN(NSWidth(r), NSHeight(r)) / side;
  const unsigned char *shape = icon + 1;

  while (*shape != GEORGE_ICON_END)
    {
      NSColor *colour = IconColor(GeorgeIconPalette[*shape++]);
      NSInteger rings = *shape++;
      NSBezierPath *path = [NSBezierPath bezierPath];
      NSInteger ring, i;

      for (ring = 0; ring < rings; ring++)
        {
          NSInteger corners = *shape++;

          for (i = 0; i < corners; i++, shape += 2)
            {
              NSPoint point = IconAt(r, u, shape[0], shape[1]);

              if (i == 0)
                [path moveToPoint: point];
              else
                [path lineToPoint: point];
            }
          [path closePath];
        }
      // Even-odd, so a loop inside another one is the hole it was drawn as.
      [path setWindingRule: NSEvenOddWindingRule];
      [colour set];
      [path fill];
      [path setLineWidth: GeorgeIconSeam * u];
      [path setLineJoinStyle: NSRoundLineJoinStyle];
      [path stroke];
    }
}

@implementation George (Icons)

- (NSRect)iconRectForRep:(id)rep
{
  NSSize size = [rep size];

  return NSMakeRect(0, 0, size.width, size.height);
}

/* Shapes, unlike the controls, are drawn smooth: that is what makes an icon
 * the same icon at any size rather than a picture of one size. */
#define GEORGE_ICON(method_, shapes_)                                \
- (void)method_:(id)rep                                              \
{                                                                    \
  NSGraphicsContext *context = [NSGraphicsContext currentContext];   \
  BOOL antialias = [context shouldAntialias];                        \
                                                                     \
  [context setShouldAntialias: YES];                                 \
  [self imageWithSize: [rep size] drawSelector: _cmd] ;               \
  [context setShouldAntialias: antialias];                           \
}

@end
