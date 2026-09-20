/*
 * Copyright (c) 2026 Simon Peter
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

/* The three faces Mac OS 8 and 9 draw their interface in, as the Mac OS 8
 * Human Interface Guidelines hand them out: the system font for controls,
 * menus and window titles; the small system font where space is tight; and
 * Monaco wherever the text is fixed pitch. GNUstep resolves all of them from
 * its own defaults, and a theme has no hook to change that, so the NSFont
 * class methods that name one are swizzled here. */

#import <AppKit/AppKit.h>
#import <objc/runtime.h>

#import "AppearanceMetrics.h"
#import "George.h"

/* Charcoal was the system font of Mac OS 8.5 and later, but it was cut to
 * Chicago's metrics and there is no liberally licensed revival of it, so
 * Chicago stands in - which is also what Aaron itself drew. */
static NSString *const GeorgeSystemFontFamily = @"Chicago Kare";
/* The guidelines name Geneva as the metric basis of the small system font. */
static NSString *const GeorgeSmallFontFamily = @"Geneva 9.2";
static NSString *const GeorgeFixedFontFamily = @"Monaco 9";

@interface NSFont (George)
+ (NSFont *)george_systemFontOfSize:(CGFloat)size;
+ (NSFont *)george_boldSystemFontOfSize:(CGFloat)size;
+ (NSFont *)george_menuFontOfSize:(CGFloat)size;
+ (NSFont *)george_menuBarFontOfSize:(CGFloat)size;
+ (NSFont *)george_messageFontOfSize:(CGFloat)size;
+ (NSFont *)george_titleBarFontOfSize:(CGFloat)size;
+ (NSFont *)george_labelFontOfSize:(CGFloat)size;
+ (NSFont *)george_controlContentFontOfSize:(CGFloat)size;
+ (NSFont *)george_toolTipsFontOfSize:(CGFloat)size;
+ (NSFont *)george_paletteFontOfSize:(CGFloat)size;
+ (NSFont *)george_userFixedPitchFontOfSize:(CGFloat)size;
@end

/* All three faces are bitmaps built on an em of METRICS_FONT_PLATINUM_EM
 * pixels: Chicago 12 fills it, Geneva 9 and Monaco 9 sit inside it. Asked for
 * at any other size, their pixels land between device pixels and every stem
 * comes out a different width, so a request is snapped to a whole em. */
CGFloat GeorgeSnappedFontSize(CGFloat size)
{
  CGFloat ems = round(size / METRICS_FONT_PLATINUM_EM);

  return MAX(1.0, ems) * METRICS_FONT_PLATINUM_EM;
}

/* Asked once per family: the installed families do not change while the
 * process runs, and resolving a font is on the path of every cell that draws
 * a label. */
static BOOL GeorgeFontFamilyAvailable(NSString *family)
{
  static NSMutableDictionary *resolved = nil;
  NSNumber *known;
  BOOL available;

  if (resolved == nil)
    resolved = [[NSMutableDictionary alloc] initWithCapacity: 3];
  known = [resolved objectForKey: family];
  if (known != nil)
    return [known boolValue];

  available = [[[NSFontManager sharedFontManager] availableFontFamilies]
                containsObject: family];
  if (!available)
    NSLog(@"George: the %@ font is not installed, falling back to the"
          @" GNUstep interface font", family);
  [resolved setObject: [NSNumber numberWithBool: available] forKey: family];
  return available;
}

static NSFont *GeorgeFont(NSString *family, CGFloat size, NSFont *fallback)
{
  NSFont *font;

  /* These swizzles are installed for good when the bundle is loaded, so they
   * keep running under whatever theme the user switches to next; the Platinum
   * faces belong to this theme alone. */
  if (!GeorgeThemeIsActive())
    return fallback;
  if (!GeorgeFontFamilyAvailable(family))
    return fallback;
  if (size <= 0.0 && fallback != nil)
    size = [fallback pointSize];
  // Asked for by family: +fontWithName: wants the PostScript name and hands
  // back the default interface font for anything else, silently.
  // Each face has one weight, so a bold request is served by the same face
  // rather than by a synthesised smear.
  font = [[NSFontManager sharedFontManager]
           fontWithFamily: family
                   traits: 0
                   weight: 5
                     size: GeorgeSnappedFontSize(size)];
  return font != nil ? font : fallback;
}

static void GeorgeSwizzleClassMethod(Class cls, SEL original, SEL replacement)
{
  Class meta = object_getClass(cls);
  Method from = class_getClassMethod(cls, original);
  Method to = class_getClassMethod(cls, replacement);

  if (from == NULL || to == NULL)
    return;
  if (class_addMethod(meta, original, method_getImplementation(to),
                      method_getTypeEncoding(to)))
    class_replaceMethod(meta, replacement, method_getImplementation(from),
                        method_getTypeEncoding(from));
  else
    method_exchangeImplementations(from, to);
}

@implementation NSFont (George)

+ (void)load
{
  Class cls = [NSFont class];

  GeorgeSwizzleClassMethod(cls, @selector(systemFontOfSize:),
                           @selector(george_systemFontOfSize:));
  GeorgeSwizzleClassMethod(cls, @selector(boldSystemFontOfSize:),
                           @selector(george_boldSystemFontOfSize:));
  GeorgeSwizzleClassMethod(cls, @selector(menuFontOfSize:),
                           @selector(george_menuFontOfSize:));
  GeorgeSwizzleClassMethod(cls, @selector(menuBarFontOfSize:),
                           @selector(george_menuBarFontOfSize:));
  GeorgeSwizzleClassMethod(cls, @selector(messageFontOfSize:),
                           @selector(george_messageFontOfSize:));
  GeorgeSwizzleClassMethod(cls, @selector(titleBarFontOfSize:),
                           @selector(george_titleBarFontOfSize:));
  GeorgeSwizzleClassMethod(cls, @selector(labelFontOfSize:),
                           @selector(george_labelFontOfSize:));
  GeorgeSwizzleClassMethod(cls, @selector(controlContentFontOfSize:),
                           @selector(george_controlContentFontOfSize:));
  GeorgeSwizzleClassMethod(cls, @selector(toolTipsFontOfSize:),
                           @selector(george_toolTipsFontOfSize:));
  GeorgeSwizzleClassMethod(cls, @selector(paletteFontOfSize:),
                           @selector(george_paletteFontOfSize:));
  GeorgeSwizzleClassMethod(cls, @selector(userFixedPitchFontOfSize:),
                           @selector(george_userFixedPitchFontOfSize:));
}

/* --- the system font: "you should use the system font for all controls" --- */

+ (NSFont *)george_systemFontOfSize:(CGFloat)size
{
  return GeorgeFont(GeorgeSystemFontFamily, size,
                    [self george_systemFontOfSize: size]);
}

+ (NSFont *)george_boldSystemFontOfSize:(CGFloat)size
{
  return GeorgeFont(GeorgeSystemFontFamily, size,
                    [self george_boldSystemFontOfSize: size]);
}

+ (NSFont *)george_menuFontOfSize:(CGFloat)size
{
  return GeorgeFont(GeorgeSystemFontFamily, size,
                    [self george_menuFontOfSize: size]);
}

+ (NSFont *)george_menuBarFontOfSize:(CGFloat)size
{
  return GeorgeFont(GeorgeSystemFontFamily, size,
                    [self george_menuBarFontOfSize: size]);
}

+ (NSFont *)george_messageFontOfSize:(CGFloat)size
{
  return GeorgeFont(GeorgeSystemFontFamily, size,
                    [self george_messageFontOfSize: size]);
}

+ (NSFont *)george_titleBarFontOfSize:(CGFloat)size
{
  return GeorgeFont(GeorgeSystemFontFamily, size,
                    [self george_titleBarFontOfSize: size]);
}

+ (NSFont *)george_controlContentFontOfSize:(CGFloat)size
{
  return GeorgeFont(GeorgeSystemFontFamily, size,
                    [self george_controlContentFontOfSize: size]);
}

/* --- the small system font: "only when space is limited" --- */

+ (NSFont *)george_labelFontOfSize:(CGFloat)size
{
  return GeorgeFont(GeorgeSmallFontFamily, size,
                    [self george_labelFontOfSize: size]);
}

+ (NSFont *)george_toolTipsFontOfSize:(CGFloat)size
{
  return GeorgeFont(GeorgeSmallFontFamily, size,
                    [self george_toolTipsFontOfSize: size]);
}

/* Palettes and the floating windows they sit in are the case the guidelines
 * mean by limited space. */
+ (NSFont *)george_paletteFontOfSize:(CGFloat)size
{
  return GeorgeFont(GeorgeSmallFontFamily, size,
                    [self george_paletteFontOfSize: size]);
}

/* --- fixed pitch --- */

/* The document font the user chose is left alone; only the fixed pitch one
 * is answered, because Monaco is the face every terminal and listing of the
 * era is set in. */
+ (NSFont *)george_userFixedPitchFontOfSize:(CGFloat)size
{
  return GeorgeFont(GeorgeFixedFontFamily, size,
                    [self george_userFixedPitchFontOfSize: size]);
}

@end
