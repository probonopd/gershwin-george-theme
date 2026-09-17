/*
 * Copyright (c) 2026 Simon Peter
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

#import "George.h"

/* The Platinum parts every control is assembled from. */
@interface George (Parts)

- (void)drawPushButtonInRect:(NSRect)frame
                     flipped:(BOOL)flipped
                     pressed:(BOOL)pressed
                     enabled:(BOOL)enabled;

/* Checkbox, radio and arrow artwork, drawn on demand and registered under the
 * standard image names. */
- (void)registerControlImages;

/* Scroll bar parts. direction is 0 up, 1 down, 2 left, 3 right. */
- (void)drawScrollArrowInRect:(NSRect)frame
                      flipped:(BOOL)flipped
                    direction:(NSInteger)direction
                      pressed:(BOOL)pressed
                      enabled:(BOOL)enabled;
- (void)drawScrollKnobInRect:(NSRect)frame
                     flipped:(BOOL)flipped
                  horizontal:(BOOL)horizontal;
- (void)drawScrollSlotInRect:(NSRect)frame
                     flipped:(BOOL)flipped
                  horizontal:(BOOL)horizontal;

/* Heavy ring Platinum puts around the default push button, and the doubled
 * outline that marks it where there is no room for the ring. */
- (void)drawDefaultRingInRect:(NSRect)frame;
- (void)drawDefaultOutlineInRect:(NSRect)frame flipped:(BOOL)flipped;

/* Square cornered button: what segments, color wells and toolbar items use. */
- (void)drawBevelButtonInRect:(NSRect)frame
                      flipped:(BOOL)flipped
                      pressed:(BOOL)pressed
                      enabled:(BOOL)enabled;
/* Sunken well: what text fields, lists and tracks sit in. */
- (void)drawWellInRect:(NSRect)frame flipped:(BOOL)flipped fill:(NSColor *)fill;
/* Raised panel: the surface of headers and tabs. */
- (void)drawRaisedPanelInRect:(NSRect)frame flipped:(BOOL)flipped pressed:(BOOL)pressed;
/* Embossed line around a group box. */
- (void)drawGrooveInRect:(NSRect)frame flipped:(BOOL)flipped;
- (void)drawSliderKnobInRect:(NSRect)frame flipped:(BOOL)flipped pressed:(BOOL)pressed;
- (void)drawGrowBoxInRect:(NSRect)frame flipped:(BOOL)flipped;
/* Indeterminate progress: Platinum's moving diagonal stripes. */
- (void)drawBarberPoleInRect:(NSRect)frame flipped:(BOOL)flipped phase:(NSInteger)phase;

@end
