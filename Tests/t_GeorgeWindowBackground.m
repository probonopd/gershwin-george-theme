/* t_GeorgeWindowBackground.m - the theme paints what the window asks for.
 * Headless: a window, a view and a color are stood in for, since a real
 * NSWindow needs a display server.
 *
 * Copyright (c) 2026 Simon Peter
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

#import <AppKit/AppKit.h>
#import <GNUstepGUI/GSTheme.h>
#import "Testing.h"
#import "George.h"

/* There is no graphics context to fill in here, so the color stops the
 * drawing at the moment it is chosen. */
static NSColor *chosen = nil;

@interface RecordingColor : NSColor
@end

@implementation RecordingColor
- (void) set
{
  chosen = self;
  [NSException raise: @"ColorChosen" format: @"stop before NSRectFill"];
}
@end

@interface WindowStandIn : NSObject
{
@public
  NSColor *color;
}
- (NSColor *) backgroundColor;
@end

@implementation WindowStandIn
- (NSColor *) backgroundColor
{
  return color;
}
@end

@interface ViewStandIn : NSView
{
@public
  WindowStandIn *stand;
}
@end

@implementation ViewStandIn
- (NSWindow *) window
{
  return (NSWindow *)stand;
}
@end

int main(void)
{
  NSAutoreleasePool *arp = [NSAutoreleasePool new];
  George *theme = [[George alloc] initWithBundle: nil];
  WindowStandIn *window = [WindowStandIn new];
  ViewStandIn *view = [[ViewStandIn alloc] initWithFrame: NSMakeRect(0, 0, 10, 10)];
  RecordingColor *color = [RecordingColor new];

  window->color = color;
  view->stand = window;
  NS_DURING
    {
      [theme drawWindowBackground: NSMakeRect(0, 0, 10, 10) view: view];
    }
  NS_HANDLER
    {
    }
  NS_ENDHANDLER
  PASS(chosen == color, "the window's own background color is painted");

  [arp release];
  return 0;
}
