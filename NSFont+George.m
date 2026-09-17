/*
 * Copyright (c) 2026 Simon Peter
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

/* Platinum draws its interface in Chicago, so George asks for Chicago Kare,
 * the MIT licensed revival shipped in Resources/Fonts. GNUstep resolves the
 * system font from its own defaults, and a theme has no hook to change that,
 * so the NSFont class methods that name a user interface font are swizzled
 * here. */

#import <AppKit/AppKit.h>
#import <objc/runtime.h>

static NSString *const GeorgeUIFontFamily = @"Chicago Kare";

/* Chicago is a bitmap face: it was drawn at twelve pixels and only lands on
 * whole pixels at that size and its multiples. */
static const CGFloat GeorgeUIFontSize = 12.0;

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
@end

/* YES once fontconfig has told us Chicago Kare is installed. Asked once: the
 * family list does not change while the process runs, and resolving a font is
 * on the path of every cell that draws a label. */
static BOOL GeorgeUIFontAvailable(void)
{
  static BOOL resolved = NO;
  static BOOL available = NO;

  if (!resolved)
    {
      available = [[[NSFontManager sharedFontManager] availableFontFamilies]
                    containsObject: GeorgeUIFontFamily];
      if (!available)
        NSLog(@"George: the %@ font is not installed, falling back to the"
              @" GNUstep interface font", GeorgeUIFontFamily);
      resolved = YES;
    }
  return available;
}

static NSFont *GeorgeUIFont(CGFloat size, NSFont *fallback)
{
  NSFont *font;

  if (!GeorgeUIFontAvailable())
    return fallback;
  if (size <= 0.0)
    size = (fallback != nil ? [fallback pointSize] : GeorgeUIFontSize);
  // Asked for by family: +fontWithName: wants the PostScript name and hands
  // back the default interface font for anything else, silently.
  // Chicago Kare has one weight, so a bold request is served by the same
  // face rather than by a synthesised smear.
  font = [[NSFontManager sharedFontManager] fontWithFamily: GeorgeUIFontFamily
                                                    traits: 0
                                                    weight: 5
                                                      size: size];
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
}

+ (NSFont *)george_systemFontOfSize:(CGFloat)size
{
  return GeorgeUIFont(size, [self george_systemFontOfSize: size]);
}

+ (NSFont *)george_boldSystemFontOfSize:(CGFloat)size
{
  return GeorgeUIFont(size, [self george_boldSystemFontOfSize: size]);
}

+ (NSFont *)george_menuFontOfSize:(CGFloat)size
{
  return GeorgeUIFont(size, [self george_menuFontOfSize: size]);
}

+ (NSFont *)george_menuBarFontOfSize:(CGFloat)size
{
  return GeorgeUIFont(size, [self george_menuBarFontOfSize: size]);
}

+ (NSFont *)george_messageFontOfSize:(CGFloat)size
{
  return GeorgeUIFont(size, [self george_messageFontOfSize: size]);
}

+ (NSFont *)george_titleBarFontOfSize:(CGFloat)size
{
  return GeorgeUIFont(size, [self george_titleBarFontOfSize: size]);
}

+ (NSFont *)george_labelFontOfSize:(CGFloat)size
{
  return GeorgeUIFont(size, [self george_labelFontOfSize: size]);
}

+ (NSFont *)george_controlContentFontOfSize:(CGFloat)size
{
  return GeorgeUIFont(size, [self george_controlContentFontOfSize: size]);
}

+ (NSFont *)george_toolTipsFontOfSize:(CGFloat)size
{
  return GeorgeUIFont(size, [self george_toolTipsFontOfSize: size]);
}

+ (NSFont *)george_paletteFontOfSize:(CGFloat)size
{
  return GeorgeUIFont(size, [self george_paletteFontOfSize: size]);
}

@end
