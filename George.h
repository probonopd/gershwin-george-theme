/*
 * Copyright (c) 2026 Simon Peter
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

#import <AppKit/AppKit.h>
#import <GNUstepGUI/GSTheme.h>

/* Title bar widgets, in the order the window manager numbers them. */
typedef NS_ENUM(NSInteger, GeorgeWidget) {
    GeorgeWidgetClose = 0,
    GeorgeWidgetCollapse,       /* "minimize" to the window manager */
    GeorgeWidgetZoom            /* "maximize" to the window manager */
};

/* Sides of a window frame, as the window manager asks for them. */
typedef NS_ENUM(NSInteger, GeorgeFrameEdge) {
    GeorgeFrameEdgeLeft = 0,
    GeorgeFrameEdgeRight,
    GeorgeFrameEdgeBottom
};

@interface George : GSTheme
@end

/* The bundle's code cannot be unloaded once the theme has been loaded, and the
 * +load swizzles in NSFont+George.m stay installed for the life of the
 * process.  They ask this before answering with a Platinum face and otherwise
 * hand back what GNUstep resolved, so another theme can take over without
 * George's typography leaking into it.  Set by -[George activate], cleared by
 * -[George deactivate]. */
BOOL GeorgeThemeIsActive(void);

/* Register an image George drew under the name GNUstep looks it up by.  An
 * NSImage name can be held by one image only, so the image that held it is
 * kept and put back when the theme is deactivated - otherwise the name would
 * point at a Platinum drawing for the rest of the process, whichever theme is
 * current. */
void GeorgeRegisterImage(NSImage *image, NSString *name);

/* Window manager interface. The window manager draws title bars and window
 * borders itself and asks the current theme for the artwork by these
 * selectors, so their names are part of that contract. */
@interface George (WindowManager)

/* YES: the theme lays out and draws the widgets, so the window manager must
 * not overlay its own edge buttons. */
- (BOOL)drawsTitlebarButtons;
- (NSRect)titlebarButtonRectForButton:(NSInteger)button
                        titlebarWidth:(CGFloat)width
                            styleMask:(NSUInteger)styleMask;
- (void)drawtitleRect:(NSRect)rect
         forStyleMask:(unsigned int)styleMask
                state:(int)inputState
             andTitle:(NSString *)title;
- (void)drawCloseButtonInRect:(NSRect)rect
                        state:(GSThemeControlState)state
                       active:(BOOL)active;
- (void)drawMinimizeButtonInRect:(NSRect)rect
                           state:(GSThemeControlState)state
                          active:(BOOL)active;
- (void)drawMaximizeButtonInRect:(NSRect)rect
                           state:(GSThemeControlState)state
                          active:(BOOL)active;

@end

@interface George (Frame)

/* Border the window manager leaves around the client, in pixels. */
- (CGFloat)windowFrameBorderWidth;
/* Color of one pixel line of that border, counted from the outside in. */
- (NSColor *)windowFrameBorderColorAtDepth:(NSInteger)depth
                                      edge:(NSInteger)edge
                                    active:(BOOL)active;

@end
