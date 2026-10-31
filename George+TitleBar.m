/*
 * Copyright (c) 2026 Simon Peter
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

/* Title bars in the Platinum style of Greg Landweber's Aaron extension. The
 * geometry and gray levels were taken from what Aaron 1.6.1's own window
 * definition draws and from its widget icon families; the parts are redrawn
 * here instead of shipping Aaron's artwork. */

#import "George+TitleBar.h"
#import "GeorgePlatinum.h"
#import "AppearanceMetrics.h"

static void OpenLookFill(NSRect ref, CGFloat x, CGFloat y, CGFloat w, CGFloat h,
                         NSInteger gray)
{
  GeorgeFill(ref, NO, GeorgeUnit(), x, y, w, h, GeorgeGray(gray));
}

#define EDGE (METRICS_WINDOW_PLATINUM_BORDER - 1)

static NSString *GeorgeFittingTitle(NSString *title, NSDictionary *attributes,
                                   CGFloat width)
{
  NSUInteger length = [title length];
  NSUInteger lo = 0, hi = length;

  if ([title sizeWithAttributes: attributes].width <= width)
    return title;
  while (lo < hi)
    {
      NSUInteger keep = (lo + hi + 1) / 2;
      NSString *candidate = [NSString stringWithFormat: @"%@…%@",
        [title substringToIndex: (keep + 1) / 2],
        [title substringFromIndex: length - keep / 2]];

      if ([candidate sizeWithAttributes: attributes].width <= width)
        lo = keep;
      else
        hi = keep - 1;
    }
  return [NSString stringWithFormat: @"%@…%@",
    [title substringToIndex: (lo + 1) / 2],
    [title substringFromIndex: length - lo / 2]];
}

@implementation George (TitleBar)

- (NSRect)widgetRectForButton:(GeorgeWidget)button
                 titlebarWidth:(CGFloat)width
                     styleMask:(NSUInteger)styleMask
{
  CGFloat s = GeorgeUnit();
  CGFloat inset = 4.0 * s;
  CGFloat slot = 12.0 * s;
  CGFloat y = METRICS_TITLEBAR_HEIGHT * s - inset - slot;
  CGFloat right = width - inset - slot;

  switch (button)
    {
      case GeorgeWidgetClose:
        return NSMakeRect(round(inset), round(y), slot, slot);
      case GeorgeWidgetCollapse:
        return NSMakeRect(round(right), round(y), slot, slot);
      case GeorgeWidgetZoom:
        if (styleMask & NSMiniaturizableWindowMask)
          return NSMakeRect(round(right - slot), round(y), slot, slot);
        return NSMakeRect(round(right), round(y), slot, slot);
    }
  return NSZeroRect;
}

- (void)drawTitlebarFrameInRect:(NSRect)rect active:(BOOL)active
{
  CGFloat w = NSWidth(rect) / GeorgeUnit();
  CGFloat h = NSHeight(rect) / GeorgeUnit();

  if (active)
    {
      OpenLookFill(rect, 0, 0, w, h, 0xD9);
      OpenLookFill(rect, 0, 0, w, 1, 0x6F);
      OpenLookFill(rect, 0, 0, 1, h, 0x6F);
      OpenLookFill(rect, w - 1, 0, 1, h, 0x88);
      OpenLookFill(rect, 0, h - 1, w, 1, 0x88);
      OpenLookFill(rect, 0, h - 2, w, 1, 0x3D);
    }
  else
    {
      OpenLookFill(rect, 0, 0, w, h, 0xE2);
      OpenLookFill(rect, 0, 0, w, 1, 0x8D);
      OpenLookFill(rect, 0, 0, 1, h, 0x8D);
      OpenLookFill(rect, w - 1, 0, 1, h, 0x8D);
      OpenLookFill(rect, 0, h - 1, w, 1, 0xAA);
    }
}

- (void)drawTitlebarInRect:(NSRect)rect
                  styleMask:(NSUInteger)styleMask
                     active:(BOOL)active
                      title:(NSString *)title
{
  CGFloat s = GeorgeUnit();
  CGFloat w = NSWidth(rect) / s;
  CGFloat gap = 4.0;
  CGFloat leftEdge = 4.0;
  CGFloat rightEdge = w - 4.0;
  GeorgeWidget button;

  [self drawTitlebarFrameInRect: rect active: active];

  for (button = GeorgeWidgetClose; button <= GeorgeWidgetZoom; button++)
    {
      NSRect slot = [self titlebarButtonRectForButton: button
                                        titlebarWidth: NSWidth(rect)
                                            styleMask: styleMask];

      if (NSIsEmptyRect(slot))
        continue;
      if (button == GeorgeWidgetClose)
        leftEdge = NSMaxX(slot) + gap;
      else
        rightEdge = NSMinX(slot) - gap;

      if (active)
        {
          slot.origin.x += NSMinX(rect);
          slot.origin.y += NSMinY(rect);
          [self drawWidget: button inSlot: slot pressed: NO];
        }
    }

  if ((styleMask & NSTitledWindowMask) && [title length] > 0)
    {
      NSMutableParagraphStyle *style = AUTORELEASE([NSMutableParagraphStyle new]);
      NSDictionary *attributes;
      NSSize size;
      CGFloat textWidth, textY, left;

      [style setLineBreakMode: NSLineBreakByClipping];
      attributes = @{
        NSFontAttributeName: [NSFont systemFontOfSize: 11.0 * s],
        NSForegroundColorAttributeName:
          [NSColor colorWithCalibratedWhite: (active ? 0x00 : 0x66) / 255.0 alpha: 1.0],
        NSParagraphStyleAttributeName: style
      };
      size = [title sizeWithAttributes: attributes];
      textWidth = ceil(size.width / s);
      textY = round(NSMaxY(rect) - (METRICS_TITLEBAR_HEIGHT * s) / 2.0 + size.height / 2.0);

      if (textWidth + 12.0 > rightEdge - leftEdge)
        {
          title = GeorgeFittingTitle(title, attributes,
                                     (rightEdge - leftEdge - 12.0) * s);
          textWidth = ceil([title sizeWithAttributes: attributes].width / s);
        }

      left = MAX(leftEdge, MIN(round(w / 2.0 - textWidth / 2.0), rightEdge - textWidth));
      if (active)
        {
          NSMutableDictionary *emboss = AUTORELEASE([attributes mutableCopy]);
          [emboss setObject: GeorgeGray(0xFF) forKey: NSForegroundColorAttributeName];
          [title drawAtPoint: NSMakePoint(NSMinX(rect) + (left + 1) * s, textY - s)
              withAttributes: emboss];
        }
      [title drawAtPoint: NSMakePoint(NSMinX(rect) + left * s, textY)
          withAttributes: attributes];
    }
}

- (void)drawWidget:(GeorgeWidget)button
             inSlot:(NSRect)slot
            pressed:(BOOL)pressed
{
  NSInteger i, j;
  NSColor *outline = GeorgeGray(0x5E);

  OpenLookFill(slot, 0, 0, NSWidth(slot), NSHeight(slot), 0xDF);

  for (j = 0; j < 10; j++)
    {
      for (i = 0; i < 10; i++)
        {
          CGFloat x = i, y = j;
          if (x < 1 || y < 1 || x > NSWidth(slot) - 2 || y > NSHeight(slot) - 2)
            OpenLookFill(slot, x, y, 1, 1, 0x6F);
          else
            OpenLookFill(slot, x, y, 1, 1, 0xF4);
        }
    }

  OpenLookFill(slot, 0, 0, NSWidth(slot), 1, outline);
  OpenLookFill(slot, 0, 0, 1, NSHeight(slot), outline);
  OpenLookFill(slot, NSWidth(slot) - 1, 0, 1, NSHeight(slot), outline);
  OpenLookFill(slot, 0, NSHeight(slot) - 1, NSWidth(slot), 1, outline);

  switch (button)
    {
      case GeorgeWidgetZoom:
        OpenLookFill(slot, 3, 3, 5, 5, 0x33);
        break;
      case GeorgeWidgetCollapse:
        OpenLookFill(slot, 3, 5, 6, 1, 0x33);
        break;
      case GeorgeWidgetClose:
        OpenLookFill(slot, 3, 3, 1, 5, 0x33);
        OpenLookFill(slot, 7, 3, 1, 5, 0x33);
        OpenLookFill(slot, 3, 3, 5, 1, 0x33);
        OpenLookFill(slot, 3, 7, 5, 1, 0x33);
        break;
    }
}

- (void)drawWidget:(GeorgeWidget)button
             inSlot:(NSRect)slot
             active:(BOOL)active
            hovered:(BOOL)hovered
{
  if (active || hovered)
    [self drawWidget: button inSlot: slot pressed: NO];
}

@end
