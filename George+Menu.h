/*
 * Copyright (c) 2026 Simon Peter
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

#import "George.h"

@interface George (Menu)

- (void)drawMenuBackgroundInView:(NSView *)view isHorizontal:(BOOL)horizontal;
- (void)drawMenuFrameInView:(NSView *)view;
- (void)drawMenuItemBackgroundInFrame:(NSRect)cellFrame
                               highlighted:(BOOL)highlighted
                              isHorizontal:(BOOL)horizontal;
- (void)drawMenuSeparatorInFrame:(NSRect)cellFrame flipped:(BOOL)flipped;
- (NSColor *)menuBackgroundColor;
- (NSColor *)disabledMenuTextColor;

@end
