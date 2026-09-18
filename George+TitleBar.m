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

/* The window manager draws title bars in device pixels, so one Platinum pixel
 * is GeorgeUnit() device pixels here. */
static void PlatinumFill(NSRect ref, CGFloat x, CGFloat y, CGFloat w, CGFloat h,
                         NSInteger gray)
{
  GeorgeFill(ref, NO, GeorgeUnit(), x, y, w, h, GeorgeGray(gray));
}

/* The window wall either side of the title bar, which is also where the
 * sunken frame around the client starts. */
#define EDGE (METRICS_WINDOW_PLATINUM_BORDER - 2)

/* Longest middle-truncated form of title that fits into width, because
 * NSLineBreakByTruncatingMiddle is not honoured when drawing a single line. */
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

/* Embossed ridges between from and to (exclusive): each light line has its
 * dark partner one pixel lower and one pixel further right. */
static void GeorgeRidges(NSRect ref, CGFloat from, CGFloat to)
{
  NSInteger i;

  if (to - from < 2)
    return;
  for (i = 0; i < METRICS_TITLEBAR_PLATINUM_RIDGES; i++)
    {
      CGFloat y = METRICS_TITLEBAR_PLATINUM_RIDGE_TOP + 2 * i;

      PlatinumFill(ref, from, y, to - from - 1, 1, 0xFF);
      PlatinumFill(ref, from + 1, y + 1, to - from - 1, 1, 0x77);
    }
}


/* Texture of a floating window's title bar: a lit dot in each three pixel
 * cell with its shadow below right, which is what Aaron tiles across it. */
static void GeorgeDots(NSRect ref, CGFloat from, CGFloat to, CGFloat height)
{
  CGFloat x, y;

  for (y = 3; y + 2 < height - 3; y += 3)
    for (x = from; x + 2 < to; x += 3)
      {
        PlatinumFill(ref, x, y, 1, 1, 0xFF);
        PlatinumFill(ref, x + 1, y + 1, 1, 1, 0x55);
      }
}

@implementation George (TitleBar)

- (NSRect)widgetRectForButton:(GeorgeWidget)button
                titlebarWidth:(CGFloat)width
                    styleMask:(NSUInteger)styleMask
{
  CGFloat s = GeorgeUnit();
  CGFloat inset = METRICS_TITLEBAR_PLATINUM_WIDGET_INSET * s;
  CGFloat slot = METRICS_TITLEBAR_PLATINUM_WIDGET_SLOT * s;
  CGFloat y = METRICS_TITLEBAR_HEIGHT * s - inset - slot;
  CGFloat corner = round(width - inset - METRICS_TITLEBAR_PLATINUM_WIDGET_SIZE * s);

  switch (button)
    {
      case GeorgeWidgetClose:
        return NSMakeRect(round(inset), round(y), slot, slot);
      case GeorgeWidgetCollapse:
        return NSMakeRect(corner, round(y), slot, slot);
      case GeorgeWidgetZoom:
        // Platinum keeps the collapse box in the corner; the zoom box only
        // moves there when the window has no collapse box.
        if (styleMask & NSMiniaturizableWindowMask)
          return NSMakeRect(corner - slot, round(y), slot, slot);
        return NSMakeRect(corner, round(y), slot, slot);
    }
  return NSZeroRect;
}

- (void)drawTitlebarFrameInRect:(NSRect)rect active:(BOOL)active
{
  CGFloat w = NSWidth(rect) / GeorgeUnit();
  CGFloat h = NSHeight(rect) / GeorgeUnit();

  if (active)
    {
      // The window wall: black outline, lit along the top and left, shaded
      // along the right, and the same four pixels wide as the border the
      // window manager draws around the client below.
      PlatinumFill(rect, 0, 0, w, h, 0xCC);
      PlatinumFill(rect, 1, 1, w - 3, 1, 0xFF);
      PlatinumFill(rect, 1, 1, 1, h - 1, 0xFF);
      PlatinumFill(rect, w - 2, 2, 1, h - 2, 0x99);
      PlatinumFill(rect, 0, 0, w, 1, 0x00);
      PlatinumFill(rect, 0, 0, 1, h, 0x00);
      PlatinumFill(rect, w - 1, 0, 1, h, 0x00);
      // The last two rows are where the sunken frame around the client
      // begins: its shadow, then its black line, which the border continues
      // down both sides.
      PlatinumFill(rect, EDGE, h - 2, w - 2 * EDGE - 1, 1, 0x99);
      PlatinumFill(rect, EDGE, h - 1, 1, 1, 0x99);
      PlatinumFill(rect, EDGE + 1, h - 1, w - 2 * EDGE - 2, 1, 0x00);
      PlatinumFill(rect, w - EDGE - 1, h - 1, 1, 1, 0xFF);
    }
  else
    {
      PlatinumFill(rect, 0, 0, w, h, 0xDD);
      PlatinumFill(rect, 0, 0, w, 1, 0x55);
      PlatinumFill(rect, 0, 0, 1, h, 0x55);
      PlatinumFill(rect, w - 1, 0, 1, h, 0x55);
      // An inactive window has a single line around the client, no shadow.
      PlatinumFill(rect, EDGE + 1, h - 1, w - 2 * EDGE - 2, 1, 0x55);
    }
}

- (void)drawTitlebarInRect:(NSRect)rect
                 styleMask:(NSUInteger)styleMask
                    active:(BOOL)active
                     title:(NSString *)title
{
  CGFloat s = GeorgeUnit();
  CGFloat w = NSWidth(rect) / s;
  CGFloat gap = METRICS_TITLEBAR_PLATINUM_GAP;
  CGFloat ridgesFrom = METRICS_TITLEBAR_PLATINUM_WIDGET_INSET;
  CGFloat ridgesTo = w - METRICS_TITLEBAR_PLATINUM_WIDGET_INSET;
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
        ridgesFrom = NSMinX(slot) / s + METRICS_TITLEBAR_PLATINUM_WIDGET_SIZE + gap;
      else
        ridgesTo = MIN(ridgesTo, NSMinX(slot) / s - gap);

      // Platinum hides the widgets of inactive windows.
      if (active)
        {
          slot.origin.x += NSMinX(rect);
          slot.origin.y += NSMinY(rect);
          [self drawWidget: button inSlot: slot pressed: NO];
        }
    }

  // Aaron fills the bar with its texture and then paints the title's own
  // background over it, so the title needs no gap of its own.
  if (active)
    {
      if (styleMask & NSUtilityWindowMask)
        GeorgeDots(rect, ridgesFrom, ridgesTo, NSHeight(rect) / s);
      else
        GeorgeRidges(rect, ridgesFrom, ridgesTo);
    }

  if ((styleMask & NSTitledWindowMask) && [title length] > 0)
    {
      NSMutableParagraphStyle *style = AUTORELEASE([NSMutableParagraphStyle new]);
      NSDictionary *attributes;
      NSSize size;
      CGFloat textWidth, textY, left;

      [style setLineBreakMode: NSLineBreakByClipping];
      attributes = @{
        // A floating window carries its title in the small system font, the
        // way Platinum sets everything that sits in a narrow strip.
        NSFontAttributeName: ((styleMask & NSUtilityWindowMask)
                              ? [NSFont paletteFontOfSize:
                                          METRICS_FONT_PLATINUM_EM * s]
                              : [NSFont systemFontOfSize:
                                          METRICS_FONT_PLATINUM_EM * s]),
        NSForegroundColorAttributeName:
          [NSColor colorWithCalibratedWhite: (active ? 0x00 : 0x88) / 255.0 alpha: 1.0],
        NSParagraphStyleAttributeName: style
      };
      size = [title sizeWithAttributes: attributes];
      textWidth = ceil(size.width / s);
      // Center the text on the ridges rather than on the whole bar so both
      // line up the way they do in Platinum.
      textY = round(NSMaxY(rect)
                    - (METRICS_TITLEBAR_PLATINUM_RIDGE_TOP + METRICS_TITLEBAR_PLATINUM_RIDGES) * s
                    - size.height / 2.0);

      if (textWidth + 2 * METRICS_TITLEBAR_PLATINUM_TITLE_PAD > ridgesTo - ridgesFrom)
        {
          title = GeorgeFittingTitle(title, attributes,
                                       (ridgesTo - ridgesFrom
                                        - 2 * METRICS_TITLEBAR_PLATINUM_TITLE_PAD) * s);
          textWidth = ceil([title sizeWithAttributes: attributes].width / s);
        }

      left = MAX(ridgesFrom + METRICS_TITLEBAR_PLATINUM_TITLE_PAD,
                 MIN(round(w / 2.0 - textWidth / 2.0),
                     ridgesTo - METRICS_TITLEBAR_PLATINUM_TITLE_PAD - textWidth));
      if (active)
        {
          NSMutableDictionary *emboss = AUTORELEASE([attributes mutableCopy]);

          PlatinumFill(rect, left - METRICS_TITLEBAR_PLATINUM_TITLE_PAD, 2,
                       textWidth + 2 * METRICS_TITLEBAR_PLATINUM_TITLE_PAD,
                       NSHeight(rect) / s - 4, 0xCC);
          // An active title is embossed: a light copy one pixel down and to
          // the right under the black one.
          [emboss setObject: GeorgeGray(0xEE)
                     forKey: NSForegroundColorAttributeName];
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

  // Sunken well around a near-black ring.
  PlatinumFill(slot, 0, 0, 12, 1, 0x88);
  PlatinumFill(slot, 0, 0, 1, 12, 0x88);
  PlatinumFill(slot, 1, 12, 12, 1, 0xFF);
  PlatinumFill(slot, 12, 1, 1, 12, 0xFF);
  PlatinumFill(slot, 1, 1, 11, 1, 0x22);
  PlatinumFill(slot, 1, 11, 11, 1, 0x22);
  PlatinumFill(slot, 1, 1, 1, 11, 0x22);
  PlatinumFill(slot, 11, 1, 1, 11, 0x22);

  // 9x9 face shaded diagonally, one 0x11 step every two pixels: raised and
  // lit from the bottom right when up, darker and flat when pressed.
  for (j = 0; j < 9; j++)
    {
      for (i = 0; i < 9; i++)
        {
          NSInteger gray;

          if (pressed)
            {
              gray = 0x44 + 0x11 * ((i + j) / 2);
              if (i == 8 || j == 8)
                gray = MIN(gray, 0x99);
            }
          else if (i == 0 && j == 0)
            gray = 0xFF;
          else if (i == 0 || j == 0)
            gray = 0xCC;
          else if (i == 8 || j == 8)
            gray = 0x88;
          else
            gray = 0x99 + 0x11 * ((i + j - 2) / 2);
          PlatinumFill(slot, 2 + i, 2 + j, 1, 1, gray);
        }
    }

  switch (button)
    {
      case GeorgeWidgetZoom:
        // Zoom box: a small box in the top left corner.
        PlatinumFill(slot, 7, 2, 1, 5, 0x22);
        PlatinumFill(slot, 2, 7, 6, 1, 0x22);
        break;
      case GeorgeWidgetCollapse:
        // Collapse box: two bars.
        PlatinumFill(slot, 2, 5, 9, 1, 0x22);
        PlatinumFill(slot, 2, 7, 9, 1, 0x22);
        break;
      case GeorgeWidgetClose:
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
