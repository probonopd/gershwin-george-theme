/*
 * Copyright (c) 2026 Simon Peter
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

#import "GeorgeControlImage.h"
#import "George+Parts.h"
#import "GeorgeGeometry.h"

@implementation GeorgeToggleImage

@synthesize oval = _oval;
@synthesize mark = _mark;

- (void)drawInRect:(NSRect)dstRect
          fromRect:(NSRect)srcRect
         operation:(NSCompositingOperation)op
          fraction:(CGFloat)delta
    respectFlipped:(BOOL)respectFlipped
             hints:(NSDictionary *)hints
{
  NSView *view = [NSView focusView];
  GSTheme *theme = [GSTheme theme];

  if ([view isKindOfClass: [NSButton class]] && [theme isKindOfClass: [George class]])
    {
      NSButtonCell *cell = [(NSButton *)view cell];
      NSImage *face = [cell isKindOfClass: [NSButtonCell class]] ? [cell image] : nil;

      // A button can show this artwork as a mere picture; only a real checkbox
      // or radio has a state that the picture stands for.
      if ([face isKindOfClass: [GeorgeToggleImage class]]
          && [(GeorgeToggleImage *)face oval] == _oval)
        {
          GeorgeToggleLook look = GeorgeToggleLookMake([cell state],
                                                       [cell isHighlighted],
                                                       [cell isEnabled]);

          if (!GeorgeToggleLookIsPlain(look, _mark))
            {
              [(George *)theme drawToggleInRect: dstRect
                                        flipped: [view isFlipped]
                                           oval: _oval
                                           look: look];
              return;
            }
        }
    }
  [super drawInRect: dstRect fromRect: srcRect operation: op fraction: delta
     respectFlipped: respectFlipped hints: hints];
}

@end

@implementation GeorgePopUpArrowImage

- (void)drawInRect:(NSRect)dstRect
          fromRect:(NSRect)srcRect
         operation:(NSCompositingOperation)op
          fraction:(CGFloat)delta
    respectFlipped:(BOOL)respectFlipped
             hints:(NSDictionary *)hints
{
  NSView *view = [NSView focusView];

  if ([view isKindOfClass: [NSPopUpButton class]] && [(NSPopUpButton *)view isBordered])
    {
      return;
    }
  [super drawInRect: dstRect fromRect: srcRect operation: op fraction: delta
     respectFlipped: respectFlipped hints: hints];
}

@end
