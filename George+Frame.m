/*
 * Copyright (c) 2026 Simon Peter
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

/* The thick Platinum border the window manager draws around the client, which
 * you can also drag from any side. Each side is a ridge: black on both edges,
 * lit on the face turned towards the top left, shaded on the one turned
 * away. */

#import "George.h"
#import "GeorgePlatinum.h"
#import "AppearanceMetrics.h"

@implementation George (Frame)

- (CGFloat)windowFrameBorderWidth
{
  return METRICS_WINDOW_PLATINUM_BORDER * GeorgeUnit();
}

- (NSColor *)windowFrameBorderColorAtDepth:(NSInteger)depth
                                      edge:(NSInteger)edge
                                    active:(BOOL)active
{
  // Outside in: outline, lit face, two filler lines, shaded face, the line
  // against the client. The left side is lit on its outer face, the right
  // and bottom sides on their inner face, because the light comes from the
  // top left.
  static const NSInteger lit[] = { 0x00, 0xFF, 0xCC, 0xCC, 0x99, 0x00 };
  CGFloat s = GeorgeUnit();
  NSInteger line = (NSInteger)floor(depth / s);
  NSInteger count = sizeof(lit) / sizeof(lit[0]);

  if (line < 0)
    line = 0;
  if (line >= count)
    line = count - 1;
  // An inactive Platinum window frame is flat gray with a lighter outline.
  if (!active)
    return GeorgeGray((line == 0 || line == count - 1) ? 0x55 : 0xDD);
  if (edge != GeorgeFrameEdgeLeft && line > 0 && line < count - 1)
    return GeorgeGray(lit[count - 1 - line]);
  return GeorgeGray(lit[line]);
}

@end
