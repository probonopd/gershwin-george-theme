/*
 * Copyright (c) 2026 Simon Peter
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

#import "GeorgePlatinum.h"
#import "AppearanceMetrics.h"

/* Process-wide GSScaleFactor cache used by the AppearanceMetrics macros;
 * reset by GSWScaleFactorInvalidate() for live scale-factor changes. */
CGFloat GSWScaleFactorValue = 0;

void GeorgeFill(NSRect ref, BOOL flipped, CGFloat unit,
                 CGFloat x, CGFloat y, CGFloat w, CGFloat h, NSColor *color)
{
  CGFloat left = round(NSMinX(ref) + x * unit);
  CGFloat right = round(NSMinX(ref) + (x + w) * unit);
  CGFloat near, far;

  if (flipped)
    {
      near = round(NSMinY(ref) + y * unit);
      far = round(NSMinY(ref) + (y + h) * unit);
    }
  else
    {
      near = round(NSMaxY(ref) - (y + h) * unit);
      far = round(NSMaxY(ref) - y * unit);
    }
  if (right <= left || far <= near)
    return;
  [color set];
  NSRectFill(NSMakeRect(left, near, right - left, far - near));
}

NSColor *GeorgeGray(NSInteger gray)
{
  return [NSColor colorWithCalibratedWhite: gray / 255.0 alpha: 1.0];
}

CGFloat GeorgeUnit(void)
{
  CGFloat scale = GSWScaleFactor();

  return MAX(1.0, round(scale));
}

/* OpenLook-inspired palette: cool steel grays, muted teal-blue accents, and
 * light ivory surfaces, rather than the warm Platinum color set. */
static NSString *const GeorgeSchemeNames[] = {
  @"openlook", @"openlook-ivory", @"openlook-ink"
};
static const unsigned int GeorgeSchemes[][9] = {
  /* openlook */
  { 0x000000, 0x21313d, 0x38566b, 0x4d7082, 0x6d90a3, 0x9bb2bf, 0xdfe7eb, 0xFFFFFF, 0x2a495d },
  /* openlook-ivory */
  { 0x000000, 0x4b4b49, 0x7c7d7a, 0x9aa1a0, 0xc0c6c5, 0xe3e7e6, 0xf4f4f1, 0xFFFFFF, 0x5d5d5a },
  /* openlook-ink */
  { 0x000000, 0x1d2430, 0x243a4b, 0x3a5d75, 0x62879a, 0x8aa7b5, 0xdde7ed, 0xFFFFFF, 0x233547 }
};

NSColor *GeorgeSchemeColor(NSInteger index)
{
  // Read once: every part drawn in the scheme must agree for the lifetime of
  // the process.
  static NSInteger scheme = -1;
  unsigned int rgb;

  if (scheme < 0)
    {
      NSString *name = [[[NSUserDefaults standardUserDefaults]
                          stringForKey: @"GeorgeColor"] lowercaseString];
      NSUInteger i;

      scheme = 0;
      for (i = 0; i < sizeof(GeorgeSchemes) / sizeof(GeorgeSchemes[0]); i++)
        {
          if ([name isEqualToString: GeorgeSchemeNames[i]])
            scheme = i;
        }
    }
  rgb = GeorgeSchemes[scheme][index];
  return [NSColor colorWithCalibratedRed: ((rgb >> 16) & 0xFF) / 255.0
                                   green: ((rgb >> 8) & 0xFF) / 255.0
                                    blue: (rgb & 0xFF) / 255.0
                                   alpha: 1.0];
}
