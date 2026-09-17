/*
 * Copyright (c) 2026 Simon Peter
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

#import <AppKit/AppKit.h>

/* NSScroller draws its parts through cells it asks the theme for. These three
 * hand the drawing back to George so the whole scroll bar is pixel art in the
 * same grays as the rest of the interface. */

@interface GeorgeScrollerArrowCell : NSButtonCell
{
  NSInteger _direction;         /* 0 up, 1 down, 2 left, 3 right */
}
@property (nonatomic, assign) NSInteger direction;
@end

@interface GeorgeScrollerKnobCell : NSButtonCell
{
  BOOL _horizontal;
}
@property (nonatomic, assign) BOOL horizontal;
@end

@interface GeorgeScrollerSlotCell : NSButtonCell
{
  BOOL _horizontal;
}
@property (nonatomic, assign) BOOL horizontal;
@end
