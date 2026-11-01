/*
 * Copyright (c) 2026 Simon Peter
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

#import <AppKit/AppKit.h>

/* NSButtonCell picks a checkbox or radio image by name and tells it nothing
 * about the cell, so held, disabled and mixed have no image of their own. This
 * image asks the button being drawn instead. Whatever the registered artwork
 * already shows, and anything drawn outside a plain button (a matrix, a table
 * cell), takes the normal image path. */
@interface GeorgeToggleImage : NSImage
{
  BOOL _oval;
  NSInteger _mark;
}
@property (nonatomic, assign) BOOL oval;
/* The GeorgeToggleMark this image draws. */
@property (nonatomic, assign) NSInteger mark;
@end

/* libs-gui draws the arrow of a pop-up on top of the button, at a place that
 * cannot be centered in the arrow box. A bordered pop-up gets its arrows with
 * the box, so the image stands back there; a borderless one still needs it. */
@interface GeorgePopUpArrowImage : NSImage
@end
