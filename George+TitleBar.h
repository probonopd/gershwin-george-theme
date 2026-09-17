/*
 * Copyright (c) 2026 Simon Peter
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

#import "George.h"

@interface George (TitleBar)

/* Slot of a title bar widget in title bar coordinates (origin bottom left),
 * without checking whether the window has that widget. */
- (NSRect)widgetRectForButton:(GeorgeWidget)button
                titlebarWidth:(CGFloat)width
                    styleMask:(NSUInteger)styleMask;

- (void)drawTitlebarInRect:(NSRect)rect
                 styleMask:(NSUInteger)styleMask
                    active:(BOOL)active
                     title:(NSString *)title;

- (void)drawTitlebarFrameInRect:(NSRect)rect active:(BOOL)active;

- (void)drawWidget:(GeorgeWidget)button
            inSlot:(NSRect)slot
           pressed:(BOOL)pressed;

/* Widget as the window manager asks for it: Platinum has no hover look, so
 * hovering only reveals the hidden widgets of an inactive window. */
- (void)drawWidget:(GeorgeWidget)button
            inSlot:(NSRect)slot
            active:(BOOL)active
           hovered:(BOOL)hovered;

@end
