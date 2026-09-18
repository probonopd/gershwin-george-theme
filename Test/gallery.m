/*
 * Copyright (c) 2026 Simon Peter
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

/* gallery - one window holding every control George draws, so the Platinum
 * artwork can be looked at side by side and compared against Aaron. */

#import <AppKit/AppKit.h>
#import <GNUstepGUI/GSTheme.h>

/* The window manager asks the theme for title bars and window frames by these
 * selectors; the preview below calls them the same way it does. */
@interface GSTheme (GalleryDecorations)
- (void)drawtitleRect:(NSRect)rect
         forStyleMask:(unsigned int)styleMask
                state:(int)inputState
             andTitle:(NSString *)title;
- (CGFloat)windowFrameBorderWidth;
- (NSColor *)windowFrameBorderColorAtDepth:(NSInteger)depth
                                      edge:(NSInteger)edge
                                    active:(BOOL)active;
@end

/* Three sample title bars with the frame the window manager would draw under
 * them, so the decorations can be inspected without a window manager. */
@interface GalleryDecorations : NSView
@end

@implementation GalleryDecorations

- (void)drawRect:(NSRect)rect
{
  static const struct { unsigned int mask; int state; const char *title; }
    samples[] = {
      { NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask
        | NSResizableWindowMask, 0, "Active window" },
      { NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask
        | NSResizableWindowMask, 1, "Inactive window" },
      { NSTitledWindowMask | NSClosableWindowMask | NSUtilityWindowMask, 0,
        "Floating panel" }
    };
  const NSUInteger count = sizeof(samples) / sizeof(samples[0]);
  GSTheme *theme = [GSTheme theme];
  CGFloat titlebar = [theme titlebarHeight];
  CGFloat border = [theme windowFrameBorderWidth];
  CGFloat width = floor(NSWidth([self bounds]) / count) - 8;
  NSUInteger i;

  for (i = 0; i < count; i++)
    {
      NSRect frame = NSMakeRect(NSMinX([self bounds]) + i * (width + 8), 0,
                                width, NSHeight([self bounds]));
      NSRect bar = NSMakeRect(NSMinX(frame), NSMaxY(frame) - titlebar,
                              width, titlebar);
      BOOL active = (samples[i].state == 0);
      NSInteger depth;

      [theme drawtitleRect: bar
             forStyleMask: samples[i].mask
                    state: samples[i].state
                 andTitle: [NSString stringWithUTF8String: samples[i].title]];
      // The client area, ringed by the border the window manager draws.
      [[NSColor whiteColor] set];
      NSRectFill(NSMakeRect(NSMinX(frame), NSMinY(frame), width,
                            NSHeight(frame) - titlebar));
      for (depth = 0; depth < (NSInteger)border; depth++)
        {
          NSRect line = NSMakeRect(NSMinX(frame) + depth, NSMinY(frame) + depth,
                                   width - 2 * depth,
                                   NSHeight(frame) - titlebar - depth);

          [[theme windowFrameBorderColorAtDepth: depth edge: 0 active: active] set];
          NSRectFill(NSMakeRect(NSMinX(line), NSMinY(line), 1, NSHeight(line)));
          [[theme windowFrameBorderColorAtDepth: depth edge: 1 active: active] set];
          NSRectFill(NSMakeRect(NSMaxX(line) - 1, NSMinY(line), 1, NSHeight(line)));
          [[theme windowFrameBorderColorAtDepth: depth edge: 2 active: active] set];
          NSRectFill(NSMakeRect(NSMinX(line), NSMinY(line), NSWidth(line), 1));
        }
    }
}

@end

static NSTextField *label(NSString *text, NSRect frame)
{
  NSTextField *field = [[NSTextField alloc] initWithFrame: frame];

  [field setStringValue: text];
  [field setEditable: NO];
  [field setSelectable: NO];
  [field setBordered: NO];
  [field setBezeled: NO];
  [field setDrawsBackground: NO];
  return field;
}

@interface GalleryDelegate : NSObject
{
  NSProgressIndicator *_indeterminate;
}
@end

/* Enough rows and columns that both scrollers have something to scroll. */
@interface GalleryRows : NSObject
@end

@implementation GalleryRows

- (NSInteger)numberOfRowsInTableView:(NSTableView *)view
{
  return 40;
}

- (id)tableView:(NSTableView *)view
  objectValueForTableColumn:(NSTableColumn *)column
                        row:(NSInteger)row
{
  return [NSString stringWithFormat: @"%@ %ld", [column identifier], (long)row + 1];
}

@end

/* The file icons the theme registers, laid out so the whole set can be seen
 * at once. */
@interface GalleryIcons : NSView
@end

@implementation GalleryIcons

- (void)drawRect:(NSRect)dirtyRect
{
  NSArray *names = @[@"common_Folder", @"common_GSFolder", @"common_LibraryFolder",
                     @"common_ApplicationFolder", @"common_DocsFolder",
                     @"common_DownloadFolder", @"common_ImageFolder",
                     @"common_MusicFolder", @"common_VideoFolder", @"common_Desktop",
                     @"common_HomeDirectory", @"common_Home2_48", @"common_Home",
                     @"common_RecyclerEmpty", @"common_RecyclerFull", @"common_Unknown",
                     @"common_UnknownApplication", @"common_UnknownTool",
                     @"common_MultipleSelection", @"common_Root_Apple",
                     @"common_Root_PC", @"common_Tile"];
  NSDictionary *label = @{ NSFontAttributeName: [NSFont labelFontOfSize: 0],
                           NSForegroundColorAttributeName: [NSColor controlTextColor] };
  NSUInteger columns = 6;
  CGFloat cell = 108, row = 92;
  NSUInteger i;

  (void)dirtyRect;
  for (i = 0; i < [names count]; i++)
    {
      NSString *name = [names objectAtIndex: i];
      NSImage *icon = [NSImage imageNamed: name];
      NSString *shown = [name hasPrefix: @"common_"]
        ? [name substringFromIndex: 7] : name;
      NSSize size = icon ? [icon size] : NSZeroSize;
      CGFloat x = (i % columns) * cell;
      CGFloat y = NSMaxY([self bounds]) - (i / columns + 1) * row;
      NSSize text = [shown sizeWithAttributes: label];

      if (icon != nil)
        [icon drawAtPoint: NSMakePoint(round(x + (cell - size.width) / 2),
                                       round(y + row - 16 - size.height))
                 fromRect: NSZeroRect
                operation: NSCompositeSourceOver
                 fraction: 1.0];
      [shown drawAtPoint: NSMakePoint(round(x + (cell - text.width) / 2), y)
          withAttributes: label];
    }
}

@end

@implementation GalleryDelegate

/* A menu bar and one open menu, so the menu artwork is on screen too. */
- (void)buildMenu
{
  NSMenu *main = [[NSMenu alloc] initWithTitle: @"Gallery"];
  NSMenu *file = [[NSMenu alloc] initWithTitle: @"File"];
  id<NSMenuItem> item;

  item = [main addItemWithTitle: @"File" action: NULL keyEquivalent: @""];
  [main setSubmenu: file forItem: item];
  [file addItemWithTitle: @"New" action: @selector(newDocument:) keyEquivalent: @"n"];
  [file addItemWithTitle: @"Open" action: @selector(openDocument:) keyEquivalent: @"o"];
  [file addItem: [NSMenuItem separatorItem]];
  item = [file addItemWithTitle: @"Disabled" action: NULL keyEquivalent: @""];
  [file addItemWithTitle: @"Quit" action: @selector(terminate:) keyEquivalent: @"q"];
  [main addItemWithTitle: @"Edit" action: NULL keyEquivalent: @""];
  [main addItemWithTitle: @"View" action: NULL keyEquivalent: @""];
  [NSApp setMainMenu: main];
}

- (void)applicationDidFinishLaunching:(NSNotification *)note
{
  NSWindow *window = [[NSWindow alloc]
    initWithContentRect: NSMakeRect(0, 0, 620, 560)
              styleMask: NSTitledWindowMask | NSClosableWindowMask
                         | NSMiniaturizableWindowMask | NSResizableWindowMask
                backing: NSBackingStoreBuffered
                  defer: NO];
  NSView *content = [window contentView];
  NSButton *push, *def, *check, *radio, *bevel;
  NSTextField *text;
  NSSlider *slider;
  NSProgressIndicator *bar;
  NSStepper *stepper;
  NSPopUpButton *popup;
  NSBox *box;
  NSTabView *tabs;
  NSTabViewItem *first, *second;
  NSScrollView *scroll;
  NSTableView *table;
  NSTableColumn *column;
  NSColorWell *well;
  NSSegmentedControl *segments;

  [window setTitle: @"George Gallery"];

  push = [[NSButton alloc] initWithFrame: NSMakeRect(20, 428, 100, 24)];
  [push setTitle: @"Button"];
  [content addSubview: push];

  def = [[NSButton alloc] initWithFrame: NSMakeRect(130, 428, 100, 24)];
  [def setTitle: @"Default"];
  [content addSubview: def];
  [window setDefaultButtonCell: [def cell]];

  bevel = [[NSButton alloc] initWithFrame: NSMakeRect(240, 428, 100, 24)];
  [bevel setTitle: @"Bevel"];
  [bevel setBezelStyle: NSRegularSquareBezelStyle];
  [content addSubview: bevel];

  push = [[NSButton alloc] initWithFrame: NSMakeRect(350, 428, 100, 24)];
  [push setTitle: @"Disabled"];
  [push setEnabled: NO];
  [content addSubview: push];

  check = [[NSButton alloc] initWithFrame: NSMakeRect(20, 396, 120, 20)];
  [check setButtonType: NSSwitchButton];
  [check setTitle: @"Checkbox"];
  [check setState: NSOnState];
  [content addSubview: check];

  check = [[NSButton alloc] initWithFrame: NSMakeRect(150, 396, 120, 20)];
  [check setButtonType: NSSwitchButton];
  [check setTitle: @"Unchecked"];
  [content addSubview: check];

  radio = [[NSButton alloc] initWithFrame: NSMakeRect(280, 396, 120, 20)];
  [radio setButtonType: NSRadioButton];
  [radio setTitle: @"Radio on"];
  [radio setState: NSOnState];
  [content addSubview: radio];

  radio = [[NSButton alloc] initWithFrame: NSMakeRect(410, 396, 120, 20)];
  [radio setButtonType: NSRadioButton];
  [radio setTitle: @"Radio off"];
  [content addSubview: radio];

  [content addSubview: label(@"Text field", NSMakeRect(20, 364, 80, 20))];
  text = [[NSTextField alloc] initWithFrame: NSMakeRect(110, 362, 180, 22)];
  [text setStringValue: @"Editable text"];
  [content addSubview: text];

  popup = [[NSPopUpButton alloc] initWithFrame: NSMakeRect(310, 362, 140, 22)];
  [popup addItemWithTitle: @"Pop-up one"];
  [popup addItemWithTitle: @"Pop-up two"];
  [content addSubview: popup];

  stepper = [[NSStepper alloc] initWithFrame: NSMakeRect(470, 362, 15, 22)];
  [content addSubview: stepper];

  slider = [[NSSlider alloc] initWithFrame: NSMakeRect(20, 326, 200, 20)];
  [slider setMinValue: 0.0];
  [slider setMaxValue: 1.0];
  [slider setDoubleValue: 0.4];
  [content addSubview: slider];

  segments = [[NSSegmentedControl alloc] initWithFrame: NSMakeRect(240, 326, 180, 22)];
  [segments setSegmentCount: 3];
  [segments setLabel: @"One" forSegment: 0];
  [segments setLabel: @"Two" forSegment: 1];
  [segments setLabel: @"Three" forSegment: 2];
  [segments setSelectedSegment: 1];
  [content addSubview: segments];

  well = [[NSColorWell alloc] initWithFrame: NSMakeRect(440, 322, 44, 26)];
  [well setColor: [NSColor redColor]];
  [content addSubview: well];

  bar = [[NSProgressIndicator alloc] initWithFrame: NSMakeRect(20, 296, 200, 16)];
  [bar setIndeterminate: NO];
  [bar setDoubleValue: 60.0];
  [content addSubview: bar];

  _indeterminate = [[NSProgressIndicator alloc]
                     initWithFrame: NSMakeRect(240, 296, 200, 16)];
  [_indeterminate setIndeterminate: YES];
  [content addSubview: _indeterminate];
  [_indeterminate startAnimation: self];

  box = [[NSBox alloc] initWithFrame: NSMakeRect(20, 176, 260, 110)];
  [box setTitle: @"Group box"];
  [content addSubview: box];

  check = [[NSButton alloc] initWithFrame: NSMakeRect(12, 40, 120, 20)];
  [check setButtonType: NSSwitchButton];
  [check setTitle: @"In a box"];
  [[box contentView] addSubview: check];

  tabs = [[NSTabView alloc] initWithFrame: NSMakeRect(300, 176, 300, 110)];
  first = [[NSTabViewItem alloc] initWithIdentifier: @"a"];
  [first setLabel: @"First"];
  second = [[NSTabViewItem alloc] initWithIdentifier: @"b"];
  [second setLabel: @"Second"];
  [tabs addTabViewItem: first];
  [tabs addTabViewItem: second];
  [content addSubview: tabs];

  table = [[NSTableView alloc] initWithFrame: NSMakeRect(0, 0, 560, 140)];
  column = [[NSTableColumn alloc] initWithIdentifier: @"one"];
  [[column headerCell] setStringValue: @"Column"];
  [column setWidth: 200];
  [table addTableColumn: column];
  column = [[NSTableColumn alloc] initWithIdentifier: @"two"];
  [[column headerCell] setStringValue: @"Another column"];
  [column setWidth: 340];
  [table addTableColumn: column];

  scroll = [[NSScrollView alloc] initWithFrame: NSMakeRect(20, 20, 580, 140)];
  [scroll setHasVerticalScroller: YES];
  [scroll setHasHorizontalScroller: YES];
  [scroll setBorderType: NSBezelBorder];
  [table setDataSource: [GalleryRows new]];
  [scroll setDocumentView: table];
  [content addSubview: scroll];

  {
    NSScroller *bare = [[NSScroller alloc]
                         initWithFrame: NSMakeRect(505, 296, 100, 16)];

    [bare setEnabled: YES];
    [bare setDoubleValue: 0.3];
    [bare setKnobProportion: 0.4];
    [content addSubview: bare];
  }

  {
    GalleryDecorations *preview = [[GalleryDecorations alloc]
                                    initWithFrame: NSMakeRect(20, 480, 580, 70)];

    [content addSubview: preview];
  }

  {
    NSWindow *icons = [[NSWindow alloc]
      initWithContentRect: NSMakeRect(0, 0, 668, 400)
                styleMask: NSTitledWindowMask | NSClosableWindowMask
                           | NSMiniaturizableWindowMask
                  backing: NSBackingStoreBuffered
                    defer: NO];
    GalleryIcons *grid = [[GalleryIcons alloc]
                           initWithFrame: NSMakeRect(10, 10, 648, 380)];

    [icons setTitle: @"Icons"];
    [[icons contentView] addSubview: grid];
    [icons orderFront: nil];
  }

  [window center];
  [window makeKeyAndOrderFront: nil];
  [self buildMenu];
}

@end

int main(int argc, const char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  GalleryDelegate *delegate = [GalleryDelegate new];

  [NSApplication sharedApplication];
  [NSApp setDelegate: delegate];
  [pool release];
  return NSApplicationMain(argc, argv);
}
