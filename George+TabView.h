/*
 * Copyright (c) 2026 Simon Peter
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

#import "George.h"

@interface George (TabView)

- (void)drawTabInRect:(NSRect)frame
              flipped:(BOOL)flipped
               upward:(BOOL)upward
             selected:(BOOL)selected;
- (void)drawTabPaneInRect:(NSRect)frame flipped:(BOOL)flipped;

@end
