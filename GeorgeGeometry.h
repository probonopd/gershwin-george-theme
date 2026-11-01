/*
 * Copyright (c) 2026 Simon Peter
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

#import <Foundation/Foundation.h>

/* What George's parts decide before they draw. Kept apart from the drawing so
 * that it can be tested without a graphics context, and free of AppKit for the
 * same reason. Nothing here may change a control's frame or hit area: every
 * rect comes from one GNUstep already laid out. */

/* The divided end of a pop-up button. imageLeft is where libs-gui puts the
 * arrow image, the only thing it keeps text away from, so the box starts just
 * left of it. Empty when the button is too small to hold a box. */
NSRect GeorgePopUpArrowBoxRect(NSRect frame, CGFloat imageLeft);

/* How far a tab's side leans in on a row, counted from the tab's outer edge. */
NSInteger GeorgeTabSideInset(NSInteger row, NSInteger height);

/* Part of a slider's knob rect the thumb fills. The knob rect stays what
 * libs-gui computes and hit tests; it is wider than the Platinum thumb. */
NSRect GeorgeSliderThumbRect(NSRect knobRect, BOOL horizontal);

/* How far the thumb's outline stands in from each long side on a row, counted
 * from its back towards its point. */
NSInteger GeorgeSliderThumbRowInset(NSInteger row, NSInteger length, NSInteger width);

typedef NS_ENUM(NSInteger, GeorgeToggleMark) {
    GeorgeToggleMarkOff = 0,
    GeorgeToggleMarkOn,
    GeorgeToggleMarkMixed
};

typedef struct {
    GeorgeToggleMark mark;
    BOOL pressed;
    BOOL enabled;
} GeorgeToggleLook;

/* state is the cell's NSCellStateValue: 0 off, 1 on, -1 mixed. */
GeorgeToggleLook GeorgeToggleLookMake(NSInteger state, BOOL highlighted, BOOL enabled);

/* YES if the registered image showing imageMark already draws this look. */
BOOL GeorgeToggleLookIsPlain(GeorgeToggleLook look, GeorgeToggleMark imageMark);

/* Where a group box title goes: on the same row, at the left of the box. */
NSRect GeorgeBoxTitleRect(NSRect titleRect, NSRect borderRect);

/* The focus band with its outer corners clipped, as whole rects so that it
 * reads the same in flipped and unflipped views. */
enum { GeorgeFocusRingBandCount = 8 };
void GeorgeFocusRingBands(NSRect frame, NSRect bands[GeorgeFocusRingBandCount]);

typedef NS_ENUM(NSInteger, GeorgeTableHeaderLook) {
    GeorgeTableHeaderNormal = 0,
    GeorgeTableHeaderPressed,
    GeorgeTableHeaderSorted
};

GeorgeTableHeaderLook GeorgeTableHeaderLookFor(BOOL highlighted, BOOL sorted);
