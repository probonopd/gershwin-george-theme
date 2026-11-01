/*
 * Copyright (c) 2026 Simon Peter
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

#import "George.h"
#import "GeorgeGeometry.h"

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
                  horizontal:(BOOL)horizontal
                     pressed:(BOOL)pressed;
- (void)drawScrollSlotInRect:(NSRect)frame
                     flipped:(BOOL)flipped
                  horizontal:(BOOL)horizontal;

/* Heavy ring Platinum puts around the default push button. */
- (void)drawDefaultRingInRect:(NSRect)frame color:(NSColor *)color;

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
/* The pointed thumb, in the knob rect libs-gui hit tests. */
- (void)drawSliderThumbInRect:(NSRect)frame
                      flipped:(BOOL)flipped
                   horizontal:(BOOL)horizontal
                      pressed:(BOOL)pressed
                      enabled:(BOOL)enabled;
- (void)drawDisabledTrackInRect:(NSRect)frame flipped:(BOOL)flipped;
/* A checkbox or radio in a state its registered image cannot show. */
- (void)drawToggleInRect:(NSRect)frame
                 flipped:(BOOL)flipped
                    oval:(BOOL)oval
                    look:(GeorgeToggleLook)look;
/* The end of a pop-up button. arrow is a scroll bar direction, or -1 for the
 * double triangle of a pop-up that opens around its own title. */
- (void)drawPopUpArrowBoxInRect:(NSRect)frame
                        flipped:(BOOL)flipped
                        pressed:(BOOL)pressed
                        enabled:(BOOL)enabled
                          arrow:(NSInteger)arrow;
/* Both halves of the little arrows as one framed part. */
- (void)drawStepperInRect:(NSRect)frame
                  flipped:(BOOL)flipped
                upPressed:(BOOL)upPressed
              downPressed:(BOOL)downPressed
                  enabled:(BOOL)enabled;
/* The header of the column a table is sorted by. */
- (void)drawSortedHeaderInRect:(NSRect)frame flipped:(BOOL)flipped;
- (void)drawSortIndicatorInRect:(NSRect)frame
                        flipped:(BOOL)flipped
                      ascending:(BOOL)ascending;
- (void)drawGrowBoxInRect:(NSRect)frame flipped:(BOOL)flipped;
/* Indeterminate progress: Platinum's moving diagonal stripes. */
- (void)drawBarberPoleInRect:(NSRect)frame flipped:(BOOL)flipped phase:(NSInteger)phase;

@end
