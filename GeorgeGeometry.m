/*
 * Copyright (c) 2026 Simon Peter
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

#import "GeorgeGeometry.h"

/* Text stops three pixels short of the arrow image in libs-gui's cell size, so
 * a box starting two pixels short of it stays clear of the text that fits. */
static const CGFloat GeorgePopUpBoxLeadIn = 2.0;
/* Past this share the box would leave no room for the title. */
static const CGFloat GeorgePopUpBoxMaxShare = 0.5;

/* Rows a slanted tab side climbs before it steps in by one pixel. */
static const NSInteger GeorgeTabSlantRows = 3;

/* A Platinum thumb is narrower than the knob image GNUstep sizes the knob rect
 * from. */
static const CGFloat GeorgeSliderThumbWidth = 13.0;

/* Where the Platinum group box starts its title, from the left of the box. */
static const CGFloat GeorgeBoxTitleInset = 8.0;

NSRect GeorgePopUpArrowBoxRect(NSRect frame, CGFloat imageLeft)
{
  NSRect box = frame;

  box.origin.x = imageLeft - GeorgePopUpBoxLeadIn;
  box.size.width = NSMaxX(frame) - NSMinX(box);
  if (NSWidth(box) <= 0 || NSWidth(box) > NSWidth(frame) * GeorgePopUpBoxMaxShare)
    {
      return NSZeroRect;
    }
  return box;
}

NSInteger GeorgeTabSideInset(NSInteger row, NSInteger height)
{
  return (height - 1 - row) / GeorgeTabSlantRows;
}

NSRect GeorgeSliderThumbRect(NSRect knobRect, BOOL horizontal)
{
  NSRect thumb = knobRect;

  if (horizontal)
    {
      thumb.origin.x += floor((NSWidth(knobRect) - GeorgeSliderThumbWidth) / 2.0);
      thumb.size.width = GeorgeSliderThumbWidth;
    }
  else
    {
      thumb.origin.y += floor((NSHeight(knobRect) - GeorgeSliderThumbWidth) / 2.0);
      thumb.size.height = GeorgeSliderThumbWidth;
    }
  return thumb;
}

NSInteger GeorgeSliderThumbRowInset(NSInteger row, NSInteger length, NSInteger width)
{
  NSInteger taper = (width - 1) / 2;
  NSInteger start = length - taper;

  if (row == 0)
    {
      return 1;
    }
  return row < start ? 0 : row - start + 1;
}

GeorgeToggleLook GeorgeToggleLookMake(NSInteger state, BOOL highlighted, BOOL enabled)
{
  GeorgeToggleLook look;

  look.mark = (state < 0 ? GeorgeToggleMarkMixed
                         : (state > 0 ? GeorgeToggleMarkOn : GeorgeToggleMarkOff));
  look.pressed = highlighted && enabled;
  look.enabled = enabled;
  return look;
}

BOOL GeorgeToggleLookIsPlain(GeorgeToggleLook look, GeorgeToggleMark imageMark)
{
  return look.enabled && !look.pressed && look.mark == imageMark;
}

NSRect GeorgeBoxTitleRect(NSRect titleRect, NSRect borderRect)
{
  NSRect title = titleRect;

  title.origin.x = NSMinX(borderRect) + GeorgeBoxTitleInset;
  if (NSMaxX(title) > NSMaxX(borderRect))
    {
      // Too wide for the inset: as far left as the box lets it start.
      title.origin.x = MAX(NSMinX(borderRect), NSMaxX(borderRect) - NSWidth(title));
    }
  return title;
}

void GeorgeFocusRingBands(NSRect frame, NSRect bands[GeorgeFocusRingBandCount])
{
  NSRect inner = NSInsetRect(frame, 1, 1);
  CGFloat x = NSMinX(frame), y = NSMinY(frame);
  CGFloat w = NSWidth(frame), h = NSHeight(frame);

  bands[0] = NSMakeRect(x + 1, y, w - 2, 1);
  bands[1] = NSMakeRect(x + 1, NSMaxY(frame) - 1, w - 2, 1);
  bands[2] = NSMakeRect(x, y + 1, 1, h - 2);
  bands[3] = NSMakeRect(NSMaxX(frame) - 1, y + 1, 1, h - 2);
  bands[4] = NSMakeRect(NSMinX(inner), NSMinY(inner), NSWidth(inner), 1);
  bands[5] = NSMakeRect(NSMinX(inner), NSMaxY(inner) - 1, NSWidth(inner), 1);
  bands[6] = NSMakeRect(NSMinX(inner), NSMinY(inner), 1, NSHeight(inner));
  bands[7] = NSMakeRect(NSMaxX(inner) - 1, NSMinY(inner), 1, NSHeight(inner));
}

GeorgeTableHeaderLook GeorgeTableHeaderLookFor(BOOL highlighted, BOOL sorted)
{
  if (sorted)
    {
      return GeorgeTableHeaderSorted;
    }
  return highlighted ? GeorgeTableHeaderPressed : GeorgeTableHeaderNormal;
}
