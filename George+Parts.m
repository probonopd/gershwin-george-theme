/*
 * Copyright (c) 2026 Simon Peter
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

/* The Platinum parts: push buttons, checkboxes, radio buttons, scroll bar
 * pieces, wells, panels and grooves in the shapes and grays that Aaron's
 * control definitions draw. */

#import "George+Parts.h"
#import "GeorgeControlImage.h"
#import "GeorgePlatinum.h"

// Aaron draws checkboxes and radio buttons 12 pixels square.
static const CGFloat GeorgeBoxSize = 12.0;
// How much darker a held radio button's sphere gets, keeping its shading.
static const NSInteger GeorgeHeldDarkening = 0x55;

@interface George (PartsPrivate)
- (void)drawBoxWellInRect:(NSRect)box
                  flipped:(BOOL)flipped
                     oval:(BOOL)oval
                     look:(GeorgeToggleLook)look;
- (void)drawCheckMarkInRect:(NSRect)box flipped:(BOOL)flipped look:(GeorgeToggleLook)look;
- (void)drawDiscMarkInRect:(NSRect)box flipped:(BOOL)flipped look:(GeorgeToggleLook)look;
- (void)drawDashInRect:(NSRect)box flipped:(BOOL)flipped look:(GeorgeToggleLook)look;
- (void)drawArrowInRep:(id)rep direction:(NSInteger)direction;
- (NSImage *)imageWithSize:(NSSize)size drawSelector:(SEL)selector;
- (NSImage *)imageOfClass:(Class)imageClass
                     size:(NSSize)size
             drawSelector:(SEL)selector;
@end

/* A solid triangle of rows lines, one pixel wider on each side per line, its
 * tip on pixel (cx, y) for up and left and its base there for the others. The
 * odd widths keep it centered on a pixel, which arrows that share an axis need. */
static void GeorgeTriangle(NSRect r, BOOL flipped, CGFloat cx, CGFloat y,
                           NSInteger rows, NSInteger direction, NSColor *color)
{
  NSInteger i;

  for (i = 0; i < rows; i++)
    {
      NSInteger reach = (direction == 0 || direction == 2) ? i : rows - 1 - i;

      if (direction < 2)
        {
          GeorgeFill(r, flipped, 1, cx - reach, y + i, 2 * reach + 1, 1, color);
        }
      else
        {
          GeorgeFill(r, flipped, 1, cx + i, y - reach, 1, 2 * reach + 1, color);
        }
    }
}

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
                          pressed:(BOOL)pressed
{
  NSRect r = NSIntegralRect(frame);
  CGFloat w = NSWidth(r), h = NSHeight(r);
  // A held thumb moves one step down the scheme's ramp, so the darkening
  // follows whichever scheme is chosen.
  NSInteger shift = pressed ? 1 : 0;
  NSColor *face = GeorgeSchemeColor(4 - shift);
  NSColor *light = GeorgeSchemeColor(5 - shift);
  NSColor *shade = GeorgeSchemeColor(3 - shift);
  NSColor *gripDark = GeorgeSchemeColor(2 - shift);
  NSColor *gripLight = GeorgeSchemeColor(6 - shift);
  NSInteger i;

  if (w < 6 || h < 6)
    return;
  GeorgeFill(r, flipped, 1, 0, 0, w, h, GeorgeGray(0x00));
  GeorgeFill(r, flipped, 1, 1, 1, w - 2, h - 2, face);
  GeorgeFill(r, flipped, 1, 1, 1, w - 3, 1, light);
  GeorgeFill(r, flipped, 1, 1, 1, 1, h - 3, light);
  GeorgeFill(r, flipped, 1, 2, h - 2, w - 3, 1, shade);
  GeorgeFill(r, flipped, 1, w - 2, 2, 1, h - 3, shade);

  // Four grip lines across the middle, each lit on its light side.
  for (i = 0; i < 4; i++)
    {
      if (horizontal)
        {
          CGFloat x = floor(w / 2.0) - 4 + i * 2;

          if (x < 4 || x > w - 5)
            continue;
          GeorgeFill(r, flipped, 1, x, 4, 1, h - 8, gripDark);
          GeorgeFill(r, flipped, 1, x - 1, 4, 1, h - 8, gripLight);
        }
      else
        {
          CGFloat y = floor(h / 2.0) - 4 + i * 2;

          if (y < 4 || y > h - 5)
            continue;
          GeorgeFill(r, flipped, 1, 4, y, w - 8, 1, gripDark);
          GeorgeFill(r, flipped, 1, 4, y - 1, w - 8, 1, gripLight);
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
 * dark bottom right, on the control gray. Held it goes dark and the light
 * swaps sides; disabled it keeps only a gray outline, as a disabled push
 * button does. */
- (void)drawBoxWellInRect:(NSRect)box
                  flipped:(BOOL)flipped
                     oval:(BOOL)oval
                     look:(GeorgeToggleLook)look
{
  CGFloat s = GeorgeBoxSize;
  NSColor *edge = GeorgeGray(look.enabled ? 0x00 : 0x88);
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
              NSInteger gray = look.enabled ? GeorgeDiscGray(x, y) : 0xDD;

              if (look.pressed)
                {
                  gray -= GeorgeHeldDarkening;
                }
              GeorgeFill(box, flipped, 1, x, y, 1, 1, rim ? edge : GeorgeGray(gray));
            }
        }
      return;
    }

  GeorgeFill(box, flipped, 1, 0, 0, s, s, edge);
  GeorgeFill(box, flipped, 1, 1, 1, s - 2, s - 2, GeorgeGray(look.pressed ? 0x99 : 0xDD));
  if (!look.enabled)
    {
      return;
    }
  GeorgeFill(box, flipped, 1, 1, 1, s - 3, 1, GeorgeGray(look.pressed ? 0x77 : 0xFF));
  GeorgeFill(box, flipped, 1, 1, 1, 1, s - 3, GeorgeGray(look.pressed ? 0x77 : 0xFF));
  GeorgeFill(box, flipped, 1, 2, s - 2, s - 3, 1, GeorgeGray(look.pressed ? 0xBB : 0x88));
  GeorgeFill(box, flipped, 1, s - 2, 2, 1, s - 3, GeorgeGray(look.pressed ? 0xBB : 0x88));
}

/* The mark of a chosen radio button: the middle of the disc, three rows in. */
- (void)drawDiscMarkInRect:(NSRect)box flipped:(BOOL)flipped look:(GeorgeToggleLook)look
{
  NSColor *mark = GeorgeGray(look.enabled ? 0x00 : 0x88);
  NSInteger y;

  for (y = 3; y < 9; y++)
    {
      GeorgeFill(box, flipped, 1, GeorgeDisc[y][0] + 3, y,
                 GeorgeDisc[y][1] - GeorgeDisc[y][0] - 5, 1, mark);
    }
}

/* Platinum check mark: a short stroke down to the foot and a long one up to
 * the right, embossed with a lighter copy one pixel down and right. It leans
 * past the top right corner of the box, the way Platinum's does. */
- (void)drawCheckMarkInRect:(NSRect)box flipped:(BOOL)flipped look:(GeorgeToggleLook)look
{
  static const CGFloat strokes[][3] = {          /* x, y, width */
    {2, 5, 2}, {3, 6, 2}, {4, 7, 2}, {5, 8, 1}, {6, 7, 1},
    {6, 6, 2}, {7, 5, 2}, {8, 4, 2}, {9, 3, 2}, {10, 2, 2}
  };
  const NSUInteger count = sizeof(strokes) / sizeof(strokes[0]);
  NSColor *mark = GeorgeGray(look.enabled ? 0x00 : 0x88);
  NSUInteger i;

  if (look.enabled)
    {
      for (i = 0; i < count; i++)
        {
          GeorgeFill(box, flipped, 1, strokes[i][0] + 1, strokes[i][1] + 1,
                     strokes[i][2], 1, GeorgeGray(look.pressed ? 0x77 : 0xAA));
        }
    }
  // The emboss leans out over the box outline, which stays unbroken.
  GeorgeFill(box, flipped, 1, NSWidth(box) - 1, 1, 1, NSHeight(box) - 2, mark);
  for (i = 0; i < count; i++)
    {
      GeorgeFill(box, flipped, 1, strokes[i][0], strokes[i][1],
                 strokes[i][2], 1, mark);
    }
}

/* The dash of a mixed state, the same in a box and in a disc. */
- (void)drawDashInRect:(NSRect)box flipped:(BOOL)flipped look:(GeorgeToggleLook)look
{
  GeorgeFill(box, flipped, 1, 3, 5, 6, 2, GeorgeGray(look.enabled ? 0x00 : 0x88));
}

- (void)drawToggleInRect:(NSRect)frame
                 flipped:(BOOL)flipped
                    oval:(BOOL)oval
                    look:(GeorgeToggleLook)look
{
  NSRect r = NSIntegralRect(frame);
  NSRect box = NSMakeRect(NSMinX(r) + round((NSWidth(r) - GeorgeBoxSize) / 2.0),
                          NSMinY(r) + round((NSHeight(r) - GeorgeBoxSize) / 2.0),
                          GeorgeBoxSize, GeorgeBoxSize);

  [self drawBoxWellInRect: box flipped: flipped oval: oval look: look];
  if (look.mark == GeorgeToggleMarkMixed)
    {
      [self drawDashInRect: box flipped: flipped look: look];
    }
  else if (look.mark == GeorgeToggleMarkOn && oval)
    {
      [self drawDiscMarkInRect: box flipped: flipped look: look];
    }
  else if (look.mark == GeorgeToggleMarkOn)
    {
      [self drawCheckMarkInRect: box flipped: flipped look: look];
    }
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

/* The double triangle of a borderless pop-up, which has no box to hold it. */
- (void)platinumDrawNibble:(id)rep
{
  NSSize size = [rep size];
  NSRect box = NSMakeRect(0, 0, size.width, size.height);
  CGFloat cx = floor(size.width / 2.0);
  CGFloat cy = floor(size.height / 2.0);

  GeorgeTriangle(box, NO, cx, cy - 4, 3, 0, GeorgeGray(0x00));
  GeorgeTriangle(box, NO, cx, cy, 3, 1, GeorgeGray(0x00));
}

/* What a menu item shows when it is on. It sits in a seven pixel column GNUstep
 * sizes from the image, too small for the checkbox's embossed mark. */
- (void)platinumDrawMenuCheck:(id)rep
{
  static const CGFloat strokes[][3] = {          /* x, y, width */
    {5, 0, 2}, {5, 1, 2}, {4, 2, 2}, {0, 3, 2}, {3, 3, 2}, {1, 4, 4}, {2, 5, 2}, {2, 6, 1}
  };
  NSSize size = [rep size];
  NSRect box = NSMakeRect(0, 0, size.width, size.height);
  NSUInteger i;

  for (i = 0; i < sizeof(strokes) / sizeof(strokes[0]); i++)
    {
      GeorgeFill(box, NO, 1, strokes[i][0], strokes[i][1], strokes[i][2], 1,
                 GeorgeGray(0x00));
    }
}

- (void)platinumDrawMenuMixed:(id)rep
{
  NSSize size = [rep size];

  GeorgeFill(NSMakeRect(0, 0, size.width, size.height), NO, 1,
             1, floor(size.height / 2.0) - 1, size.width - 2, 2, GeorgeGray(0x00));
}

/* Lit like the scroll thumb so that the triangles follow the color scheme. */
- (void)drawDisclosureInRep:(id)rep expanded:(BOOL)expanded
{
  NSSize size = [rep size];
  NSRect box = NSMakeRect(0, 0, size.width, size.height);
  NSColor *edge = GeorgeGray(0x00);
  NSColor *face = GeorgeSchemeColor(4);
  NSInteger i;

  for (i = 0; i < 5; i++)
    {
      NSInteger span = 9 - 2 * i;
      NSInteger along = i + 2;

      if (expanded)
        {
          GeorgeFill(box, NO, 1, i, along, span, 1, edge);
          if (span > 2 && i > 0)
            {
              GeorgeFill(box, NO, 1, i + 1, along, span - 2, 1, face);
            }
        }
      else
        {
          GeorgeFill(box, NO, 1, along, i, 1, span, edge);
          if (span > 2 && i > 0)
            {
              GeorgeFill(box, NO, 1, along, i + 1, 1, span - 2, face);
            }
        }
    }
}

- (void)platinumDrawDisclosureCollapsed:(id)rep
{
  [self drawDisclosureInRep: rep expanded: NO];
}

- (void)platinumDrawDisclosureExpanded:(id)rep
{
  [self drawDisclosureInRep: rep expanded: YES];
}

- (void)platinumDrawSortAscending:(id)rep
{
  NSSize size = [rep size];

  GeorgeTriangle(NSMakeRect(0, 0, size.width, size.height), NO,
                 floor(size.width / 2.0), 2, 4, 0, GeorgeGray(0x00));
}

- (void)platinumDrawSortDescending:(id)rep
{
  NSSize size = [rep size];

  GeorgeTriangle(NSMakeRect(0, 0, size.width, size.height), NO,
                 floor(size.width / 2.0), 2, 4, 1, GeorgeGray(0x00));
}

- (void)platinumDrawSwitchOff:(id)rep
{
  [self drawToggleInRect: NSMakeRect(0, 0, [rep size].width, [rep size].height)
                 flipped: NO oval: NO look: GeorgeToggleLookMake(0, NO, YES)];
}

- (void)platinumDrawSwitchOn:(id)rep
{
  [self drawToggleInRect: NSMakeRect(0, 0, [rep size].width, [rep size].height)
                 flipped: NO oval: NO look: GeorgeToggleLookMake(1, NO, YES)];
}

- (void)platinumDrawSwitchMixed:(id)rep
{
  [self drawToggleInRect: NSMakeRect(0, 0, [rep size].width, [rep size].height)
                 flipped: NO oval: NO look: GeorgeToggleLookMake(-1, NO, YES)];
}

- (void)platinumDrawRadioOff:(id)rep
{
  [self drawToggleInRect: NSMakeRect(0, 0, [rep size].width, [rep size].height)
                 flipped: NO oval: YES look: GeorgeToggleLookMake(0, NO, YES)];
}

- (void)platinumDrawRadioOn:(id)rep
{
  [self drawToggleInRect: NSMakeRect(0, 0, [rep size].width, [rep size].height)
                 flipped: NO oval: YES look: GeorgeToggleLookMake(1, NO, YES)];
}

- (NSImage *)imageOfClass:(Class)imageClass
                     size:(NSSize)size
             drawSelector:(SEL)selector
{
  NSCustomImageRep *rep = [[NSCustomImageRep alloc] initWithDrawSelector: selector
                                                                delegate: self];
  NSImage *image = [[imageClass alloc] initWithSize: size];

  [rep setSize: size];
  [image addRepresentation: rep];
  RELEASE(rep);
  return AUTORELEASE(image);
}

- (NSImage *)imageWithSize:(NSSize)size drawSelector:(SEL)selector
{
  return [self imageOfClass: [NSImage class] size: size drawSelector: selector];
}

- (void)registerControlImages
{
  // Every image keeps the size of the one it replaces: libs-gui sizes checkbox
  // titles, menu columns, pop-ups and outline indents from these.
  static const struct {
    const char *name;
    const char *selector;
    int kind;                  /* 0 plain, 1 pop-up arrow, 2 toggle */
    BOOL oval;
    NSInteger mark;
  } images[] = {
    { "common_SwitchOff", "platinumDrawSwitchOff:", 2, NO, GeorgeToggleMarkOff },
    { "common_SwitchOn", "platinumDrawSwitchOn:", 2, NO, GeorgeToggleMarkOn },
    { "GSSwitchMixed", "platinumDrawSwitchMixed:", 2, NO, GeorgeToggleMarkMixed },
    { "common_RadioOff", "platinumDrawRadioOff:", 2, YES, GeorgeToggleMarkOff },
    { "common_RadioOn", "platinumDrawRadioOn:", 2, YES, GeorgeToggleMarkOn },
    { "common_Nibble", "platinumDrawNibble:", 1, NO, 0 },
    { "common_3DArrowUp", "platinumDrawArrowUp:", 1, NO, 0 },
    { "common_3DArrowDown", "platinumDrawArrowDown:", 1, NO, 0 },
    { "common_3DArrowLeft", "platinumDrawArrowLeft:", 1, NO, 0 },
    { "common_3DArrowRight", "platinumDrawArrowRight:", 1, NO, 0 },
    { "common_ArrowRightH", "platinumDrawDisclosureCollapsed:", 0, NO, 0 },
    { "common_ArrowDownH", "platinumDrawDisclosureExpanded:", 0, NO, 0 },
    { "NSMenuCheckmark", "platinumDrawMenuCheck:", 0, NO, 0 },
    { "NSMenuMixedState", "platinumDrawMenuMixed:", 0, NO, 0 },
    { "NSAscendingSortIndicator", "platinumDrawSortAscending:", 0, NO, 0 },
    { "NSDescendingSortIndicator", "platinumDrawSortDescending:", 0, NO, 0 }
  };
  NSUInteger i;

  for (i = 0; i < sizeof(images) / sizeof(images[0]); i++)
    {
      NSString *name = [NSString stringWithUTF8String: images[i].name];
      NSImage *old = [NSImage imageNamed: name];
      Class imageClass = (images[i].kind == 2 ? [GeorgeToggleImage class]
                          : (images[i].kind == 1 ? [GeorgePopUpArrowImage class]
                             : [NSImage class]));
      // Nothing in libs-gui ships the sort indicators, so they alone have no
      // size to keep.
      NSSize size = old ? [old size] : NSMakeSize(9, 9);
      NSImage *image = [self imageOfClass: imageClass
                                     size: size
                             drawSelector: sel_registerName(images[i].selector)];

      if (images[i].kind == 2)
        {
          [(GeorgeToggleImage *)image setOval: images[i].oval];
          [(GeorgeToggleImage *)image setMark: images[i].mark];
        }
      GeorgeRegisterImage(image, name);
    }
}

#pragma mark - Wells, panels and grooves

- (void)drawDefaultRingInRect:(NSRect)frame color:(NSColor *)color
{
  NSGraphicsContext *context = [NSGraphicsContext currentContext];
  BOOL antialias = [context shouldAntialias];
  // Snapped to device pixels first: at a fractional scale the ring would
  // otherwise keep an uneven gap to the button, whose edges are snapped too.
  NSRect outer = [[NSView focusView] centerScanRect: frame];
  // Stroked on the center of the line so its three pixels land on whole ones.
  NSRect r = NSInsetRect(outer, 1.5, 1.5);
  NSBezierPath *ring;

  if (NSWidth(r) < 8 || NSHeight(r) < 8)
    return;
  ring = [NSBezierPath bezierPathWithRoundedRect: r xRadius: 6.0 yRadius: 6.0];
  [context setShouldAntialias: NO];
  [color set];
  [ring setLineWidth: 3.0];
  [ring stroke];
  [context setShouldAntialias: antialias];
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

/* Rows run along the thumb from its back to its point; a row is drawn across
 * the track of a horizontal slider and along that of a vertical one, so one
 * routine covers both. */
- (void)drawSliderThumbInRect:(NSRect)frame
                      flipped:(BOOL)flipped
                   horizontal:(BOOL)horizontal
                      pressed:(BOOL)pressed
                      enabled:(BOOL)enabled
{
  NSRect r = NSIntegralRect(GeorgeSliderThumbRect(frame, horizontal));
  NSInteger width = (NSInteger)(horizontal ? NSWidth(r) : NSHeight(r));
  NSInteger length = (NSInteger)(horizontal ? NSHeight(r) : NSWidth(r));
  NSInteger shift = pressed ? 1 : 0;
  NSColor *edge = GeorgeGray(enabled ? 0x00 : 0x88);
  NSColor *face = enabled ? GeorgeSchemeColor(4 - shift) : GeorgeGray(0xDD);
  NSColor *light = enabled ? GeorgeSchemeColor(5 - shift) : face;
  NSColor *shade = enabled ? GeorgeSchemeColor(3 - shift) : face;
  NSInteger row;

#define SPANS(row_, last, from, count, color) \
  do { \
    if (horizontal) \
      { \
        GeorgeFill(r, flipped, 1, (from), (row_), (count), (last) - (row_) + 1, (color)); \
      } \
    else \
      { \
        GeorgeFill(r, flipped, 1, (row_), (from), (last) - (row_) + 1, (count), (color)); \
      } \
  } while (0)
#define SPAN(row_, from, count, color) SPANS((row_), (row_), (from), (count), (color))

  if (width < 7 || length < 7)
    {
      return;
    }
  // Each row reaches back to the top of the body rather than being one row:
  // at a fractional scale the edges between rows blend, and that would stripe
  // the face.
  SPAN(0, 1, width - 2, edge);
  for (row = length - 1; row >= 1; row--)
    {
      NSInteger inset = GeorgeSliderThumbRowInset(row, length, width);

      SPANS(1, row, inset, width - 2 * inset, edge);
    }
  for (row = length - 2; row >= 1; row--)
    {
      NSInteger inset = GeorgeSliderThumbRowInset(row, length, width);

      SPANS(1, row, inset + 1, width - 2 * inset - 2, face);
    }
  for (row = 1; row < length - 1; row++)
    {
      NSInteger inset = GeorgeSliderThumbRowInset(row, length, width);

      SPAN(row, inset + 1, 1, light);
      SPAN(row, width - inset - 2, 1, shade);
    }
  if (enabled)
    {
      SPAN(1, 2, width - 4, light);
      // The grip line of the scroll thumb, across its body.
      SPAN(3, 3, width - 6, GeorgeSchemeColor(2));
      SPAN(4, 3, width - 6, GeorgeSchemeColor(6));
    }
#undef SPAN
#undef SPANS
}

- (void)drawDisabledTrackInRect:(NSRect)frame flipped:(BOOL)flipped
{
  NSRect r = NSIntegralRect(frame);
  CGFloat w = NSWidth(r), h = NSHeight(r);

  if (w < 4 || h < 4)
    {
      return;
    }
  GeorgeFill(r, flipped, 1, 0, 0, w, h, GeorgeGray(0x88));
  GeorgeFill(r, flipped, 1, 1, 1, w - 2, h - 2, GeorgeGray(0xDD));
}

- (void)drawPopUpArrowBoxInRect:(NSRect)frame
                        flipped:(BOOL)flipped
                        pressed:(BOOL)pressed
                        enabled:(BOOL)enabled
                          arrow:(NSInteger)arrow
{
  NSRect r = NSIntegralRect(frame);
  CGFloat w = NSWidth(r), h = NSHeight(r);
  // The middle of what is left between the divider and the button's own
  // right edge and bevel.
  CGFloat cx = floor(w / 2.0);
  CGFloat cy = floor(h / 2.0);
  NSColor *edge = GeorgeGray(enabled ? 0x00 : 0x88);

  if (w < 9 || h < 12)
    {
      return;
    }
  // The divider stops at the button's outline, which it joins.
  GeorgeFill(r, flipped, 1, 0, 1, 1, h - 2, edge);
  if (enabled)
    {
      GeorgeFill(r, flipped, 1, 1, 3, 1, h - 6, GeorgeGray(pressed ? 0x55 : 0xFF));
    }
  if (arrow < 0)
    {
      GeorgeTriangle(r, flipped, cx, cy - 5, 4, 0, edge);
      GeorgeTriangle(r, flipped, cx, cy + 1, 4, 1, edge);
    }
  else if (arrow < 2)
    {
      GeorgeTriangle(r, flipped, cx, cy - 2, 4, arrow, edge);
    }
  else
    {
      GeorgeTriangle(r, flipped, cx - 2, cy, 4, arrow, edge);
    }
}

- (void)drawStepperInRect:(NSRect)frame
                  flipped:(BOOL)flipped
                upPressed:(BOOL)upPressed
              downPressed:(BOOL)downPressed
                  enabled:(BOOL)enabled
{
  NSRect r = NSIntegralRect(frame);
  CGFloat w = NSWidth(r), h = NSHeight(r);
  CGFloat middle = floor(h / 2.0);
  CGFloat cx = floor(w / 2.0);
  NSColor *edge = GeorgeGray(enabled ? 0x00 : 0x88);
  NSInteger rows = (w >= 13 && middle >= 8) ? 4 : 3;
  NSInteger half;

  if (w < 9 || h < 12)
    {
      return;
    }
  for (half = 0; half < 2; half++)
    {
      BOOL pressed = enabled && (half == 0 ? upPressed : downPressed);
      CGFloat top = (half == 0) ? 1 : middle + 1;
      CGFloat height = (half == 0) ? middle - 1 : h - middle - 2;

      GeorgeFill(r, flipped, 1, 1, top, w - 2, height, GeorgeGray(pressed ? 0x77 : 0xDD));
      if (enabled)
        {
          GeorgeFill(r, flipped, 1, 1, top, w - 3, 1, GeorgeGray(pressed ? 0x55 : 0xFF));
          GeorgeFill(r, flipped, 1, 1, top, 1, height - 1, GeorgeGray(pressed ? 0x55 : 0xFF));
          GeorgeFill(r, flipped, 1, 2, top + height - 1, w - 3, 1,
                     GeorgeGray(pressed ? 0x99 : 0xAA));
          GeorgeFill(r, flipped, 1, w - 2, top + 1, 1, height - 1,
                     GeorgeGray(pressed ? 0x99 : 0xAA));
        }
      GeorgeTriangle(r, flipped, cx, top + floor((height - rows) / 2.0), rows,
                     half, edge);
    }
  // One outline around both halves with the line between them shared, and the
  // outer corners clipped, which is what makes the two read as one control.
  GeorgeFill(r, flipped, 1, 1, 0, w - 2, 1, edge);
  GeorgeFill(r, flipped, 1, 1, h - 1, w - 2, 1, edge);
  GeorgeFill(r, flipped, 1, 0, 1, 1, h - 2, edge);
  GeorgeFill(r, flipped, 1, w - 1, 1, 1, h - 2, edge);
  GeorgeFill(r, flipped, 1, 1, middle, w - 2, 1, edge);
}

- (void)drawSortedHeaderInRect:(NSRect)frame flipped:(BOOL)flipped
{
  NSRect r = NSIntegralRect(frame);
  CGFloat w = NSWidth(r), h = NSHeight(r);

  if (w < 3 || h < 3)
    {
      return;
    }
  // Still raised: it marks the column, nobody is pressing it.
  GeorgeFill(r, flipped, 1, 0, 0, w, h, GeorgeGray(0xBB));
  GeorgeFill(r, flipped, 1, 0, 0, w - 1, 1, GeorgeGray(0xDD));
  GeorgeFill(r, flipped, 1, 0, 0, 1, h - 1, GeorgeGray(0xDD));
  GeorgeFill(r, flipped, 1, 1, h - 1, w - 1, 1, GeorgeGray(0x77));
  GeorgeFill(r, flipped, 1, w - 1, 1, 1, h - 1, GeorgeGray(0x77));
}

- (void)drawSortIndicatorInRect:(NSRect)frame
                        flipped:(BOOL)flipped
                      ascending:(BOOL)ascending
{
  NSRect r = NSIntegralRect(frame);

  GeorgeTriangle(r, flipped, NSWidth(r) - 9, floor((NSHeight(r) - 4) / 2.0), 4,
                 ascending ? 0 : 1, GeorgeGray(0x00));
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
