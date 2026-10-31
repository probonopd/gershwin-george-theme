/*
 * Copyright (c) 2026 Simon Peter
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

/* The Platinum parts: push buttons, checkboxes, radio buttons, scroll bar
 * pieces, wells, panels and grooves in the shapes and grays that Aaron's
 * control definitions draw. */

#import "George+Parts.h"
#import "GeorgePlatinum.h"

// Aaron draws checkboxes and radio buttons 12 pixels square.
static const CGFloat GeorgeBoxSize = 12.0;

@interface George (PartsPrivate)
- (void)drawBoxWellInRect:(NSRect)box oval:(BOOL)oval;
- (void)drawCheckMarkInRect:(NSRect)box;
- (void)drawArrowInRep:(id)rep direction:(NSInteger)direction;
- (NSRect)boxRectForRep:(id)rep;
- (NSImage *)imageWithSize:(NSSize)size drawSelector:(SEL)selector;
@end

@implementation George (Parts)

- (void)drawPushButtonInRect:(NSRect)frame
                           flipped:(BOOL)flipped
                           pressed:(BOOL)pressed
                           enabled:(BOOL)enabled
{
  NSRect r = NSIntegralRect(frame);
  CGFloat w = NSWidth(r);
  CGFloat h = NSHeight(r);
  NSColor *face = GeorgeGray(pressed ? 0xD7 : 0xF1);
  NSColor *edge = GeorgeGray(enabled ? 0x6B : 0x88);
  NSColor *shadow = GeorgeGray(pressed ? 0x9A : 0xBB);
  NSColor *highlight = GeorgeGray(pressed ? 0xF7 : 0xFF);

  if (w < 8 || h < 8)
    return;

#define FILL(x_, y_, w_, h_, c) GeorgeFill(r, flipped, 1, x_, y_, w_, h_, c)
  FILL(0, 0, w, h, face);
  FILL(0, 0, w, 1, edge);
  FILL(0, h - 1, w, 1, shadow);
  FILL(0, 0, 1, h, edge);
  FILL(w - 1, 0, 1, h, shadow);

  FILL(1, 1, w - 2, h - 2, face);
  FILL(1, 1, w - 2, 1, highlight);
  FILL(1, 1, 1, h - 2, highlight);
  FILL(2, h - 2, w - 3, 1, shadow);
  FILL(w - 2, 2, 1, h - 3, shadow);

  if (!enabled)
    return;

  FILL(2, 2, w - 4, 1, highlight);
  FILL(2, 2, 1, h - 4, highlight);
  FILL(3, h - 3, w - 5, 1, shadow);
  FILL(w - 3, 3, 1, h - 5, shadow);
#undef FILL
}

#pragma mark - Scroll bars

- (void)drawScrollArrowInRect:(NSRect)frame
                            flipped:(BOOL)flipped
                          direction:(NSInteger)direction
                            pressed:(BOOL)pressed
                            enabled:(BOOL)enabled
{
  NSRect r = NSIntegralRect(frame);
  CGFloat w = NSWidth(r), h = NSHeight(r);
  NSColor *face = GeorgeGray(pressed ? 0xD9 : 0xEB);
  NSColor *edge = GeorgeGray(enabled ? 0x74 : 0x99);
  NSColor *glyph = GeorgeGray(enabled ? 0x11 : 0x77);
  CGFloat cx = floor(w / 2.0), cy = floor(h / 2.0);
  NSInteger i;

  if (w < 6 || h < 6)
    return;

  GeorgeFill(r, flipped, 1, 0, 0, w, h, GeorgeGray(0xF4));
  GeorgeFill(r, flipped, 1, 1, 1, w - 2, h - 2, face);
  GeorgeFill(r, flipped, 1, 1, 1, w - 2, 1, GeorgeGray(0xFF));
  GeorgeFill(r, flipped, 1, 1, 1, 1, h - 2, GeorgeGray(0xFF));
  GeorgeFill(r, flipped, 1, 1, h - 2, w - 2, 1, edge);
  GeorgeFill(r, flipped, 1, w - 2, 1, 1, h - 2, edge);

  for (i = 0; i < 4; i++)
    {
      switch (direction)
        {
          case 0: GeorgeFill(r, flipped, 1, cx - i - 1, cy - 2 + i, 2 * i + 2, 1, glyph); break;
          case 1: GeorgeFill(r, flipped, 1, cx - 4 + i, cy - 2 + i, 8 - 2 * i, 1, glyph); break;
          case 2: GeorgeFill(r, flipped, 1, cx - 2 + i, cy - i - 1, 1, 2 * i + 2, glyph); break;
          default: GeorgeFill(r, flipped, 1, cx - 2 + i, cy - 4 + i, 1, 8 - 2 * i, glyph); break;
        }
    }
}

- (void)drawScrollKnobInRect:(NSRect)frame
                           flipped:(BOOL)flipped
                        horizontal:(BOOL)horizontal
{
  NSRect r = NSIntegralRect(frame);
  CGFloat w = NSWidth(r), h = NSHeight(r);
  NSInteger i;

  if (w < 6 || h < 6)
    return;

  GeorgeFill(r, flipped, 1, 0, 0, w, h, GeorgeGray(0xE7));
  GeorgeFill(r, flipped, 1, 1, 1, w - 2, h - 2, GeorgeSchemeColor(6));
  GeorgeFill(r, flipped, 1, 1, 1, w - 2, 1, GeorgeGray(0xFF));
  GeorgeFill(r, flipped, 1, 1, 1, 1, h - 2, GeorgeGray(0xFF));
  GeorgeFill(r, flipped, 1, 1, h - 2, w - 2, 1, GeorgeGray(0x9A));
  GeorgeFill(r, flipped, 1, w - 2, 1, 1, h - 2, GeorgeGray(0x9A));

  for (i = 0; i < 3; i++)
    {
      if (horizontal)
        {
          CGFloat x = floor(w / 2.0) - 3 + i * 2;
          GeorgeFill(r, flipped, 1, x, 4, 1, h - 8, GeorgeSchemeColor(3));
        }
      else
        {
          CGFloat y = floor(h / 2.0) - 3 + i * 2;
          GeorgeFill(r, flipped, 1, 4, y, w - 8, 1, GeorgeSchemeColor(3));
        }
    }
}

- (void)drawScrollSlotInRect:(NSRect)frame
                           flipped:(BOOL)flipped
                        horizontal:(BOOL)horizontal
{
  NSRect r = NSIntegralRect(frame);
  CGFloat w = NSWidth(r), h = NSHeight(r);

  GeorgeFill(r, flipped, 1, 0, 0, w, h, GeorgeGray(0xD7));
  if (horizontal)
    {
      GeorgeFill(r, flipped, 1, 0, 0, w, 1, GeorgeGray(0x88));
      GeorgeFill(r, flipped, 1, 0, h - 1, w, 1, GeorgeGray(0x9A));
    }
  else
    {
      GeorgeFill(r, flipped, 1, 0, 0, 1, h, GeorgeGray(0x88));
      GeorgeFill(r, flipped, 1, w - 1, 0, 1, h, GeorgeGray(0x9A));
    }
}

#pragma mark - Checkbox and radio artwork

static const NSInteger GeorgeDisc[12][2] = {
  {4, 7}, {2, 9}, {1, 10}, {1, 10}, {0, 11}, {0, 11},
  {0, 11}, {0, 11}, {1, 10}, {1, 10}, {2, 9}, {4, 7}
};

static NSInteger GeorgeDiscGray(NSInteger x, NSInteger y)
{
  NSInteger step = (x + y - 6) / 2;
  if (step <= 0)
    return 0xFF;
  return MAX(0x88, 0xFF - 0x11 * step);
}

- (void)drawBoxWellInRect:(NSRect)box oval:(BOOL)oval
{
  CGFloat s = GeorgeBoxSize;
  NSInteger x, y;

  if (oval)
    {
      for (y = 0; y < 12; y++)
        {
          for (x = GeorgeDisc[y][0]; x <= GeorgeDisc[y][1]; x++)
            {
              BOOL rim = (x == GeorgeDisc[y][0] || x == GeorgeDisc[y][1]
                          || y == 0 || y == 11
                          || x < GeorgeDisc[y - 1][0] || x > GeorgeDisc[y - 1][1]
                          || x < GeorgeDisc[y + 1][0] || x > GeorgeDisc[y + 1][1]);

              GeorgeFill(box, NO, 1, x, y, 1, 1,
                                GeorgeGray(rim ? 0x6B : GeorgeDiscGray(x, y)));
            }
        }
      return;
    }

  GeorgeFill(box, NO, 1, 0, 0, s, s, GeorgeGray(0x00));
  GeorgeFill(box, NO, 1, 1, 1, s - 2, s - 2, GeorgeGray(0xF0));
  GeorgeFill(box, NO, 1, 1, 1, s - 2, 1, GeorgeGray(0xFF));
  GeorgeFill(box, NO, 1, 1, 1, 1, s - 2, GeorgeGray(0xFF));
  GeorgeFill(box, NO, 1, 2, s - 2, s - 3, 1, GeorgeGray(0x8A));
  GeorgeFill(box, NO, 1, s - 2, 2, 1, s - 3, GeorgeGray(0x8A));
}

- (void)drawDiscMarkInRect:(NSRect)box
{
  NSInteger y;

  for (y = 3; y < 9; y++)
    GeorgeFill(box, NO, 1, GeorgeDisc[y][0] + 2, y,
                      GeorgeDisc[y][1] - GeorgeDisc[y][0] - 3, 1,
                      GeorgeGray(0x00));
}

- (void)drawCheckMarkInRect:(NSRect)box
{
  static const CGFloat strokes[][3] = {
    {2, 6, 2}, {3, 7, 2}, {4, 8, 2}, {5, 8, 1}, {6, 7, 1},
    {6, 6, 2}, {7, 5, 2}, {8, 4, 2}, {9, 3, 2}, {10, 2, 2}
  };
  const NSUInteger count = sizeof(strokes) / sizeof(strokes[0]);
  NSUInteger i;

  for (i = 0; i < count; i++)
    GeorgeFill(box, NO, 1, strokes[i][0], strokes[i][1],
                      strokes[i][2], 1, GeorgeGray(0x00));
}

- (void)drawArrowInRep:(id)rep direction:(NSInteger)direction
{
  NSSize size = [rep size];
  NSRect box = NSMakeRect(0, 0, size.width, size.height);
  CGFloat cx = floor(size.width / 2.0), cy = floor(size.height / 2.0);
  NSInteger steps = MAX(2, (NSInteger)floor(MIN(size.width / 2.0, size.height)));
  NSInteger i;

  for (i = 0; i < steps; i++)
    {
      switch (direction)
        {
          case 0: GeorgeFill(box, NO, 1, cx - i - 1, cy - steps / 2 + i, 2 * i + 2, 1, GeorgeGray(0x00)); break;
          case 1: GeorgeFill(box, NO, 1, cx - steps + i, cy - steps / 2 + i, 2 * (steps - i), 1, GeorgeGray(0x00)); break;
          case 2: GeorgeFill(box, NO, 1, cx - steps / 2 + i, cy - i - 1, 1, 2 * i + 2, GeorgeGray(0x00)); break;
          default: GeorgeFill(box, NO, 1, cx - steps / 2 + i, cy - steps + i, 1, 2 * (steps - i), GeorgeGray(0x00)); break;
        }
    }
}

- (void)platinumDrawArrowUp:(id)rep { [self drawArrowInRep: rep direction: 0]; }
- (void)platinumDrawArrowDown:(id)rep { [self drawArrowInRep: rep direction: 1]; }
- (void)platinumDrawArrowLeft:(id)rep { [self drawArrowInRep: rep direction: 2]; }
- (void)platinumDrawArrowRight:(id)rep { [self drawArrowInRep: rep direction: 3]; }

- (void)platinumDrawSwitchOff:(id)rep
{
  [self drawBoxWellInRect: [self boxRectForRep: rep] oval: NO];
}

- (void)platinumDrawSwitchOn:(id)rep
{
  NSRect box = [self boxRectForRep: rep];
  [self drawBoxWellInRect: box oval: NO];
  [self drawCheckMarkInRect: box];
}

- (void)platinumDrawRadioOff:(id)rep
{
  [self drawBoxWellInRect: [self boxRectForRep: rep] oval: YES];
}

- (void)platinumDrawRadioOn:(id)rep
{
  NSRect box = [self boxRectForRep: rep];
  [self drawBoxWellInRect: box oval: YES];
  [self drawDiscMarkInRect: box];
}

- (NSRect)boxRectForRep:(id)rep
{
  NSSize size = [rep size];
  return NSMakeRect(round((size.width - GeorgeBoxSize) / 2.0),
                    round((size.height - GeorgeBoxSize) / 2.0),
                    GeorgeBoxSize, GeorgeBoxSize);
}

- (NSImage *)imageWithSize:(NSSize)size drawSelector:(SEL)selector
{
  NSCustomImageRep *rep = [[NSCustomImageRep alloc] initWithDrawSelector: selector
                                                                 delegate: self];
  NSImage *image = [[NSImage alloc] initWithSize: size];

  [rep setSize: size];
  [image addRepresentation: rep];
  RELEASE(rep);
  return AUTORELEASE(image);
}

- (void)registerControlImages
{
  NSDictionary *drawing = @{
    @"common_SwitchOff": [NSValue valueWithPointer: @selector(platinumDrawSwitchOff:)],
    @"common_SwitchOn": [NSValue valueWithPointer: @selector(platinumDrawSwitchOn:)],
    @"common_RadioOff": [NSValue valueWithPointer: @selector(platinumDrawRadioOff:)],
    @"common_RadioOn": [NSValue valueWithPointer: @selector(platinumDrawRadioOn:)],
    @"common_3DArrowUp": [NSValue valueWithPointer: @selector(platinumDrawArrowUp:)],
    @"common_3DArrowDown": [NSValue valueWithPointer: @selector(platinumDrawArrowDown:)],
    @"common_3DArrowLeft": [NSValue valueWithPointer: @selector(platinumDrawArrowLeft:)],
    @"common_3DArrowRight": [NSValue valueWithPointer: @selector(platinumDrawArrowRight:)]
  };
  NSEnumerator *names = [drawing keyEnumerator];
  NSString *name;

  while ((name = [names nextObject]) != nil)
    {
      NSImage *old = [NSImage imageNamed: name];
      NSSize size = old ? [old size] : NSMakeSize(18, 18);
      NSImage *image = [self imageWithSize: size
                                   drawSelector: [[drawing objectForKey: name] pointerValue]];

      GeorgeRegisterImage(image, name);
    }
}

#pragma mark - Wells, panels and grooves

- (void)drawDefaultRingInRect:(NSRect)frame
{
  NSGraphicsContext *context = [NSGraphicsContext currentContext];
  BOOL antialias = [context shouldAntialias];
  NSRect r = NSInsetRect(NSIntegralRect(frame), 1.5, 1.5);
  NSBezierPath *ring;

  if (NSWidth(r) < 8 || NSHeight(r) < 8)
    return;

  ring = [NSBezierPath bezierPathWithRoundedRect: r xRadius: 4.0 yRadius: 4.0];
  [context setShouldAntialias: NO];
  [GeorgeGray(0x60) set];
  [ring setLineWidth: 2.0];
  [ring stroke];
  [context setShouldAntialias: antialias];
}

- (void)drawDefaultOutlineInRect:(NSRect)frame flipped:(BOOL)flipped
{
  NSRect r = NSIntegralRect(frame);
  CGFloat w = NSWidth(r), h = NSHeight(r);
  NSColor *edge = GeorgeGray(0x60);

  if (w < 12 || h < 12)
    return;

#define EDGE(x_, y_, w_, h_) GeorgeFill(r, flipped, 1, x_, y_, w_, h_, edge)
  EDGE(1, 1, w - 2, 1);
  EDGE(1, h - 2, w - 2, 1);
  EDGE(1, 1, 1, h - 2);
  EDGE(w - 2, 1, 1, h - 2);
#undef EDGE
}

- (void)drawBevelButtonInRect:(NSRect)frame
                            flipped:(BOOL)flipped
                            pressed:(BOOL)pressed
                            enabled:(BOOL)enabled
{
  NSRect r = NSIntegralRect(frame);
  CGFloat w = NSWidth(r), h = NSHeight(r);
  NSColor *face = GeorgeGray(pressed ? 0xD7 : 0xF1);
  NSColor *edge = GeorgeGray(enabled ? 0x5E : 0x88);
  NSColor *shadow = GeorgeGray(pressed ? 0x9A : 0xBB);
  NSColor *highlight = GeorgeGray(pressed ? 0xF1 : 0xFF);

  if (w < 6 || h < 6)
    return;

#define BEVEL(x_, y_, w_, h_, c) GeorgeFill(r, flipped, 1, x_, y_, w_, h_, c)
  BEVEL(0, 0, w, 1, edge);
  BEVEL(0, h - 1, w, 1, shadow);
  BEVEL(0, 0, 1, h, edge);
  BEVEL(w - 1, 0, 1, h, shadow);
  BEVEL(1, 1, w - 2, h - 2, face);
  BEVEL(1, 1, w - 2, 1, highlight);
  BEVEL(1, 1, 1, h - 2, highlight);
  BEVEL(2, h - 2, w - 3, 1, shadow);
  BEVEL(w - 2, 2, 1, h - 3, shadow);
#undef BEVEL
}

- (void)drawWellInRect:(NSRect)frame flipped:(BOOL)flipped fill:(NSColor *)fill
{
  NSRect r = NSIntegralRect(frame);
  CGFloat w = NSWidth(r), h = NSHeight(r);

  if (w < 4 || h < 4)
    return;

  GeorgeFill(r, flipped, 1, 0, 0, w, h, GeorgeGray(0xE8));
  GeorgeFill(r, flipped, 1, 1, 1, w - 2, h - 2, fill ? fill : GeorgeGray(0xF5));
  GeorgeFill(r, flipped, 1, 1, 1, w - 2, 1, GeorgeGray(0xFF));
  GeorgeFill(r, flipped, 1, 1, 1, 1, h - 2, GeorgeGray(0xFF));
  GeorgeFill(r, flipped, 1, 1, h - 2, w - 2, 1, GeorgeGray(0xA5));
  GeorgeFill(r, flipped, 1, w - 2, 1, 1, h - 2, GeorgeGray(0xA5));
}

- (void)drawRaisedPanelInRect:(NSRect)frame flipped:(BOOL)flipped pressed:(BOOL)pressed
{
  NSRect r = NSIntegralRect(frame);
  CGFloat w = NSWidth(r), h = NSHeight(r);

  if (w < 3 || h < 3)
    return;

  GeorgeFill(r, flipped, 1, 0, 0, w, h, GeorgeGray(pressed ? 0xD7 : 0xEF));
  GeorgeFill(r, flipped, 1, 0, 0, w, 1, GeorgeGray(0xFF));
  GeorgeFill(r, flipped, 1, 0, 0, 1, h, GeorgeGray(0xFF));
  GeorgeFill(r, flipped, 1, 0, h - 1, w, 1, GeorgeGray(0x9A));
  GeorgeFill(r, flipped, 1, w - 1, 0, 1, h, GeorgeGray(0x9A));
}

- (void)drawGrooveInRect:(NSRect)frame flipped:(BOOL)flipped
{
  NSRect r = NSIntegralRect(frame);
  CGFloat w = NSWidth(r), h = NSHeight(r);

  if (w < 3 || h < 3)
    return;

  GeorgeFill(r, flipped, 1, 0, 0, w, 1, GeorgeGray(0x88));
  GeorgeFill(r, flipped, 1, 0, h - 1, w, 1, GeorgeGray(0x9A));
  GeorgeFill(r, flipped, 1, 0, 0, 1, h, GeorgeGray(0x88));
  GeorgeFill(r, flipped, 1, w - 1, 0, 1, h, GeorgeGray(0x9A));
}

- (void)drawSliderKnobInRect:(NSRect)frame flipped:(BOOL)flipped pressed:(BOOL)pressed
{
  NSRect r = NSIntegralRect(frame);
  CGFloat w = NSWidth(r), h = NSHeight(r);

  if (w < 6 || h < 6)
    return;

  GeorgeFill(r, flipped, 1, 0, 0, w, h, GeorgeGray(pressed ? 0xD7 : 0xF1));
  GeorgeFill(r, flipped, 1, 0, 0, w, 1, GeorgeGray(0xFF));
  GeorgeFill(r, flipped, 1, 0, 0, 1, h, GeorgeGray(0xFF));
  GeorgeFill(r, flipped, 1, 0, h - 1, w, 1, GeorgeGray(0x9A));
  GeorgeFill(r, flipped, 1, w - 1, 0, 1, h, GeorgeGray(0x9A));

  if (w > h)
    {
      GeorgeFill(r, flipped, 1, floor(w / 2.0), 3, 1, h - 6, GeorgeSchemeColor(3));
      GeorgeFill(r, flipped, 1, floor(w / 2.0) - 1, 3, 1, h - 6, GeorgeSchemeColor(6));
    }
  else
    {
      GeorgeFill(r, flipped, 1, 3, floor(h / 2.0), w - 6, 1, GeorgeSchemeColor(3));
      GeorgeFill(r, flipped, 1, 3, floor(h / 2.0) - 1, w - 6, 1, GeorgeSchemeColor(6));
    }
}

- (void)drawGrowBoxInRect:(NSRect)frame flipped:(BOOL)flipped
{
  NSRect r = NSIntegralRect(frame);
  CGFloat w = NSWidth(r), h = NSHeight(r);
  CGFloat size = MIN(w, h);

  if (size < 9)
    return;

  GeorgeFill(r, flipped, 1, 0, 0, size, size, GeorgeGray(0xF1));
  GeorgeFill(r, flipped, 1, 0, 0, size, 1, GeorgeGray(0xFF));
  GeorgeFill(r, flipped, 1, 0, 0, 1, size, GeorgeGray(0xFF));
  GeorgeFill(r, flipped, 1, 0, size - 1, size, 1, GeorgeGray(0x9A));
  GeorgeFill(r, flipped, 1, size - 1, 0, 1, size, GeorgeGray(0x9A));

  GeorgeFill(r, flipped, 1, 3, 3, size - 7, 1, GeorgeGray(0x5E));
  GeorgeFill(r, flipped, 1, 3, 3, 1, size - 7, GeorgeGray(0x5E));
  GeorgeFill(r, flipped, 1, 5, 5, size - 11, 1, GeorgeGray(0x88));
  GeorgeFill(r, flipped, 1, 5, 5, 1, size - 11, GeorgeGray(0x88));
}

- (void)drawBarberPoleInRect:(NSRect)frame flipped:(BOOL)flipped phase:(NSInteger)phase
{
  NSRect r = NSIntegralRect(frame);
  CGFloat w = NSWidth(r), h = NSHeight(r);
  NSInteger x, y;

  GeorgeFill(r, flipped, 1, 0, 0, w, h, GeorgeSchemeColor(4));
  for (y = 0; y < (NSInteger)h; y++)
    {
      NSInteger start = ((-y - phase) % 8 + 8) % 8;

      for (x = start - 8; x < (NSInteger)w; x += 8)
        {
          NSInteger from = MAX(x, 0);
          NSInteger to = MIN(x + 4, (NSInteger)w);

          if (to > from)
            GeorgeFill(r, flipped, 1, from, y, to - from, 1, GeorgeSchemeColor(3));
        }
    }
}

@end
