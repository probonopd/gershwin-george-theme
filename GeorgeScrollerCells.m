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

/* NSScroller never highlights the knob's cell; while the thumb is held the
 * only sign of it is the part being tracked. Nothing promises a redraw when
 * the mouse goes up (with a scroll view the last update can be dropped as
 * unchanged), and the held thumb would stay dark. The tracking loop runs in
 * its own run loop mode, so a request queued for the others waits until the
 * thumb is let go. */
- (void)drawWithFrame:(NSRect)frame inView:(NSView *)view
{
  George *theme = GeorgeTheme();
  BOOL pressed = ([view isKindOfClass: [NSScroller class]]
                  && [(NSScroller *)view hitPart] == NSScrollerKnob);

  if (theme == nil)
    return;
  [theme drawScrollKnobInRect: frame
                     flipped: [view isFlipped]
                  horizontal: _horizontal
                     pressed: pressed];
  if (pressed)
    {
      [NSObject cancelPreviousPerformRequestsWithTarget: self
                                               selector: @selector(redrawReleased:)
                                                 object: view];
      [self performSelector: @selector(redrawReleased:)
                 withObject: view
                 afterDelay: 0.0
                    inModes: [NSArray arrayWithObjects: NSDefaultRunLoopMode,
                                      NSModalPanelRunLoopMode, nil]];
    }
}

- (void)redrawReleased:(NSView *)view
{
  [view setNeedsDisplay: YES];
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
