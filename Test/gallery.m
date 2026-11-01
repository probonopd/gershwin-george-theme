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

/* A small tree, one branch of it opened, for the disclosure triangles. */
@interface GalleryTree : NSObject
@end

@implementation GalleryTree

/* An outline tracks its items by pointer, so each must be the same object
 * every time it is asked for. */
+ (NSString *)nameAtIndex:(NSInteger)index inFolder:(BOOL)inFolder
{
  static NSMutableDictionary *names = nil;
  NSString *name = [NSString stringWithFormat: @"%@ %ld",
                             inFolder ? @"Leaf" : @"Folder", (long)index + 1];

  if (names == nil)
    {
      names = [NSMutableDictionary new];
    }
  if ([names objectForKey: name] == nil)
    {
      [names setObject: name forKey: name];
    }
  return [names objectForKey: name];
}

- (NSInteger)outlineView:(NSOutlineView *)view numberOfChildrenOfItem:(id)item
{
  return item == nil ? 3 : ([item isEqual: @"Folder 1"] ? 2 : 0);
}

- (id)outlineView:(NSOutlineView *)view child:(NSInteger)index ofItem:(id)item
{
  return [GalleryTree nameAtIndex: index inFolder: item != nil];
}

- (BOOL)outlineView:(NSOutlineView *)view isItemExpandable:(id)item
{
  return [item hasPrefix: @"Folder"];
}

- (id)outlineView:(NSOutlineView *)view
  objectValueForTableColumn:(NSTableColumn *)column
                     byItem:(id)item
{
  return item;
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
  item = [file addItemWithTitle: @"Checked" action: @selector(newDocument:) keyEquivalent: @""];
  [item setState: NSOnState];
  item = [file addItemWithTitle: @"Mixed" action: @selector(newDocument:) keyEquivalent: @""];
  [item setState: NSMixedState];
  [file addItemWithTitle: @"Quit" action: @selector(terminate:) keyEquivalent: @"q"];
  [main addItemWithTitle: @"Edit" action: NULL keyEquivalent: @""];
  [main addItemWithTitle: @"View" action: NULL keyEquivalent: @""];
  [NSApp setMainMenu: main];
}

/* Every state the main window has no room for: nothing here can be reached by
 * pressing something on a display without a person at it, so held controls are
 * put in that state by hand. */
- (void)buildStatesWindow
{
  NSWindow *states = [[NSWindow alloc]
    initWithContentRect: NSMakeRect(0, 0, 620, 500)
              styleMask: NSTitledWindowMask | NSClosableWindowMask
                backing: NSBackingStoreBuffered
                  defer: NO];
  NSView *content = [states contentView];
  static const NSInteger stateOfKind[] = { 0, 1, -1, 0, 1, -1 };
  NSInteger i;

  [states setTitle: @"George States"];

  for (i = 0; i < 12; i++)
    {
      NSButton *b = [[NSButton alloc] initWithFrame:
        NSMakeRect(10 + (i % 6) * 100, 470 - (i / 6) * 24, 96, 20)];
      NSInteger kind = i % 6;

      [b setButtonType: (i < 6 ? NSSwitchButton : NSRadioButton)];
      [b setTitle: [NSString stringWithFormat: @"%@", @[@"Off", @"On", @"Mixed",
                    @"Off dim", @"On dim", @"Mix dim"][kind]]];
      [b setAllowsMixedState: YES];
      [b setState: stateOfKind[kind]];
      [b setEnabled: kind < 3];
      [content addSubview: b];
    }
  for (i = 0; i < 4; i++)
    {
      NSButton *b = [[NSButton alloc] initWithFrame:
        NSMakeRect(10 + i * 100, 422, 96, 20)];

      [b setButtonType: (i < 2 ? NSSwitchButton : NSRadioButton)];
      [b setTitle: @"Held"];
      [b setState: i % 2];
      [[b cell] setHighlighted: YES];
      [content addSubview: b];
    }

  for (i = 0; i < 3; i++)
    {
      NSSlider *s = [[NSSlider alloc] initWithFrame:
        NSMakeRect(10 + i * 130, 390, 120, 20)];

      [s setDoubleValue: 0.2 + i * 0.3];
      [s setEnabled: i != 1];
      if (i == 2)
        {
          [[s cell] setHighlighted: YES];
        }
      [content addSubview: s];
    }
  for (i = 0; i < 2; i++)
    {
      NSSlider *s = [[NSSlider alloc] initWithFrame:
        NSMakeRect(420 + i * 30, 340, 20, 110)];

      [s setDoubleValue: 0.6];
      [s setEnabled: i == 0];
      [content addSubview: s];
    }

  {
    NSPopUpButton *p;
    NSStepper *step;

    p = [[NSPopUpButton alloc] initWithFrame: NSMakeRect(10, 360, 130, 22) pullsDown: YES];
    [p addItemsWithTitles: @[@"Pull-down", @"Two"]];
    [content addSubview: p];

    p = [[NSPopUpButton alloc] initWithFrame: NSMakeRect(150, 360, 130, 22)];
    [p addItemsWithTitles: @[@"Dimmed", @"Two"]];
    [p setEnabled: NO];
    [content addSubview: p];

    p = [[NSPopUpButton alloc] initWithFrame: NSMakeRect(290, 360, 120, 22)];
    [p addItemsWithTitles: @[@"Borderless", @"Two"]];
    [p setBordered: NO];
    [content addSubview: p];

    p = [[NSPopUpButton alloc] initWithFrame: NSMakeRect(10, 330, 50, 22)];
    [p addItemsWithTitles: @[@"A title that fits exactly", @"Two"]];
    [p sizeToFit];
    [content addSubview: p];

    p = [[NSPopUpButton alloc] initWithFrame: NSMakeRect(290, 330, 120, 22)];
    [p addItemsWithTitles: @[@"Checked", @"Mixed", @"Plain"]];
    [[p itemAtIndex: 1] setState: NSMixedState];
    [content addSubview: p];

    step = [[NSStepper alloc] initWithFrame: NSMakeRect(490, 400, 15, 22)];
    [step setEnabled: NO];
    [content addSubview: step];
    step = [[NSStepper alloc] initWithFrame: NSMakeRect(520, 400, 18, 26)];
    [content addSubview: step];
  }

  {
    NSOutlineView *tree = [[NSOutlineView alloc] initWithFrame: NSMakeRect(0, 0, 180, 120)];
    NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier: @"tree"];
    NSScrollView *scroll = [[NSScrollView alloc] initWithFrame: NSMakeRect(10, 190, 200, 130)];
    GalleryTree *data = [GalleryTree new];

    [column setWidth: 170];
    [tree addTableColumn: column];
    [tree setOutlineTableColumn: column];
    [tree setDataSource: data];
    [scroll setHasVerticalScroller: YES];
    [scroll setBorderType: NSBezelBorder];
    [scroll setDocumentView: tree];
    [content addSubview: scroll];
    [tree expandItem: [GalleryTree nameAtIndex: 0 inFolder: NO]];
  }

  {
    NSTableView *table = [[NSTableView alloc] initWithFrame: NSMakeRect(0, 0, 360, 100)];
    NSScrollView *scroll = [[NSScrollView alloc] initWithFrame: NSMakeRect(230, 190, 380, 130)];
    NSArray *names = @[@"one", @"two", @"three"];
    NSTableColumn *column;

    for (i = 0; i < 3; i++)
      {
        column = [[NSTableColumn alloc] initWithIdentifier: names[i]];
        [column setWidth: 110];
        [[column headerCell] setStringValue: [names[i] capitalizedString]];
        [column setSortDescriptorPrototype:
          [NSSortDescriptor sortDescriptorWithKey: names[i] ascending: YES]];
        [table addTableColumn: column];
      }
    [table setSortDescriptors:
      @[[NSSortDescriptor sortDescriptorWithKey: @"two" ascending: NO]]];
    [table setHighlightedTableColumn: [table tableColumnWithIdentifier: @"three"]];
    [table setDataSource: [GalleryRows new]];
    [scroll setHasVerticalScroller: YES];
    [scroll setBorderType: NSBezelBorder];
    [scroll setDocumentView: table];
    [content addSubview: scroll];
  }

  {
    NSTabView *tabs = [[NSTabView alloc] initWithFrame: NSMakeRect(10, 90, 320, 90)];
    NSBox *box = [[NSBox alloc] initWithFrame: NSMakeRect(340, 90, 270, 90)];
    NSBox *wide = [[NSBox alloc] initWithFrame: NSMakeRect(340, 10, 130, 70)];
    NSTabView *bottom = [[NSTabView alloc] initWithFrame: NSMakeRect(10, 5, 320, 80)];
    NSButton *focused = [[NSButton alloc] initWithFrame: NSMakeRect(490, 40, 110, 24)];

    for (i = 0; i < 3; i++)
      {
        NSTabViewItem *item = [[NSTabViewItem alloc] initWithIdentifier: @(i)];
        NSTabViewItem *under = [[NSTabViewItem alloc] initWithIdentifier: @(i)];

        [item setLabel: @[@"First", @"Second", @"Third"][i]];
        [under setLabel: @[@"Under", @"Below", @"Beneath"][i]];
        [tabs addTabViewItem: item];
        [bottom addTabViewItem: under];
      }
    [tabs selectTabViewItemAtIndex: 1];
    [bottom setTabViewType: NSBottomTabsBezelBorder];
    [content addSubview: tabs];
    [content addSubview: bottom];
    [box setTitle: @"Title on the line"];
    [content addSubview: box];
    [wide setTitle: @"A title as wide as this box"];
    [content addSubview: wide];
    [focused setTitle: @"Focused"];
    [focused setBezelStyle: NSRoundedBezelStyle];
    [content addSubview: focused];
    [states setInitialFirstResponder: focused];
    [states makeFirstResponder: focused];
  }

  [states setFrameTopLeftPoint:
            NSMakePoint(NSMaxX([[NSScreen mainScreen] frame]) - NSWidth([states frame]) - 10,
                        NSMaxY([[NSScreen mainScreen] frame]) - 40)];
  [states orderFront: nil];
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

  [self buildStatesWindow];
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
