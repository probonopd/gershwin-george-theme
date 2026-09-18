/*
 * Copyright (c) 2026 Simon Peter
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

#import "George.h"

/* The file icons: folders, documents, volumes and the trash, drawn as
 * Platinum pixel art in the same grays the controls use. */
@interface George (Icons)

/* Draws each icon on demand and registers it under the name GNUstep looks it
 * up by, the way the control images are registered. */
- (void)registerFileIcons;

@end
