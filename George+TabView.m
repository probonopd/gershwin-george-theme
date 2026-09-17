/*
 * Copyright (c) 2026 Simon Peter
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

/* Tab views in the Platinum style. Tabs are raised panels with
 * clipped top corners; the selected one is filled like the pane below it and
 * eats the pane border so the two read as one surface. */

#import "George+TabView.h"
#import "GeorgePlatinum.h"

static const CGFloat GeorgeTabLabelPadding = 12.0;
static const CGFloat GeorgeTabStripInset = 8.0;

@implementation George (TabView)

/* upward is YES for tabs sitting above their pane; for tabs below it every
 * row is mirrored inside the rect so the lit edges stay on the outside. */
- (void)drawTabInRect:(NSRect)frame
                   flipped:(BOOL)flipped
                    upward:(BOOL)upward
                  selected:(BOOL)selected
{
  NSRect r = NSIntegralRect(frame);
  CGFloat w = NSWidth(r), h = NSHeight(r);
  NSInteger face = selected ? 0xDD : 0xCC;

#define TAB_FILL(x, y, fw, fh, gray) \
  GeorgeFill(r, flipped, 1, (x), (upward ? (y) : h - (y) - (fh)), \
                    (fw), (fh), GeorgeGray(gray))

  if (w < 6 || h < 6)
    return;

  TAB_FILL(0, 0, w, h, 0xDD);
  TAB_FILL(1, 1, w - 2, h - 1, face);

  TAB_FILL(2, 0, w - 4, 1, 0x00);
  TAB_FILL(1, 1, 1, 1, 0x00);
  TAB_FILL(w - 2, 1, 1, 1, 0x00);
  TAB_FILL(0, 2, 1, h - 2, 0x00);
  TAB_FILL(w - 1, 2, 1, h - 2, 0x00);

  TAB_FILL(2, 1, w - 4, 1, 0xFF);
  TAB_FILL(1, 2, 1, h - 2, 0xFF);
  TAB_FILL(w - 2, 2, 1, h - 2, 0x99);

  // An unselected tab keeps its own base line; a selected one runs into the
  // pane, so its last two rows stay filled with the pane color.
  if (!selected)
    TAB_FILL(0, h - 1, w, 1, 0x00);
  else
    TAB_FILL(1, h - 2, w - 2, 2, face);

#undef TAB_FILL
}

- (void)drawTabPaneInRect:(NSRect)frame flipped:(BOOL)flipped
{
  NSRect r = NSIntegralRect(frame);
  CGFloat w = NSWidth(r), h = NSHeight(r);

  if (w < 4 || h < 4)
    return;
  GeorgeFill(r, flipped, 1, 0, 0, w, h, GeorgeGray(0x00));
  GeorgeFill(r, flipped, 1, 1, 1, w - 2, h - 2, GeorgeGray(0xDD));
  GeorgeFill(r, flipped, 1, 1, 1, w - 3, 1, GeorgeGray(0xFF));
  GeorgeFill(r, flipped, 1, 1, 1, 1, h - 3, GeorgeGray(0xFF));
  GeorgeFill(r, flipped, 1, 2, h - 2, w - 3, 1, GeorgeGray(0x99));
  GeorgeFill(r, flipped, 1, w - 2, 2, 1, h - 3, GeorgeGray(0x99));
}

- (void)drawTabViewRect:(NSRect)rect
                      inView:(NSView *)view
                   withItems:(NSArray *)items
                selectedItem:(NSTabViewItem *)selected
{
  NSTabViewType type = [(NSTabView *)view tabViewType];
  BOOL truncate = [(NSTabView *)view allowsTruncatedLabels];
  BOOL flipped = [view isFlipped];
  BOOL upward = (type == NSTopTabsBezelBorder);
  NSRect bounds = [view bounds];
  NSRect pane = [self tabViewBackgroundRectForBounds: bounds tabViewType: type];
  CGFloat tabHeight = [self tabHeightForType: type];
  CGFloat stripY = upward ? NSMinY(bounds) : NSMaxY(pane);
  CGFloat x = NSMinX(bounds) + GeorgeTabStripInset;
  NSUInteger count = [items count];
  NSUInteger i;
  NSRect selectedRect = NSZeroRect;

  if (type != NSTopTabsBezelBorder && type != NSBottomTabsBezelBorder)
    {
      [super drawTabViewRect: rect inView: view withItems: items
                selectedItem: selected];
      return;
    }

  [GeorgeGray(0xDD) set];
  NSRectFill(NSMakeRect(NSMinX(bounds), stripY, NSWidth(bounds), tabHeight));
  [self drawTabPaneInRect: pane flipped: flipped];

  for (i = 0; i < count; i++)
    {
      NSTabViewItem *item = [items objectAtIndex: i];
      BOOL isSelected = ([item tabState] == NSSelectedTab);
      NSSize size = [item sizeOfLabel: truncate];
      NSRect tab = NSMakeRect(x, stripY,
                              round(size.width) + 2 * GeorgeTabLabelPadding,
                              tabHeight);

      // The selected tab is full height and is drawn last so that it covers
      // the base line of the tabs it touches.
      if (!isSelected)
        {
          NSRect label = NSInsetRect(tab, GeorgeTabLabelPadding, 3);

          // Two pixels shorter at the outer edge, and its base line lands on
          // the pane border rather than next to it.
          tab.size.height -= 1;
          if (upward)
            tab.origin.y += 2;
          else
            tab.origin.y -= 1;
          [self drawTabInRect: tab flipped: flipped upward: upward
                          selected: NO];
          [item drawLabel: truncate inRect: label];
        }
      else
        {
          selectedRect = tab;
        }
      // Neighbouring tabs share the pixel column their borders sit in.
      x += NSWidth(tab) - 1;
    }

  if (!NSIsEmptyRect(selectedRect))
    {
      NSRect label = NSInsetRect(selectedRect, GeorgeTabLabelPadding, 3);

      // Reaches two pixels into the pane so that its own fill replaces the
      // pane border there and both read as one surface.
      selectedRect.size.height += 2;
      if (!upward)
        selectedRect.origin.y -= 2;
      [self drawTabInRect: selectedRect flipped: flipped upward: upward
                      selected: YES];
      [selected drawLabel: truncate inRect: label];
    }
}

@end
