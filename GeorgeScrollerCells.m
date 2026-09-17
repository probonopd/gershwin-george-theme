/*
 * Copyright (c) 2026 Simon Peter
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

#import "GeorgeScrollerCells.h"
#import "George+Parts.h"

/* The scroller is only ever drawn by the theme that handed out these cells,
 * so ask for it rather than for whichever theme is current now. */
static George *GeorgeTheme(void)
{
  GSTheme *theme = [GSTheme theme];

  return [theme isKindOfClass: [George class]] ? (George *)theme : nil;
}

@implementation GeorgeScrollerArrowCell

@synthesize direction = _direction;

- (void)drawWithFrame:(NSRect)frame inView:(NSView *)view
{
  George *theme = GeorgeTheme();
  BOOL enabled = ![view respondsToSelector: @selector(isEnabled)]
    || [(NSControl *)view isEnabled];

  if (theme == nil)
    return;
  [theme drawScrollArrowInRect: frame
                      flipped: [view isFlipped]
                    direction: _direction
                      pressed: [self isHighlighted]
                      enabled: enabled];
}

@end

@implementation GeorgeScrollerKnobCell

@synthesize horizontal = _horizontal;

- (void)drawWithFrame:(NSRect)frame inView:(NSView *)view
{
  George *theme = GeorgeTheme();

  if (theme == nil)
    return;
  [theme drawScrollKnobInRect: frame
                     flipped: [view isFlipped]
                  horizontal: _horizontal];
}

@end

@implementation GeorgeScrollerSlotCell

@synthesize horizontal = _horizontal;

- (void)drawWithFrame:(NSRect)frame inView:(NSView *)view
{
  George *theme = GeorgeTheme();

  if (theme == nil)
    return;
  [theme drawScrollSlotInRect: frame
                     flipped: [view isFlipped]
                  horizontal: _horizontal];
}

@end
