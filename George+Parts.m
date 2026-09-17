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
  NSColor *face = GeorgeGray(pressed ? 0x66 : 0xDD);
  NSColor *edge = GeorgeGray(enabled ? 0x00 : 0x88);
  NSColor *corner = GeorgeGray(enabled ? 0x22 : 0x88);

  if (w < 8 || h < 8)
    return;

#define FILL(x_, y_, w_, h_, c) GeorgeFill(r, flipped, 1, x_, y_, w_, h_, c)
  FILL(1, 1, w - 2, h - 2, face);

  // Outline: square with the corners cut back one pixel per row, the way a
  // four pixel radius comes out in Platinum.
  FILL(3, 0, w - 6, 1, edge);
  FILL(3, h - 1, w - 6, 1, edge);
  FILL(0, 3, 1, h - 6, edge);
  FILL(w - 1, 3, 1, h - 6, edge);
  FILL(1, 1, 2, 1, edge);      FILL(w - 3, 1, 2, 1, edge);
  FILL(1, h - 2, 2, 1, edge);  FILL(w - 3, h - 2, 2, 1, edge);
  FILL(1, 2, 1, 1, edge);      FILL(w - 2, 2, 1, 1, edge);
  FILL(1, h - 3, 1, 1, edge);  FILL(w - 2, h - 3, 1, 1, edge);
  FILL(2, 0, 1, 1, corner);    FILL(w - 3, 0, 1, 1, corner);
  FILL(0, 2, 1, 1, corner);    FILL(w - 1, 2, 1, 1, corner);
  FILL(2, h - 1, 1, 1, corner); FILL(w - 3, h - 1, 1, 1, corner);
  FILL(0, h - 3, 1, 1, corner); FILL(w - 1, h - 3, 1, 1, corner);

  // A disabled button is just the gray outline on the face, with no bevel.
  if (!enabled)
    {
      return;
    }

  // Two bevel rings inside the outline: lit from the top left when the
  // button is up, sunken when it is pressed.
  NSColor *outerLight = GeorgeGray(pressed ? 0x44 : 0xDD);
  NSColor *outerShade = GeorgeGray(pressed ? 0x88 : 0x77);
  NSColor *innerLight = GeorgeGray(pressed ? 0x55 : 0xFF);
  NSColor *innerShade = GeorgeGray(pressed ? 0x77 : 0xAA);

  FILL(3, 1, w - 6, 1, outerLight);
  FILL(1, 3, 1, h - 6, outerLight);
  FILL(3, h - 2, w - 6, 1, outerShade);
  FILL(w - 2, 3, 1, h - 6, outerShade);
  FILL(2, 2, w - 5, 1, innerLight);
  FILL(2, 3, 1, h - 6, innerLight);
  // The lit corner belongs to the outer ring once the bevel is sunken.
  FILL(3, 3, 1, 1, pressed ? outerLight : innerLight);
  FILL(3, h - 3, w - 6, 1, innerShade);
  FILL(w - 3, 3, 1, h - 6, innerShade);
  FILL(w - 4, h - 4, 1, 1, innerShade);
  // Where the cut corners meet the bevel the outline stays black, the bevel
  // gives way to the face, and the shadow turns the bottom right corner.
  FILL(w - 2, 1, 1, 1, edge);
  FILL(1, h - 2, 1, 1, edge);
  FILL(w - 3, 2, 1, 1, face);
  FILL(2, h - 3, 1, 1, face);
  FILL(w - 3, h - 3, 1, 1, outerShade);
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
  NSColor *face = GeorgeGray(pressed ? 0x77 : 0xDD);
  NSColor *light = GeorgeGray(pressed ? 0x55 : 0xFF);
  NSColor *shade = GeorgeGray(pressed ? 0x99 : 0xAA);
  NSColor *glyph = GeorgeGray(enabled ? 0x00 : 0x77);
  CGFloat cx = floor(w / 2.0), cy = floor(h / 2.0);
  NSInteger i;

  if (w < 6 || h < 6)
    return;
  GeorgeFill(r, flipped, 1, 0, 0, w, h, GeorgeGray(0x00));
  GeorgeFill(r, flipped, 1, 1, 1, w - 2, h - 2, face);
  GeorgeFill(r, flipped, 1, 1, 1, w - 3, 1, light);
  GeorgeFill(r, flipped, 1, 1, 1, 1, h - 3, light);
  GeorgeFill(r, flipped, 1, 2, h - 2, w - 3, 1, shade);
  GeorgeFill(r, flipped, 1, w - 2, 2, 1, h - 3, shade);

  // Solid triangle, two pixels taller on each step.
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
  GeorgeFill(r, flipped, 1, 0, 0, w, h, GeorgeGray(0x00));
  GeorgeFill(r, flipped, 1, 1, 1, w - 2, h - 2, GeorgeSchemeColor(4));
  GeorgeFill(r, flipped, 1, 1, 1, w - 3, 1, GeorgeSchemeColor(5));
  GeorgeFill(r, flipped, 1, 1, 1, 1, h - 3, GeorgeSchemeColor(5));
  GeorgeFill(r, flipped, 1, 2, h - 2, w - 3, 1, GeorgeSchemeColor(3));
  GeorgeFill(r, flipped, 1, w - 2, 2, 1, h - 3, GeorgeSchemeColor(3));

  // Four grip lines across the middle, each lit on its light side.
  for (i = 0; i < 4; i++)
    {
      if (horizontal)
        {
          CGFloat x = floor(w / 2.0) - 4 + i * 2;

          if (x < 4 || x > w - 5)
            continue;
          GeorgeFill(r, flipped, 1, x, 4, 1, h - 8, GeorgeSchemeColor(2));
          GeorgeFill(r, flipped, 1, x - 1, 4, 1, h - 8, GeorgeSchemeColor(6));
        }
      else
        {
          CGFloat y = floor(h / 2.0) - 4 + i * 2;

          if (y < 4 || y > h - 5)
            continue;
          GeorgeFill(r, flipped, 1, 4, y, w - 8, 1, GeorgeSchemeColor(2));
          GeorgeFill(r, flipped, 1, 4, y - 1, w - 8, 1, GeorgeSchemeColor(6));
        }
    }
}

- (void)drawScrollSlotInRect:(NSRect)frame
                          flipped:(BOOL)flipped
                       horizontal:(BOOL)horizontal
{
  NSRect r = NSIntegralRect(frame);
  CGFloat w = NSWidth(r), h = NSHeight(r);

  GeorgeFill(r, flipped, 1, 0, 0, w, h, GeorgeGray(0xCC));
  // The track keeps the black edges the arrow buttons have on their long sides.
  if (horizontal)
    {
      GeorgeFill(r, flipped, 1, 0, 0, w, 1, GeorgeGray(0x00));
      GeorgeFill(r, flipped, 1, 0, h - 1, w, 1, GeorgeGray(0x00));
    }
  else
    {
      GeorgeFill(r, flipped, 1, 0, 0, 1, h, GeorgeGray(0x00));
      GeorgeFill(r, flipped, 1, w - 1, 0, 1, h, GeorgeGray(0x00));
    }
}

#pragma mark - Checkbox and radio artwork

/* The pixels of the twelve pixel disc a radio button is, as the first and
 * last column of each of its rows. */
static const NSInteger GeorgeDisc[12][2] = {
  {4, 7}, {2, 9}, {1, 10}, {1, 10}, {0, 11}, {0, 11},
  {0, 11}, {0, 11}, {1, 10}, {1, 10}, {2, 9}, {4, 7}
};

/* Platinum lights a radio button like a sphere: brightest along the band
 * just above its centre, falling away towards the bottom right. */
static NSInteger GeorgeDiscGray(NSInteger x, NSInteger y)
{
  NSInteger step = (x + y - 6) / 2;

  if (step <= 0)
    return 0xFF;
  return MAX(0x88, 0xFF - 0x11 * step);
}

/* Sunken well the checkbox and radio sit in: black edge, light top left,
 * dark bottom right, on the control gray. */
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
                                GeorgeGray(rim ? 0x00 : GeorgeDiscGray(x, y)));
            }
        }
      return;
    }

  GeorgeFill(box, NO, 1, 0, 0, s, s, GeorgeGray(0x00));
  GeorgeFill(box, NO, 1, 1, 1, s - 2, s - 2, GeorgeGray(0xDD));
  GeorgeFill(box, NO, 1, 1, 1, s - 3, 1, GeorgeGray(0xFF));
  GeorgeFill(box, NO, 1, 1, 1, 1, s - 3, GeorgeGray(0xFF));
  GeorgeFill(box, NO, 1, 2, s - 2, s - 3, 1, GeorgeGray(0x88));
  GeorgeFill(box, NO, 1, s - 2, 2, 1, s - 3, GeorgeGray(0x88));
}

/* The mark of a chosen radio button: the middle of the disc, three rows in. */
- (void)drawDiscMarkInRect:(NSRect)box
{
  NSInteger y;

  for (y = 3; y < 9; y++)
    GeorgeFill(box, NO, 1, GeorgeDisc[y][0] + 3, y,
                      GeorgeDisc[y][1] - GeorgeDisc[y][0] - 5, 1,
                      GeorgeGray(0x00));
}

/* Platinum check mark: a short stroke down to the foot and a long one up to
 * the right, embossed with a lighter copy one pixel down and right. It leans
 * past the top right corner of the box, the way Platinum's does. */
- (void)drawCheckMarkInRect:(NSRect)box
{
  static const CGFloat strokes[][3] = {          /* x, y, width */
    {2, 5, 2}, {3, 6, 2}, {4, 7, 2}, {5, 8, 1}, {6, 7, 1},
    {6, 6, 2}, {7, 5, 2}, {8, 4, 2}, {9, 3, 2}, {10, 2, 2}
  };
  const NSUInteger count = sizeof(strokes) / sizeof(strokes[0]);
  NSUInteger i;

  for (i = 0; i < count; i++)
    GeorgeFill(box, NO, 1, strokes[i][0] + 1, strokes[i][1] + 1,
                      strokes[i][2], 1, GeorgeGray(0xAA));
  // The emboss leans out over the box outline, which stays unbroken.
  GeorgeFill(box, NO, 1, NSWidth(box) - 1, 1, 1, NSHeight(box) - 2,
                    GeorgeGray(0x00));
  for (i = 0; i < count; i++)
    GeorgeFill(box, NO, 1, strokes[i][0], strokes[i][1],
                      strokes[i][2], 1, GeorgeGray(0x00));
}

/* Platinum arrows for popup buttons and submenus: a solid triangle that
 * grows two pixels per step, the same shape as the scroll bar arrows. */
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
      // Several names map onto one registered image name (NSSwitch and
      // common_SwitchOff both resolve to GSSwitch), so take the name the
      // image is actually registered under; anything else is never found.
      // Copied, because unregistering the old image is what releases it, and
      // the name belongs to it.
      NSString *registered = AUTORELEASE([([old name] ? [old name] : name) copy]);

      [old setName: nil];
      [image setName: registered];
    }
}

#pragma mark - Wells, panels and grooves

- (void)drawDefaultRingInRect:(NSRect)frame
{
  NSGraphicsContext *context = [NSGraphicsContext currentContext];
  BOOL antialias = [context shouldAntialias];
  // Stroked on the pixel centre so the three pixel line lands on whole pixels.
  NSRect r = NSInsetRect(NSIntegralRect(frame), 1.5, 1.5);
  NSBezierPath *ring;

  if (NSWidth(r) < 8 || NSHeight(r) < 8)
    return;
  ring = [NSBezierPath bezierPathWithRoundedRect: r xRadius: 6.0 yRadius: 6.0];
  [context setShouldAntialias: NO];
  [GeorgeGray(0x00) set];
  [ring setLineWidth: 3.0];
  [ring stroke];
  [context setShouldAntialias: antialias];
}

- (void)drawDefaultOutlineInRect:(NSRect)frame flipped:(BOOL)flipped
{
  NSRect r = NSIntegralRect(frame);
  CGFloat w = NSWidth(r), h = NSHeight(r);
  NSColor *edge = GeorgeGray(0x00);

  if (w < 12 || h < 12)
    return;
  // A second outline one pixel inside the first, following the same cut
  // corners, so the button reads as the default one without growing.
#define EDGE(x_, y_, w_, h_) GeorgeFill(r, flipped, 1, x_, y_, w_, h_, edge)
  EDGE(3, 1, w - 6, 1);
  EDGE(3, h - 2, w - 6, 1);
  EDGE(1, 3, 1, h - 6);
  EDGE(w - 2, 3, 1, h - 6);
  EDGE(2, 2, 1, 1);
  EDGE(w - 3, 2, 1, 1);
  EDGE(2, h - 3, 1, 1);
  EDGE(w - 3, h - 3, 1, 1);
#undef EDGE
}

- (void)drawBevelButtonInRect:(NSRect)frame
                           flipped:(BOOL)flipped
                           pressed:(BOOL)pressed
                           enabled:(BOOL)enabled
{
  NSRect r = NSIntegralRect(frame);
  CGFloat w = NSWidth(r), h = NSHeight(r);
  NSColor *face = GeorgeGray(pressed ? 0x66 : 0xDD);
  NSColor *edge = GeorgeGray(enabled ? 0x00 : 0x88);
  NSColor *outerLight = GeorgeGray(pressed ? 0x44 : 0xDD);
  NSColor *outerShade = GeorgeGray(pressed ? 0x88 : 0x77);
  NSColor *innerLight = GeorgeGray(pressed ? 0x55 : 0xFF);
  NSColor *innerShade = GeorgeGray(pressed ? 0x77 : 0xAA);

  if (w < 6 || h < 6)
    return;

#define BEVEL(x_, y_, w_, h_, c) GeorgeFill(r, flipped, 1, x_, y_, w_, h_, c)
  BEVEL(0, 0, w, 1, edge);
  BEVEL(0, h - 1, w, 1, edge);
  BEVEL(0, 1, 1, h - 2, edge);
  BEVEL(w - 1, 1, 1, h - 2, edge);
  BEVEL(1, 1, w - 2, h - 2, face);

  if (!enabled)
    return;

  BEVEL(1, 1, w - 3, 1, outerLight);
  BEVEL(1, 1, 1, h - 3, outerLight);
  BEVEL(2, h - 2, w - 3, 1, outerShade);
  BEVEL(w - 2, 2, 1, h - 3, outerShade);
  BEVEL(2, 2, w - 5, 1, innerLight);
  BEVEL(2, 2, 1, h - 5, innerLight);
  BEVEL(3, h - 3, w - 5, 1, innerShade);
  BEVEL(w - 3, 3, 1, h - 5, innerShade);
#undef BEVEL
}

- (void)drawWellInRect:(NSRect)frame flipped:(BOOL)flipped fill:(NSColor *)fill
{
  NSRect r = NSIntegralRect(frame);
  CGFloat w = NSWidth(r), h = NSHeight(r);

  if (w < 4 || h < 4)
    return;
  GeorgeFill(r, flipped, 1, 0, 0, w, h, GeorgeGray(0x00));
  GeorgeFill(r, flipped, 1, 1, 1, w - 2, h - 2, fill ? fill : GeorgeGray(0xFF));
  // Sunken: shaded along the top and left, lit along the bottom and right.
  GeorgeFill(r, flipped, 1, 1, 1, w - 3, 1, GeorgeGray(0x88));
  GeorgeFill(r, flipped, 1, 1, 1, 1, h - 3, GeorgeGray(0x88));
  GeorgeFill(r, flipped, 1, 2, h - 2, w - 3, 1, GeorgeGray(0xFF));
  GeorgeFill(r, flipped, 1, w - 2, 2, 1, h - 3, GeorgeGray(0xFF));
}

- (void)drawRaisedPanelInRect:(NSRect)frame flipped:(BOOL)flipped pressed:(BOOL)pressed
{
  NSRect r = NSIntegralRect(frame);
  CGFloat w = NSWidth(r), h = NSHeight(r);

  if (w < 3 || h < 3)
    return;
  GeorgeFill(r, flipped, 1, 0, 0, w, h, GeorgeGray(pressed ? 0xAA : 0xDD));
  GeorgeFill(r, flipped, 1, 0, 0, w - 1, 1, GeorgeGray(pressed ? 0x88 : 0xFF));
  GeorgeFill(r, flipped, 1, 0, 0, 1, h - 1, GeorgeGray(pressed ? 0x88 : 0xFF));
  GeorgeFill(r, flipped, 1, 1, h - 1, w - 1, 1, GeorgeGray(pressed ? 0xFF : 0x88));
  GeorgeFill(r, flipped, 1, w - 1, 1, 1, h - 1, GeorgeGray(pressed ? 0xFF : 0x88));
}

- (void)drawGrooveInRect:(NSRect)frame flipped:(BOOL)flipped
{
  NSRect r = NSIntegralRect(frame);
  CGFloat w = NSWidth(r), h = NSHeight(r);

  if (w < 3 || h < 3)
    return;
  // A groove is a dark line with a light line below and to its right.
  GeorgeFill(r, flipped, 1, 0, 0, w - 1, 1, GeorgeGray(0x88));
  GeorgeFill(r, flipped, 1, 0, 0, 1, h - 1, GeorgeGray(0x88));
  GeorgeFill(r, flipped, 1, 1, 1, w - 2, 1, GeorgeGray(0xFF));
  GeorgeFill(r, flipped, 1, 1, 1, 1, h - 2, GeorgeGray(0xFF));
  GeorgeFill(r, flipped, 1, 1, h - 1, w - 1, 1, GeorgeGray(0xFF));
  GeorgeFill(r, flipped, 1, w - 1, 1, 1, h - 1, GeorgeGray(0xFF));
  GeorgeFill(r, flipped, 1, 1, h - 2, w - 2, 1, GeorgeGray(0x88));
  GeorgeFill(r, flipped, 1, w - 2, 1, 1, h - 2, GeorgeGray(0x88));
}

- (void)drawSliderKnobInRect:(NSRect)frame flipped:(BOOL)flipped pressed:(BOOL)pressed
{
  NSRect r = NSIntegralRect(frame);
  CGFloat w = NSWidth(r), h = NSHeight(r);

  if (w < 6 || h < 6)
    return;
  GeorgeFill(r, flipped, 1, 0, 0, w, h, GeorgeGray(0x00));
  GeorgeFill(r, flipped, 1, 1, 1, w - 2, h - 2, GeorgeGray(pressed ? 0x99 : 0xDD));
  GeorgeFill(r, flipped, 1, 1, 1, w - 3, 1, GeorgeGray(pressed ? 0x77 : 0xFF));
  GeorgeFill(r, flipped, 1, 1, 1, 1, h - 3, GeorgeGray(pressed ? 0x77 : 0xFF));
  GeorgeFill(r, flipped, 1, 2, h - 2, w - 3, 1, GeorgeGray(pressed ? 0xDD : 0x88));
  GeorgeFill(r, flipped, 1, w - 2, 2, 1, h - 3, GeorgeGray(pressed ? 0xDD : 0x88));
  // One grip line across the middle, like the scroll bar thumb has.
  if (w > h)
    {
      GeorgeFill(r, flipped, 1, floor(w / 2.0), 3, 1, h - 6, GeorgeGray(0x88));
      GeorgeFill(r, flipped, 1, floor(w / 2.0) - 1, 3, 1, h - 6, GeorgeGray(0xFF));
    }
  else
    {
      GeorgeFill(r, flipped, 1, 3, floor(h / 2.0), w - 6, 1, GeorgeGray(0x88));
      GeorgeFill(r, flipped, 1, 3, floor(h / 2.0) - 1, w - 6, 1, GeorgeGray(0xFF));
    }
}

- (void)drawGrowBoxInRect:(NSRect)frame flipped:(BOOL)flipped
{
  NSRect r = NSIntegralRect(frame);
  CGFloat w = NSWidth(r), h = NSHeight(r);
  CGFloat size = MIN(w, h);

  if (size < 9)
    return;
  // Two overlapping squares, the Platinum size box.
  GeorgeFill(r, flipped, 1, 0, 0, size, size, GeorgeGray(0xDD));
  GeorgeFill(r, flipped, 1, 0, 0, size - 4, size - 4, GeorgeGray(0xFF));
  GeorgeFill(r, flipped, 1, 1, 1, size - 6, size - 6, GeorgeGray(0xDD));
  GeorgeFill(r, flipped, 1, 4, 4, size - 4, size - 4, GeorgeGray(0xFF));
  GeorgeFill(r, flipped, 1, 5, 5, size - 6, size - 6, GeorgeGray(0xDD));
  GeorgeFill(r, flipped, 1, 0, 0, size - 4, 1, GeorgeGray(0x00));
  GeorgeFill(r, flipped, 1, 0, 0, 1, size - 4, GeorgeGray(0x00));
  GeorgeFill(r, flipped, 1, 4, 4, size - 4, 1, GeorgeGray(0x00));
  GeorgeFill(r, flipped, 1, 4, 4, 1, size - 4, GeorgeGray(0x00));
  GeorgeFill(r, flipped, 1, 4, size - 5, size - 4, 1, GeorgeGray(0x00));
  GeorgeFill(r, flipped, 1, size - 5, 4, 1, size - 4, GeorgeGray(0x00));
  GeorgeFill(r, flipped, 1, 0, size - 5, 5, 1, GeorgeGray(0x00));
  GeorgeFill(r, flipped, 1, size - 5, 0, 1, 5, GeorgeGray(0x00));
}

- (void)drawBarberPoleInRect:(NSRect)frame flipped:(BOOL)flipped phase:(NSInteger)phase
{
  NSRect r = NSIntegralRect(frame);
  CGFloat w = NSWidth(r), h = NSHeight(r);
  NSInteger x, y;

  GeorgeFill(r, flipped, 1, 0, 0, w, h, GeorgeSchemeColor(4));
  // Diagonal stripes that travel one pixel per phase step. Each row is a run
  // of four lit pixels every eight, so the row is filled a stripe at a time
  // rather than a pixel at a time: an indeterminate bar redraws many times a
  // second and one fill per pixel is far too much work for that.
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
