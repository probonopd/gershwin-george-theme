/* t_GeorgeFonts.m - ObjectTesting coverage for the size at which the Platinum
 * bitmap faces are asked for. Headless.
 *
 * Copyright (c) 2026 Simon Peter
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

#import <Foundation/Foundation.h>
#import "Testing.h"
#include "../NSFont+George.m"

int main(void)
{
  NSAutoreleasePool *arp = [NSAutoreleasePool new];

  /* --- a size lands on the pixel grid of the faces --- */
  {
    // Chicago 12, Geneva 9 and Monaco 9 are all drawn on an em of sixteen
    // pixels, so only whole multiples of it come out as the bitmaps.
    PASS(GeorgeSnappedFontSize(16.0) == 16.0, "one em is left alone");
    PASS(GeorgeSnappedFontSize(32.0) == 32.0, "two ems are left alone");
    PASS(GeorgeSnappedFontSize(12.0) == 16.0,
         "the GNUstep interface size snaps up to one em");
    PASS(GeorgeSnappedFontSize(13.0) == 16.0, "a size below one em snaps up");
    PASS(GeorgeSnappedFontSize(28.0) == 32.0,
         "a size near two ems snaps to two ems");
    PASS(GeorgeSnappedFontSize(20.0) == 16.0,
         "a size just above one em stays at one em");
  }

  /* --- the faces have a single weight, so nothing may come back bold --- */
  START_SET("bold")
    NSFontManager *manager = nil;
    NSFont *plain;
    NSFont *bold;
    BOOL resolvable = NO;

    // Resolving a font needs the backend, and the backend needs a display,
    // which a headless run has not.
    NS_DURING
      [NSApplication sharedApplication];
      manager = [NSFontManager sharedFontManager];
      resolvable = [[manager availableFontFamilies]
                     containsObject: GeorgeSystemFontFamily];
    NS_HANDLER
      resolvable = NO;
    NS_ENDHANDLER
    if (!resolvable)
      SKIP("the interface faces cannot be resolved here")

    plain = [NSFont systemFontOfSize: 0];
    bold = [NSFont boldSystemFontOfSize: 0];
    PASS_EQUAL([bold fontName], [plain fontName],
               "the bold system font is the same face as the system font");
    PASS(([manager traitsOfFont: bold] & NSBoldFontMask) == 0,
         "the bold system font carries no bold trait");
    PASS_EQUAL([[manager convertFont: plain
                         toHaveTrait: NSBoldFontMask] fontName],
               [plain fontName],
               "the font manager cannot embolden the system font either");
    PASS([manager fontWithFamily: GeorgeSystemFontFamily
                          traits: NSBoldFontMask
                          weight: 9
                            size: METRICS_FONT_PLATINUM_EM] == nil,
         "the family has no bold member to hand out");
  END_SET("bold")

  /* --- a size that names nothing --- */
  {
    PASS(GeorgeSnappedFontSize(0.0) == 16.0, "an unset size is one em");
    PASS(GeorgeSnappedFontSize(-8.0) == 16.0, "a negative size is one em");
  }

  [arp release];
  return 0;
}
