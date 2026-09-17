/* t_GeorgePlatinum.m - ObjectTesting coverage for the Platinum helpers.
 * Headless.
 *
 * Copyright (c) 2026 Simon Peter
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

#import <Foundation/Foundation.h>
#import "Testing.h"
#include "../GeorgePlatinum.m"

static BOOL SameColor(NSColor *color, CGFloat r, CGFloat g, CGFloat b)
{
  NSColor *rgb = [color colorUsingColorSpaceName: NSCalibratedRGBColorSpace];

  return fabs([rgb redComponent] - r) < 0.002
    && fabs([rgb greenComponent] - g) < 0.002
    && fabs([rgb blueComponent] - b) < 0.002;
}

int main(void)
{
  NSAutoreleasePool *arp = [NSAutoreleasePool new];
  NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];

  /* --- gray levels --- */
  {
    PASS(SameColor(GeorgeGray(0x00), 0.0, 0.0, 0.0), "gray 0x00 is black");
    PASS(SameColor(GeorgeGray(0xFF), 1.0, 1.0, 1.0), "gray 0xFF is white");
    PASS(SameColor(GeorgeGray(0xDD), 0xDD / 255.0, 0xDD / 255.0, 0xDD / 255.0),
         "gray 0xDD is the Platinum control gray");
  }

  /* --- one Platinum pixel is a whole number of device pixels --- */
  {
    [defs setFloat: 1.0 forKey: @"GSScaleFactor"];
    GSWScaleFactorInvalidate();
    PASS(GeorgeUnit() == 1.0, "unit is one pixel at scale factor 1");

    [defs setFloat: 2.0 forKey: @"GSScaleFactor"];
    GSWScaleFactorInvalidate();
    PASS(GeorgeUnit() == 2.0, "unit is two pixels at scale factor 2");

    // A fractional factor would make a ridge or a widget row come out
    // unevenly tall, so it is rounded to whole pixels.
    [defs setFloat: 1.5 forKey: @"GSScaleFactor"];
    GSWScaleFactorInvalidate();
    PASS(GeorgeUnit() == 2.0, "unit rounds a fractional scale factor up");

    [defs setFloat: 0.2 forKey: @"GSScaleFactor"];
    GSWScaleFactorInvalidate();
    PASS(GeorgeUnit() == 1.0, "unit never falls below one pixel");

    [defs setFloat: 1.0 forKey: @"GSScaleFactor"];
    GSWScaleFactorInvalidate();
  }

  /* --- color schemes --- */
  {
    // The scheme is read once per process, so lavender (the default, because
    // GeorgeColor is unset here) is the only scheme this test can see.
    PASS(SameColor(GeorgeSchemeColor(0), 0.0, 0.0, 0.0),
         "entry 0 of a scheme is black");
    PASS(SameColor(GeorgeSchemeColor(7), 1.0, 1.0, 1.0),
         "entry 7 of a scheme is white");
    PASS(SameColor(GeorgeSchemeColor(4), 0x99 / 255.0, 0x99 / 255.0, 1.0),
         "lavender is the default scheme");
  }

  [arp release];
  return 0;
}
