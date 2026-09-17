/*
 * Copyright (c) 2026 Simon Peter
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

#import <AppKit/AppKit.h>

/* Shared helpers for George, which draws Platinum parts as pixel art in the
 * colors the Aaron 1.6.1 extension uses. */

/* Fills (x, y, w, h), given in Platinum pixels from the top left corner of
 * ref, where one Platinum pixel is unit points. Each edge is snapped to whole
 * points on its own so that neighbouring fills tile without seams. */
void GeorgeFill(NSRect ref, BOOL flipped, CGFloat unit,
                CGFloat x, CGFloat y, CGFloat w, CGFloat h, NSColor *color);

NSColor *GeorgeGray(NSInteger gray);

/* Size of one Platinum pixel in the window decorations, in device pixels. The
 * decorations are pixel art, so the scale factor is rounded to a whole number
 * here: at a fractional one the rows of a ridge or of a widget would come out
 * unevenly tall and nothing would sit centred in the title bar. */
CGFloat GeorgeUnit(void);

/* Entry of the color scheme chosen with the GeorgeColor default: one of
 * Aaron's eight window color schemes (lavender unless set). Entry 0 is black,
 * 1-6 run from dark to light, 7 is white, 8 is a dark accent. */
NSColor *GeorgeSchemeColor(NSInteger index);
