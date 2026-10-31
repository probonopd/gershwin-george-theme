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
  return 3.0 * GeorgeUnit();
}

- (NSColor *)windowFrameBorderColorAtDepth:(NSInteger)depth
                                       edge:(NSInteger)edge
                                     active:(BOOL)active
{
  static const NSInteger lit[] = { 0x00, 0x6A, 0x8E, 0xB1, 0xD3, 0x00 };
  CGFloat s = GeorgeUnit();
  NSInteger line = (NSInteger)floor(depth / s);
  NSInteger count = sizeof(lit) / sizeof(lit[0]);

  if (line < 0)
    line = 0;
  if (line >= count)
    line = count - 1;

  if (!active)
    return GeorgeGray((line == 0 || line == count - 1) ? 0x99 : 0xC7);

  if (edge != GeorgeFrameEdgeLeft && line > 0 && line < count - 1)
    return GeorgeGray(lit[count - 1 - line]);
  return GeorgeGray(lit[line]);
}

@end
