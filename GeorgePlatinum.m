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

/* Aaron's scheme color tables, clut -10206 to -10199. */
static NSString *const GeorgeSchemeNames[] = {
  @"lavender", @"gold", @"emerald", @"turquoise",
  @"crimson", @"magenta", @"sapphire", @"silver"
};
static const unsigned int GeorgeSchemes[][9] = {
  { 0x000000, 0x000055, 0x333399, 0x6666CC, 0x9999FF, 0xCCCCFF, 0xEEEEEE, 0xFFFFFF, 0x000088 },
  { 0x000000, 0x550000, 0x996600, 0xCC9900, 0xFFCC66, 0xFFFF66, 0xFFFFCC, 0xFFFFFF, 0x663300 },
  { 0x000000, 0x002200, 0x006633, 0x339966, 0x33CC66, 0x66FF99, 0xCCFFCC, 0xFFFFFF, 0x004400 },
  { 0x000000, 0x002200, 0x006666, 0x009999, 0x00CC99, 0x66FFCC, 0xCCFFFF, 0xFFFFFF, 0x003333 },
  { 0x000000, 0x440000, 0x990000, 0xCC3333, 0xFF6666, 0xFF9999, 0xFFCCCC, 0xFFFFFF, 0x770000 },
  { 0x000000, 0x220000, 0x660066, 0x993399, 0xCC66CC, 0xFF99FF, 0xFFCCFF, 0xFFFFFF, 0x330033 },
  { 0x000000, 0x000077, 0x0033CC, 0x3366FF, 0x6699FF, 0x99CCFF, 0xEEEEEE, 0xFFFFFF, 0x003399 },
  { 0x000000, 0x222222, 0x555555, 0x777777, 0xAAAAAA, 0xDDDDDD, 0xEEEEEE, 0xFFFFFF, 0x333333 }
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
