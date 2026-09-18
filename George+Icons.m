/*
 * Copyright (c) 2026 Simon Peter
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

/* The file icons: the Platinum artwork of Mac OS 8, drawn as the shapes it is
 * made of. Every colour of every icon was traced along the edge of its pixels
 * and simplified back onto the straight lines it was drawn from (see
 * GeorgeIconShapes.h and Tools/makeiconshapes.py), so an icon is the same
 * picture at the size it was drawn at, and a drawing rather than a blur at
 * any other.
 *
 * The one icon that is not artwork is the tile a viewer stands an icon on:
 * that is a Platinum surface, and is drawn the way the controls are. */

#import "George+Icons.h"
#import "GeorgePlatinum.h"
#import "GeorgeIconShapes.h"

static const CGFloat GeorgeIconTileSpace = 64.0;
/* Two shapes that touch share an edge, and antialiasing lets the background
 * through it; each shape is grown by half of this to close the seam. */
static const CGFloat GeorgeIconSeam = 0.12;

@interface George (IconsPrivate)
- (NSImage *)imageWithSize:(NSSize)size drawSelector:(SEL)selector;
@end

static NSColor *IconColor(unsigned int rgb)
{
  return [NSColor colorWithCalibratedRed: ((rgb >> 16) & 0xFF) / 255.0
                                   green: ((rgb >> 8) & 0xFF) / 255.0
                                    blue: (rgb & 0xFF) / 255.0
                                   alpha: 1.0];
}

/* The shapes are written with y counted from the top, the way the artwork was
 * laid out; this is the only place that knows better. */
static NSPoint IconAt(NSRect r, CGFloat u, CGFloat x, CGFloat y)
{
  return NSMakePoint(NSMinX(r) + x * u, NSMaxY(r) - y * u);
}

static void GeorgeDrawIcon(NSRect r, const unsigned char *icon)
{
  CGFloat side = icon[0];
  CGFloat u = MIN(NSWidth(r), NSHeight(r)) / side;
  const unsigned char *shape = icon + 1;

  while (*shape != GEORGE_ICON_END)
    {
      NSColor *colour = IconColor(GeorgeIconPalette[*shape++]);
      NSInteger rings = *shape++;
      NSBezierPath *path = [NSBezierPath bezierPath];
      NSInteger ring, i;

      for (ring = 0; ring < rings; ring++)
        {
          NSInteger corners = *shape++;

          for (i = 0; i < corners; i++, shape += 2)
            {
              NSPoint point = IconAt(r, u, shape[0], shape[1]);

              if (i == 0)
                [path moveToPoint: point];
              else
                [path lineToPoint: point];
            }
          [path closePath];
        }
      // Even-odd, so a loop inside another one is the hole it was drawn as.
      [path setWindingRule: NSEvenOddWindingRule];
      [colour set];
      [path fill];
      [path setLineWidth: GeorgeIconSeam * u];
      [path setLineJoinStyle: NSRoundLineJoinStyle];
      [path stroke];
    }
}

@implementation George (Icons)

- (NSRect)iconRectForRep:(id)rep
{
  NSSize size = [rep size];

  return NSMakeRect(0, 0, size.width, size.height);
}

/* Shapes, unlike the controls, are drawn smooth: that is what makes an icon
 * the same icon at any size rather than a picture of one size. */
#define GEORGE_ICON(method_, shapes_)                                \
- (void)method_:(id)rep                                              \
{                                                                    \
  NSGraphicsContext *context = [NSGraphicsContext currentContext];   \
  BOOL antialias = [context shouldAntialias];                        \
                                                                     \
  [context setShouldAntialias: YES];                                 \
  GeorgeDrawIcon([self iconRectForRep: rep], shapes_);               \
  [context setShouldAntialias: antialias];                           \
}

GEORGE_ICON(platinumDrawFolder, GeorgeIconFolder)
GEORGE_ICON(platinumDrawSystemFolder, GeorgeIconSystemFolder)
GEORGE_ICON(platinumDrawLibraryFolder, GeorgeIconExtensionsFolder)
GEORGE_ICON(platinumDrawApplicationFolder, GeorgeIconToolsFolder)
GEORGE_ICON(platinumDrawDocsFolder, GeorgeIconDocumentsFolder)
GEORGE_ICON(platinumDrawDownloadFolder, GeorgeIconDownloadFolder)
GEORGE_ICON(platinumDrawImageFolder, GeorgeIconPictureFolder)
GEORGE_ICON(platinumDrawMusicFolder, GeorgeIconSoundFolder)
GEORGE_ICON(platinumDrawVideoFolder, GeorgeIconMovieFolder)
GEORGE_ICON(platinumDrawDesktopFolder, GeorgeIconMonitorFolder)
GEORGE_ICON(platinumDrawHomeFolder, GeorgeIconUsersFolder)
GEORGE_ICON(platinumDrawRecyclerEmpty, GeorgeIconTrashEmpty)
GEORGE_ICON(platinumDrawRecyclerFull, GeorgeIconTrashFull)
GEORGE_ICON(platinumDrawUnknown, GeorgeIconDocument)
GEORGE_ICON(platinumDrawUnknownApplication, GeorgeIconApplication)
GEORGE_ICON(platinumDrawUnknownTool, GeorgeIconExtension)
GEORGE_ICON(platinumDrawVolume, GeorgeIconHardDisk)
GEORGE_ICON(platinumDrawOtherVolume, GeorgeIconOtherDisk)

/* Mac OS 8 had no icon for a selection of several files, so its document is
 * stacked, which is what a viewer of the time showed for one. */
- (void)platinumDrawMultipleSelection:(id)rep
{
  NSGraphicsContext *context = [NSGraphicsContext currentContext];
  BOOL antialias = [context shouldAntialias];
  NSRect r = [self iconRectForRep: rep];
  CGFloat step = NSWidth(r) / 9.0;
  NSInteger sheet;

  [context setShouldAntialias: YES];
  for (sheet = 2; sheet >= 0; sheet--)
    GeorgeDrawIcon(NSMakeRect(NSMinX(r) + sheet * step,
                              NSMinY(r) + sheet * step,
                              NSWidth(r) - 2 * step, NSHeight(r) - 2 * step),
                   GeorgeIconDocument);
  [context setShouldAntialias: antialias];
}

/* The plinth an icon stands on in a viewer: a Platinum surface rather than a
 * picture of anything, so it is the one thing here drawn as the controls. */
- (void)platinumDrawTile:(id)rep
{
  NSRect r = [self iconRectForRep: rep];
  CGFloat u = NSWidth(r) / GeorgeIconTileSpace;

#define TILE(x_, y_, w_, h_, c_) GeorgeFill(r, NO, u, x_, y_, w_, h_, c_)
  TILE(2, 2, 60, 60, GeorgeGray(0xDD));
  TILE(2, 2, 60, 1, GeorgeGray(0xFF));
  TILE(2, 2, 1, 60, GeorgeGray(0xFF));
  TILE(2, 61, 60, 1, GeorgeGray(0x99));
  TILE(61, 2, 1, 60, GeorgeGray(0x99));
#undef TILE
}

- (void)registerFileIcons
{
  /* Which icon of the era answers which name GNUstep looks up. Where Mac OS 8
   * had nothing for what GNUstep asks about, the nearest icon it did have is
   * used: the folder of tools for a folder of applications, and the folder of
   * users for a home directory. */
  static const struct {
    const char *name;
    const char *selector;
    CGFloat side;
  } icons[] = {
    { "common_Folder", "platinumDrawFolder:", 48 },
    { "common_GSFolder", "platinumDrawSystemFolder:", 48 },
    { "common_LibraryFolder", "platinumDrawLibraryFolder:", 48 },
    { "common_ApplicationFolder", "platinumDrawApplicationFolder:", 48 },
    { "common_DocsFolder", "platinumDrawDocsFolder:", 48 },
    { "common_DownloadFolder", "platinumDrawDownloadFolder:", 48 },
    { "common_ImageFolder", "platinumDrawImageFolder:", 48 },
    { "common_MusicFolder", "platinumDrawMusicFolder:", 48 },
    { "common_VideoFolder", "platinumDrawVideoFolder:", 48 },
    { "common_Desktop", "platinumDrawDesktopFolder:", 48 },
    { "common_HomeDirectory", "platinumDrawHomeFolder:", 48 },
    { "common_Home2_48", "platinumDrawHomeFolder:", 48 },
    /* The small one is the same drawing: shapes do not need artwork
       of their own at another size. */
    { "common_Home", "platinumDrawHomeFolder:", 24 },
    { "common_RecyclerEmpty", "platinumDrawRecyclerEmpty:", 48 },
    { "common_RecyclerFull", "platinumDrawRecyclerFull:", 48 },
    { "common_Unknown", "platinumDrawUnknown:", 48 },
    { "common_UnknownApplication", "platinumDrawUnknownApplication:", 48 },
    { "common_UnknownTool", "platinumDrawUnknownTool:", 48 },
    { "common_MultipleSelection", "platinumDrawMultipleSelection:", 48 },
    { "common_Root_Apple", "platinumDrawVolume:", 48 },
    { "common_Root_PC", "platinumDrawOtherVolume:", 48 },
    { "common_Tile", "platinumDrawTile:", 64 },
    { NULL, NULL, 0 }
  };
  NSUInteger i;

  for (i = 0; icons[i].name != NULL; i++)
    {
      NSString *name = [NSString stringWithUTF8String: icons[i].name];
      NSImage *old = [NSImage imageNamed: name];
      NSSize size = NSMakeSize(icons[i].side, icons[i].side);
      NSImage *image;
      NSString *registered;

      image = [self imageWithSize: size
                     drawSelector: NSSelectorFromString(
                       [NSString stringWithUTF8String: icons[i].selector])];
      // The name belongs to the image that holds it, so it is copied before
      // the old one is let go of.
      registered = AUTORELEASE([([old name] ? [old name] : name) copy]);
      [old setName: nil];
      [image setName: registered];
    }
}

@end
