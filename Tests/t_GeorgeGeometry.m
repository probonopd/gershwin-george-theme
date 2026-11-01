/*
 * Copyright (c) 2026 Simon Peter
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

/* The decisions behind George's drawn parts that need no graphics context. */

#import <Foundation/Foundation.h>
#import "Testing.h"
#import "GeorgeGeometry.h"

static BOOL RectsCoverPoint(const NSRect *rects, NSUInteger count, NSPoint p)
{
  NSUInteger i;

  for (i = 0; i < count; i++)
    {
      if (NSPointInRect(p, rects[i]))
        {
          return YES;
        }
    }
  return NO;
}

int main(void)
{
  NSAutoreleasePool *arp = [NSAutoreleasePool new];

  /* Pop-up arrow box */
  {
    NSRect frame = NSMakeRect(10, 20, 140, 22);
    NSRect box = GeorgePopUpArrowBoxRect(frame, 131);

    PASS(NSMaxX(box) == NSMaxX(frame), "arrow box ends at the right edge");
    PASS(NSMinX(box) == 129, "arrow box leaves the text the gap it was promised");
    PASS(NSMinY(box) == 20 && NSHeight(box) == 22, "arrow box is as tall as the button");
    PASS(NSIsEmptyRect(GeorgePopUpArrowBoxRect(NSMakeRect(0, 0, 20, 22), 2)),
         "no arrow box where it would eat the whole button");
  }

  /* Slanted tab sides */
  {
    PASS(GeorgeTabSideInset(21, 22) == 0, "a tab side starts at its base");
    PASS(GeorgeTabSideInset(0, 22) == 7, "a tab side leans in by its full slant at the top");
    PASS(GeorgeTabSideInset(18, 22) == 1, "a tab side steps in every three rows");
    PASS(GeorgeTabSideInset(19, 22) == 0, "the step is not taken early");
  }

  /* Slider thumb */
  {
    NSRect horizontal = GeorgeSliderThumbRect(NSMakeRect(100, 10, 19, 14), YES);
    NSRect vertical = GeorgeSliderThumbRect(NSMakeRect(10, 100, 14, 19), NO);

    PASS(NSEqualRects(horizontal, NSMakeRect(103, 10, 13, 14)),
         "a horizontal thumb is centered along the track in the knob rect");
    PASS(NSEqualRects(vertical, NSMakeRect(10, 103, 14, 13)),
         "a vertical thumb is centered along the track in the knob rect");
    PASS(GeorgeSliderThumbRowInset(0, 14, 13) == 1, "the back corners are cut");
    PASS(GeorgeSliderThumbRowInset(1, 14, 13) == 0, "the body runs full width");
    PASS(GeorgeSliderThumbRowInset(7, 14, 13) == 0, "the body ends before the taper");
    PASS(GeorgeSliderThumbRowInset(8, 14, 13) == 1, "the taper starts");
    PASS(GeorgeSliderThumbRowInset(13, 14, 13) == 6, "the thumb ends in a single pixel");
  }

  /* Checkbox and radio looks */
  {
    GeorgeToggleLook look;

    look = GeorgeToggleLookMake(1, NO, YES);
    PASS(look.mark == GeorgeToggleMarkOn && !look.pressed && look.enabled, "plain on");
    look = GeorgeToggleLookMake(0, YES, YES);
    PASS(look.mark == GeorgeToggleMarkOff && look.pressed, "held keeps the mark of the state");
    look = GeorgeToggleLookMake(-1, NO, YES);
    PASS(look.mark == GeorgeToggleMarkMixed, "mixed shows the dash");
    look = GeorgeToggleLookMake(1, YES, NO);
    PASS(!look.pressed && !look.enabled, "a disabled control never looks pressed");
    PASS(GeorgeToggleLookIsPlain(GeorgeToggleLookMake(1, NO, YES), GeorgeToggleMarkOn),
         "an enabled, idle, matching image can use the plain drawing");
    PASS(!GeorgeToggleLookIsPlain(GeorgeToggleLookMake(0, YES, YES), GeorgeToggleMarkOn),
         "the alternate image shown while held does not mean the state changed");
    PASS(!GeorgeToggleLookIsPlain(GeorgeToggleLookMake(0, NO, NO), GeorgeToggleMarkOff),
         "disabled needs its own drawing");
    PASS(GeorgeToggleLookIsPlain(GeorgeToggleLookMake(-1, NO, YES), GeorgeToggleMarkMixed),
         "the mixed image shows mixed");
    PASS(!GeorgeToggleLookIsPlain(GeorgeToggleLookMake(-1, NO, YES), GeorgeToggleMarkOn),
         "a radio has no mixed image, so its on image needs replacing");
  }

  /* Group box title */
  {
    NSRect border = NSMakeRect(0, 0, 260, 100);
    NSRect title = GeorgeBoxTitleRect(NSMakeRect(90, 92, 80, 16), border);
    NSRect wide = GeorgeBoxTitleRect(NSMakeRect(0, 92, 255, 16), border);
    NSRect wider = GeorgeBoxTitleRect(NSMakeRect(0, 92, 300, 16), border);

    PASS(NSMinX(title) == 8 && NSMinY(title) == 92 && NSWidth(title) == 80,
         "the title moves left and stays on its row");
    PASS(NSMinX(wide) == 5 && NSMaxX(wide) == 260, "a wide title stays inside the box");
    PASS(NSMinX(wider) == 0, "what does not fit keeps the start of the title in view");
  }

  /* Focus ring */
  {
    NSRect r = NSMakeRect(10, 10, 40, 20);
    NSRect bands[GeorgeFocusRingBandCount];

    GeorgeFocusRingBands(r, bands);
    PASS(!RectsCoverPoint(bands, GeorgeFocusRingBandCount, NSMakePoint(10.5, 10.5)),
         "the outer corner is clipped");
    PASS(!RectsCoverPoint(bands, GeorgeFocusRingBandCount, NSMakePoint(49.5, 29.5)),
         "the opposite corner is clipped too");
    PASS(RectsCoverPoint(bands, GeorgeFocusRingBandCount, NSMakePoint(11.5, 10.5)),
         "the band reaches next to the corner");
    PASS(RectsCoverPoint(bands, GeorgeFocusRingBandCount, NSMakePoint(11.5, 11.5)),
         "the inner ring keeps its corner");
    PASS(!RectsCoverPoint(bands, GeorgeFocusRingBandCount, NSMakePoint(12.5, 12.5)),
         "the band is two pixels wide");
  }

  /* Table header */
  {
    PASS(GeorgeTableHeaderLookFor(NO, NO) == GeorgeTableHeaderNormal, "plain header");
    PASS(GeorgeTableHeaderLookFor(YES, NO) == GeorgeTableHeaderPressed, "pressed header");
    PASS(GeorgeTableHeaderLookFor(NO, YES) == GeorgeTableHeaderSorted, "sorted header");
    PASS(GeorgeTableHeaderLookFor(YES, YES) == GeorgeTableHeaderSorted,
         "GNUstep marks the sorted column highlighted, which is not a press");
  }

  [arp release];
  return 0;
}
