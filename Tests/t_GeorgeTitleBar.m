/* t_GeorgeTitleBar.m - ObjectTesting coverage for what George answers the
 * window manager: widget slots, and the border around the client. Headless.
 *
 * Copyright (c) 2026 Simon Peter
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

#import <Foundation/Foundation.h>
#import "Testing.h"
#import "George.h"
#import "GeorgePlatinum.h"
#import "AppearanceMetrics.h"

static BOOL SameGray(NSColor *color, NSInteger gray)
{
  // -whiteComponent is only defined for a white color space, and the frame
  // colors come back converted, so the gray is read off the red channel.
  NSColor *rgb = [color colorUsingColorSpaceName: NSCalibratedRGBColorSpace];

  return fabs([rgb redComponent] - gray / 255.0) < 0.002;
}

int main(void)
{
  NSAutoreleasePool *arp = [NSAutoreleasePool new];
  // Set before anything asks: otherwise the scale factor comes from the main
  // screen, and there is no screen in a headless test.
  NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
  George *theme;
  NSUInteger full = NSTitledWindowMask | NSClosableWindowMask
    | NSMiniaturizableWindowMask | NSResizableWindowMask;
  CGFloat width = 400.0;
  CGFloat inset = METRICS_TITLEBAR_PLATINUM_WIDGET_INSET;
  CGFloat slot = METRICS_TITLEBAR_PLATINUM_WIDGET_SLOT;
  CGFloat y = METRICS_TITLEBAR_HEIGHT - inset - slot;
  CGFloat corner = width - inset - METRICS_TITLEBAR_PLATINUM_WIDGET_SIZE;

  [defs setFloat: 1.0 forKey: @"GSScaleFactor"];
  GSWScaleFactorInvalidate();
  theme = [[George alloc] initWithBundle: nil];

  /* --- the window manager must leave the widgets to the theme --- */
  {
    PASS([theme drawsTitlebarButtons], "the theme draws its own widgets");
  }

  /* --- widget slots --- */
  {
    NSRect close = [theme titlebarButtonRectForButton: GeorgeWidgetClose
                                        titlebarWidth: width
                                            styleMask: full];
    NSRect collapse = [theme titlebarButtonRectForButton: GeorgeWidgetCollapse
                                          titlebarWidth: width
                                              styleMask: full];
    NSRect zoom = [theme titlebarButtonRectForButton: GeorgeWidgetZoom
                                      titlebarWidth: width
                                          styleMask: full];

    PASS(NSEqualRects(close, NSMakeRect(inset, y, slot, slot)),
         "the close box sits inset from the left edge");
    PASS(NSEqualRects(collapse, NSMakeRect(corner, y, slot, slot)),
         "the collapse box sits in the right corner");
    PASS(NSEqualRects(zoom, NSMakeRect(corner - slot, y, slot, slot)),
         "the zoom box sits left of the collapse box");
    PASS(NSMaxY(close) + inset == METRICS_TITLEBAR_HEIGHT,
         "a widget is inset from the top of the title bar as well");
  }

  /* --- Platinum keeps the collapse box in the corner --- */
  {
    NSUInteger noCollapse = full & ~NSMiniaturizableWindowMask;
    NSRect zoom = [theme titlebarButtonRectForButton: GeorgeWidgetZoom
                                      titlebarWidth: width
                                          styleMask: noCollapse];

    PASS(NSEqualRects(zoom, NSMakeRect(corner, y, slot, slot)),
         "the zoom box moves into the corner without a collapse box");
  }

  /* --- a widget the window does not have has no slot --- */
  {
    NSRect close = [theme titlebarButtonRectForButton: GeorgeWidgetClose
                                        titlebarWidth: width
                                            styleMask: NSTitledWindowMask];
    NSRect collapse = [theme titlebarButtonRectForButton: GeorgeWidgetCollapse
                                          titlebarWidth: width
                                              styleMask: NSTitledWindowMask];
    NSRect zoom = [theme titlebarButtonRectForButton: GeorgeWidgetZoom
                                      titlebarWidth: width
                                          styleMask: NSTitledWindowMask];

    PASS(NSIsEmptyRect(close), "no close box without NSClosableWindowMask");
    PASS(NSIsEmptyRect(collapse),
         "no collapse box without NSMiniaturizableWindowMask");
    PASS(NSIsEmptyRect(zoom), "no zoom box without NSResizableWindowMask");
  }

  /* --- slots scale with the pixel size of the decorations --- */
  {
    NSRect close;

    [defs setFloat: 2.0 forKey: @"GSScaleFactor"];
    GSWScaleFactorInvalidate();
    close = [theme titlebarButtonRectForButton: GeorgeWidgetClose
                                 titlebarWidth: width
                                     styleMask: full];
    PASS(NSEqualRects(close, NSMakeRect(inset * 2, y * 2, slot * 2, slot * 2)),
         "the widget slot doubles at scale factor 2");
    [defs setFloat: 1.0 forKey: @"GSScaleFactor"];
    GSWScaleFactorInvalidate();
  }

  /* --- the border the window manager draws around the client --- */
  {
    NSInteger last = (NSInteger)METRICS_WINDOW_PLATINUM_BORDER - 1;

    PASS([theme windowFrameBorderWidth] == METRICS_WINDOW_PLATINUM_BORDER,
         "the frame is as wide as the Platinum border");
    PASS(SameGray([theme windowFrameBorderColorAtDepth: 0
                                                  edge: GeorgeFrameEdgeLeft
                                                active: YES], 0x00),
         "the outermost line of an active frame is the black outline");
    PASS(SameGray([theme windowFrameBorderColorAtDepth: 1
                                                  edge: GeorgeFrameEdgeLeft
                                                active: YES], 0xFF),
         "the left side is lit on its outer face");
    PASS(SameGray([theme windowFrameBorderColorAtDepth: 1
                                                  edge: GeorgeFrameEdgeRight
                                                active: YES], 0x99),
         "the right side is shaded on its outer face");
    PASS(SameGray([theme windowFrameBorderColorAtDepth: last
                                                  edge: GeorgeFrameEdgeLeft
                                                active: YES], 0x00),
         "the line against the client is black");
    PASS(SameGray([theme windowFrameBorderColorAtDepth: 2
                                                  edge: GeorgeFrameEdgeLeft
                                                active: NO], 0xDD),
         "an inactive frame is flat gray");
    // A depth outside the border must not read past the table.
    PASS(SameGray([theme windowFrameBorderColorAtDepth: 99
                                                  edge: GeorgeFrameEdgeLeft
                                                active: YES], 0x00),
         "a depth past the border is clamped to the innermost line");
  }

  [arp release];
  return 0;
}
