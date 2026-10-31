/*
 * Copyright (c) 2026 Simon Peter
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

/* Menus: the menu bar as Aaron's menu bar patch draws it, and
 * menus as Aaron's menu definition draws them, in its "Menu Colors". */

#import "George+Menu.h"
#import "GeorgePlatinum.h"

@implementation George (Menu)

- (NSColor *)menuBackgroundColor
{
  return GeorgeGray(0xE8);
}

- (NSColor *)disabledMenuTextColor
{
  return GeorgeGray(0x7A);
}

- (void)drawMenuBackgroundInView:(NSView *)view isHorizontal:(BOOL)horizontal
{
  NSRect b = [view bounds];
  BOOL f = [view isFlipped];
  CGFloat w = NSWidth(b);
  CGFloat h = NSHeight(b);

  GeorgeFill(b, f, 1, 0, 0, w, h, [self menuBackgroundColor]);
  if (!horizontal)
    return;

  GeorgeFill(b, f, 1, 0, 0, w, 1, GeorgeGray(0xFF));
  GeorgeFill(b, f, 1, 0, 0, 1, h, GeorgeGray(0xFF));
  GeorgeFill(b, f, 1, w - 1, 0, 1, h, GeorgeGray(0x9A));
  GeorgeFill(b, f, 1, 0, h - 1, w, 1, GeorgeGray(0x9A));
}

- (void)drawMenuFrameInView:(NSView *)view
{
  NSRect b = [view bounds];
  BOOL f = [view isFlipped];
  CGFloat w = NSWidth(b);
  CGFloat h = NSHeight(b);

  GeorgeFill(b, f, 1, 1, 1, w - 2, 1, GeorgeGray(0xFF));
  GeorgeFill(b, f, 1, 1, 1, 1, h - 2, GeorgeGray(0xFF));
  GeorgeFill(b, f, 1, 2, h - 2, w - 3, 1, GeorgeGray(0x88));
  GeorgeFill(b, f, 1, w - 2, 2, 1, h - 3, GeorgeGray(0x88));
  GeorgeFill(b, f, 1, 0, 0, w, 1, GeorgeGray(0x60));
  GeorgeFill(b, f, 1, 0, h - 1, w, 1, GeorgeGray(0x60));
  GeorgeFill(b, f, 1, 0, 0, 1, h, GeorgeGray(0x60));
  GeorgeFill(b, f, 1, w - 1, 0, 1, h, GeorgeGray(0x60));
}

- (void)drawMenuItemBackgroundInFrame:(NSRect)cellFrame
                                highlighted:(BOOL)highlighted
                               isHorizontal:(BOOL)horizontal
{
  if (highlighted)
    {
      [GeorgeGray(0xB8) set];
      NSRectFill(cellFrame);
    }
  else if (!horizontal)
    {
      [[self menuBackgroundColor] set];
      NSRectFill(cellFrame);
    }
}

- (void)drawMenuSeparatorInFrame:(NSRect)cellFrame flipped:(BOOL)flipped
{
  GeorgeFill(cellFrame, flipped, 1, 0, floor(NSHeight(cellFrame) / 2.0),
             NSWidth(cellFrame), 1, GeorgeGray(0xA0));
}

#pragma mark - GSTheme menu hooks

- (NSColor *)menuBarBackgroundColor
{
  return [self menuBackgroundColor];
}

- (NSColor *)menuItemBackgroundColor
{
  return [self menuBackgroundColor];
}

- (NSColor *)menuBarBorderColor
{
  return GeorgeGray(0x60);
}

- (NSColor *)menuBorderColor
{
  return GeorgeGray(0x60);
}

- (NSColor *)menuSeparatorColor
{
  return [self disabledMenuTextColor];
}

- (CGFloat)menuSeparatorInset
{
  return 0.0;
}

- (void)drawBackgroundForMenuView:(NSMenuView *)menuView
                         withFrame:(NSRect)bounds
                         dirtyRect:(NSRect)dirtyRect
                        horizontal:(BOOL)horizontal
{
  [self drawMenuBackgroundInView: menuView isHorizontal: horizontal];
}

- (void)drawMenuRect:(NSRect)rect
               inView:(NSView *)view
         isHorizontal:(BOOL)horizontal
            itemCells:(NSArray *)itemCells
{
  [super drawMenuRect: rect inView: view isHorizontal: horizontal
             itemCells: itemCells];
  if (!horizontal)
    [self drawMenuFrameInView: view];
}

- (BOOL)drawsBorderForMenuItemCell:(NSMenuItemCell *)cell
                              state:(GSThemeControlState)state
                       isHorizontal:(BOOL)horizontal
{
  return NO;
}

- (void)drawBorderAndBackgroundForMenuItemCell:(NSMenuItemCell *)cell
                                      withFrame:(NSRect)cellFrame
                                         inView:(NSView *)controlView
                                          state:(GSThemeControlState)state
                                   isHorizontal:(BOOL)isHorizontal
{
  [self drawMenuItemBackgroundInFrame: cellFrame
                           highlighted: (state == GSThemeSelectedState
                                         || state == GSThemeHighlightedState)
                          isHorizontal: isHorizontal];
}

- (void)drawSeparatorItemForMenuItemCell:(NSMenuItemCell *)cell
                                withFrame:(NSRect)cellFrame
                                   inView:(NSView *)controlView
                             isHorizontal:(BOOL)isHorizontal
{
  [self drawMenuSeparatorInFrame: cellFrame flipped: [controlView isFlipped]];
}

@end
