/* t_GeorgeIcons.m - ObjectTesting coverage for the file icons: that every
 * name GNUstep looks up is answered by the theme's own drawing rather than by
 * the stock artwork. Needs a display to resolve images with.
 *
 * Copyright (c) 2026 Simon Peter
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "Testing.h"
#import "George.h"
#import "George+Icons.h"

static NSArray *GeorgeIconNames(void)
{
  return @[@"common_Folder", @"common_GSFolder", @"common_LibraryFolder",
           @"common_ApplicationFolder", @"common_DocsFolder",
           @"common_DownloadFolder", @"common_ImageFolder", @"common_MusicFolder",
           @"common_VideoFolder", @"common_Desktop", @"common_HomeDirectory",
           @"common_Home2_48", @"common_Home", @"common_RecyclerEmpty",
           @"common_RecyclerFull", @"common_Unknown", @"common_UnknownApplication",
           @"common_UnknownTool", @"common_MultipleSelection", @"common_Root_Apple",
           @"common_Root_PC", @"common_Tile"];
}

/* Empty while everything passed, and the offending names when it did not. */
static const char *GeorgeNamesLeft(NSArray *names)
{
  if ([names count] == 0)
    return "";
  return [[NSString stringWithFormat: @", missing: %@",
                    [names componentsJoinedByString: @", "]] UTF8String];
}

int main(void)
{
  NSAutoreleasePool *arp = [NSAutoreleasePool new];

  START_SET("icons")
    George *theme = nil;
    NSEnumerator *names;
    NSString *name;
    NSMutableArray *missing = [NSMutableArray array];
    NSMutableArray *stock = [NSMutableArray array];
    NSMutableArray *blank = [NSMutableArray array];

    // Drawing an image needs the backend, and the backend needs a display,
    // which a headless run has not.
    NS_DURING
      [NSApplication sharedApplication];
      theme = [[George alloc] initWithBundle: nil];
      [theme registerFileIcons];
    NS_HANDLER
      theme = nil;
    NS_ENDHANDLER
    if (theme == nil)
      SKIP("the icons cannot be drawn here")

    names = [GeorgeIconNames() objectEnumerator];
    while ((name = [names nextObject]) != nil)
      {
        NSImage *icon = [NSImage imageNamed: name];
        NSImageRep *rep = [[icon representations] lastObject];

        if (icon == nil)
          [missing addObject: name];
        // A custom rep is the theme drawing the icon itself; anything else is
        // the stock artwork still answering the name.
        else if (![rep isKindOfClass: [NSCustomImageRep class]])
          [stock addObject: name];
        else if ([icon TIFFRepresentation] == nil)
          [blank addObject: name];
      }

    // The test framework takes a C format, so the names of whatever failed
    // are handed over as one string.
    PASS([missing count] == 0, "every icon name resolves%s",
         GeorgeNamesLeft(missing));
    PASS([stock count] == 0, "every icon is the theme's own drawing%s",
         GeorgeNamesLeft(stock));
    PASS([blank count] == 0, "every icon draws something%s",
         GeorgeNamesLeft(blank));
    PASS(NSEqualSizes([[NSImage imageNamed: @"common_Tile"] size],
                      NSMakeSize(64, 64)),
         "the icon tile keeps the size a viewer lays its grid out with");
  END_SET("icons")

  [arp release];
  return 0;
}
