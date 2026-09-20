/*
 * Copyright (c) 2026 Simon Peter
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

/* George: a GNUstep theme in the Platinum look of Mac OS 8, as Greg
 * Landweber's Aaron extension drew it. Every part is pixel art drawn in code;
 * this file is only the wiring that hands each GSTheme drawing hook to the
 * matching Platinum part. */

#import "George.h"
#import "George+Icons.h"
#import "George+Menu.h"
#import "George+Parts.h"
#import "George+TabView.h"
#import "George+TitleBar.h"
#import "GeorgePlatinum.h"
#import "GeorgeScrollerCells.h"
#import "AppearanceMetrics.h"

/* Drawn by GSStandardWindowDecorationView for windows that GNUstep decorates
 * itself; not declared in GSTheme.h. */
@interface GSTheme (GeorgeResizeBar)
- (void)drawResizeBarRect:(NSRect)resizeBarRect;
@end

/* Platinum scroll bars are 16 pixels wide, arrows included. */
static const CGFloat GeorgeScrollerWidth = 16.0;

/* Thickness of the sunken track a linear slider runs in. */
static const CGFloat GeorgeSliderTrackThickness = 6.0;

static BOOL gGeorgeActive = NO;

BOOL GeorgeThemeIsActive(void)
{
  return gGeorgeActive;
}

static BOOL GeorgeStateIsPressed(GSThemeControlState state)
{
  return state == GSThemeHighlightedState
    || state == GSThemeHighlightedFirstResponderState
    || state == GSThemeSelectedState
    || state == GSThemeSelectedFirstResponderState;
}

@implementation George

- (void)activate
{
  gGeorgeActive = YES;
  [super activate];
  // The checkbox, radio and arrow images are drawn on demand, so they can
  // only be registered once the theme is the current one.
  [self registerControlImages];
  [self registerFileIcons];
}

- (void)deactivate
{
  gGeorgeActive = NO;
  [super deactivate];
}

/* Platinum puts every window and control on the same #DDDDDD gray, so the
 * system colors are handed out here instead of coming from a color list. */
- (NSColorList *)colors
{
  static NSColorList *platinum = nil;
  NSColorList *base = [super colors];

  if (platinum == nil)
    {
      NSDictionary *overrides = @{
        @"windowBackgroundColor": GeorgeGray(0xDD),
        @"controlBackgroundColor": GeorgeGray(0xDD),
        @"controlColor": GeorgeGray(0xDD),
        @"controlHighlightColor": GeorgeGray(0xFF),
        @"controlLightHighlightColor": GeorgeGray(0xFF),
        @"controlShadowColor": GeorgeGray(0x88),
        @"controlDarkShadowColor": GeorgeGray(0x00),
        @"controlTextColor": GeorgeGray(0x00),
        @"disabledControlTextColor": GeorgeGray(0x88),
        @"scrollBarColor": GeorgeGray(0xDD),
        @"knobColor": GeorgeGray(0xDD),
        @"selectedControlColor": GeorgeSchemeColor(5),
        @"selectedMenuItemColor": GeorgeSchemeColor(3),
        @"selectedTextBackgroundColor": GeorgeSchemeColor(5),
        @"selectedTextColor": GeorgeGray(0x00),
        @"textBackgroundColor": GeorgeGray(0xFF),
        @"textColor": GeorgeGray(0x00),
        @"gridColor": GeorgeGray(0xBB)
      };
      NSEnumerator *keys;
      NSString *key;

      // George ships no color list of its own, so there is usually no list to
      // start from; whatever the overrides leave out is filled in from the
      // default system colors by NSColor when the theme activates.
      platinum = [[NSColorList alloc] initWithName: @"System"];
      keys = [[base allKeys] objectEnumerator];
      while ((key = [keys nextObject]) != nil)
        [platinum setColor: [base colorWithKey: key] forKey: key];
      keys = [overrides keyEnumerator];
      while ((key = [keys nextObject]) != nil)
        [platinum setColor: [overrides objectForKey: key] forKey: key];
    }
  return platinum;
}

#pragma mark - Buttons

/* Platinum marks the default button with its ring, never with a return glyph
 * inside the button, so no image is put on the cell here. */
- (void)setKeyEquivalent:(NSString *)key forButtonCell:(NSButtonCell *)cell
{
}

- (void)drawButton:(NSRect)frame
                in:(NSCell *)cell
              view:(NSView *)view
             style:(int)style
             state:(GSThemeControlState)state
{
  BOOL flipped = [view isFlipped];
  BOOL pressed = GeorgeStateIsPressed(state);
  BOOL enabled = (state != GSThemeDisabledState);

  switch (style)
    {
      case NSRoundedBezelStyle:
      case NSRoundRectBezelStyle:
      case NSTexturedRoundedBezelStyle:
      case 0:
        // The push button: the only Platinum button with cut corners.
        [self drawPushButtonInRect: frame flipped: flipped
                          pressed: pressed enabled: enabled];
        // There is no room around a GNUstep button for Platinum's heavy
        // ring, so the default button is marked with a doubled outline.
        if (enabled && [[view window] defaultButtonCell] == (NSButtonCell *)cell)
          [self drawDefaultOutlineInRect: frame flipped: flipped];
        break;
      default:
        [self drawBevelButtonInRect: frame flipped: flipped
                           pressed: pressed enabled: enabled];
        break;
    }
}

- (GSThemeMargins)buttonMarginsForCell:(NSCell *)cell
                                 style:(int)style
                                 state:(GSThemeControlState)state
{
  GSThemeMargins margins;

  switch (style)
    {
      case NSRoundedBezelStyle:
      case NSRoundRectBezelStyle:
      case NSTexturedRoundedBezelStyle:
      case 0:
        // Outline, two bevel rings and a pixel of air.
        margins.left = margins.right = 5;
        margins.top = margins.bottom = 4;
        break;
      default:
        margins.left = margins.right = margins.top = margins.bottom = 3;
        break;
    }
  return margins;
}

/* Platinum has no focus ring; what marks the keyboard focus is the two pixel
 * band in the accent color that the Appearance Manager draws around the
 * focused part. */
- (void)drawFocusFrame:(NSRect)frame view:(NSView *)view
{
  NSRect r = NSIntegralRect(frame);

  [GeorgeSchemeColor(3) set];
  NSFrameRect(r);
  NSFrameRect(NSInsetRect(r, 1, 1));
}

- (void)drawWindowBackground:(NSRect)frame view:(NSView *)view
{
  [GeorgeGray(0xDD) set];
  NSRectFill(frame);
}

#pragma mark - Borders

- (void)drawBorderType:(NSBorderType)aType
                 frame:(NSRect)frame
                  view:(NSView *)view
{
  BOOL flipped = [view isFlipped];

  switch (aType)
    {
      case NSLineBorder:
        [GeorgeGray(0x00) set];
        NSFrameRect(frame);
        break;
      case NSGrooveBorder:
        [self drawGrooveInRect: frame flipped: flipped];
        break;
      case NSBezelBorder:
        // Text fields, lists and anything else that holds content sit in a
        // sunken well. The content is filled in by the caller afterwards, so
        // only the frame is drawn here.
        [self drawWellInRect: frame flipped: flipped fill: nil];
        break;
      case NSNoBorder:
      default:
        break;
    }
}

- (NSSize)sizeForBorderType:(NSBorderType)aType
{
  if (aType == NSNoBorder)
    return NSZeroSize;
  return NSMakeSize(2, 2);
}

- (void)drawBorderForImageFrameStyle:(NSImageFrameStyle)frameStyle
                               frame:(NSRect)frame
                                view:(NSView *)view
{
  BOOL flipped = [view isFlipped];

  switch (frameStyle)
    {
      case NSImageFrameNone:
        break;
      case NSImageFramePhoto:
      case NSImageFrameGrayBezel:
      case NSImageFrameButton:
        [self drawWellInRect: frame flipped: flipped fill: nil];
        break;
      case NSImageFrameGroove:
        [self drawGrooveInRect: frame flipped: flipped];
        break;
    }
}

- (NSSize)sizeForImageFrameStyle:(NSImageFrameStyle)frameStyle
{
  if (frameStyle == NSImageFrameNone)
    return NSZeroSize;
  return NSMakeSize(2, 2);
}

#pragma mark - Mid level drawing

/* NSCell and friends reach for these primitives directly, so they are
 * redirected to the Platinum parts as well; otherwise a control that does
 * not have a hook of its own would still be drawn in the default look. */

- (NSRect)drawButton:(NSRect)border withClip:(NSRect)clip
{
  [self drawBevelButtonInRect: border flipped: [[NSView focusView] isFlipped]
                     pressed: NO enabled: YES];
  return NSInsetRect(border, 2, 2);
}

- (NSRect)drawDarkButton:(NSRect)border withClip:(NSRect)clip
{
  [self drawBevelButtonInRect: border flipped: [[NSView focusView] isFlipped]
                     pressed: YES enabled: YES];
  return NSInsetRect(border, 2, 2);
}

- (NSRect)drawGrayBezel:(NSRect)border withClip:(NSRect)clip
{
  [self drawWellInRect: border flipped: [[NSView focusView] isFlipped] fill: nil];
  return NSInsetRect(border, 2, 2);
}

- (NSRect)drawWhiteBezel:(NSRect)border withClip:(NSRect)clip
{
  [self drawWellInRect: border flipped: [[NSView focusView] isFlipped]
                  fill: GeorgeGray(0xFF)];
  return NSInsetRect(border, 2, 2);
}

- (NSRect)drawDarkBezel:(NSRect)border withClip:(NSRect)clip
{
  [self drawWellInRect: border flipped: [[NSView focusView] isFlipped] fill: nil];
  return NSInsetRect(border, 2, 2);
}

- (NSRect)drawLightBezel:(NSRect)border withClip:(NSRect)clip
{
  [self drawWellInRect: border flipped: [[NSView focusView] isFlipped] fill: nil];
  return NSInsetRect(border, 2, 2);
}

- (NSRect)drawGroove:(NSRect)border withClip:(NSRect)clip
{
  [self drawGrooveInRect: border flipped: [[NSView focusView] isFlipped]];
  return NSInsetRect(border, 2, 2);
}

- (NSRect)drawFramePhoto:(NSRect)border withClip:(NSRect)clip
{
  [self drawWellInRect: border flipped: [[NSView focusView] isFlipped] fill: nil];
  return NSInsetRect(border, 2, 2);
}

#pragma mark - Boxes

- (BOOL)isBoxOpaque:(NSBox *)box
{
  return [box boxType] != NSBoxSeparator;
}

/* Group boxes are framed with Platinum's embossed groove. */
- (void)drawBoxInClipRect:(NSRect)clipRect
                  boxType:(NSBoxType)boxType
               borderType:(NSBorderType)borderType
                   inView:(NSBox *)box
{
  NSView *view = (NSView *)box;

  if (borderType == NSNoBorder)
    {
      [super drawBoxInClipRect: clipRect boxType: boxType
                   borderType: borderType inView: box];
      return;
    }
  if (boxType == NSBoxSeparator)
    {
      NSRect line = [view bounds];

      if (NSWidth(line) > NSHeight(line))
        line.size.height = 2;
      else
        line.size.width = 2;
      [self drawGrooveInRect: line flipped: [view isFlipped]];
      return;
    }
  [self drawGrooveInRect: [view bounds] flipped: [view isFlipped]];

  // The groove replaces the default border drawing, so the box title has to
  // be drawn here as well.
  if ([box titlePosition] != NSNoTitle)
    {
      NSRect title = [box titleRect];

      [[self menuBackgroundColor] set];
      NSRectFill(title);
      [[box titleCell] drawWithFrame: title inView: view];
    }
}

#pragma mark - Scroll bars

- (float)defaultScrollerWidth
{
  return GeorgeScrollerWidth;
}

/* Platinum puts one arrow at each end of the bar. */
- (BOOL)scrollerArrowsSameEndForScroller:(NSScroller *)scroller
{
  return NO;
}

- (BOOL)scrollViewUseBottomCorner
{
  return YES;
}


- (NSButtonCell *)cellForScrollerArrow:(NSScrollerArrow)arrow
                            horizontal:(BOOL)horizontal
{
  GeorgeScrollerArrowCell *cell = [[GeorgeScrollerArrowCell alloc] init];
  NSString *name;

  if (horizontal)
    {
      if (arrow == NSScrollerDecrementArrow)
        {
          [cell setDirection: 2];
          name = GSScrollerLeftArrow;
        }
      else
        {
          [cell setDirection: 3];
          name = GSScrollerRightArrow;
        }
    }
  else
    {
      if (arrow == NSScrollerDecrementArrow)
        {
          [cell setDirection: 0];
          name = GSScrollerUpArrow;
        }
      else
        {
          [cell setDirection: 1];
          name = GSScrollerDownArrow;
        }
    }
  [cell setImagePosition: NSImageOnly];
  // Naming the cell hands it to the theme, which keeps it alive for as long
  // as the theme is active.
  [self setName: name forElement: cell temporary: YES];
  RELEASE(cell);
  return cell;
}

- (NSCell *)cellForScrollerKnob:(BOOL)horizontal
{
  GeorgeScrollerKnobCell *cell = [[GeorgeScrollerKnobCell alloc] init];

  [cell setHorizontal: horizontal];
  [cell setImagePosition: NSImageOnly];
  [self setName: (horizontal ? GSScrollerHorizontalKnob : GSScrollerVerticalKnob)
     forElement: cell
      temporary: YES];
  RELEASE(cell);
  return cell;
}

- (NSCell *)cellForScrollerKnobSlot:(BOOL)horizontal
{
  GeorgeScrollerSlotCell *cell = [[GeorgeScrollerSlotCell alloc] init];

  [cell setHorizontal: horizontal];
  [cell setBordered: NO];
  [cell setTitle: nil];
  [self setName: (horizontal ? GSScrollerHorizontalSlot : GSScrollerVerticalSlot)
     forElement: cell
      temporary: YES];
  RELEASE(cell);
  return cell;
}

#pragma mark - Steppers

- (void)drawStepperCell:(NSCell *)cell
              withFrame:(NSRect)cellFrame
                 inView:(NSView *)controlView
            highlightUp:(BOOL)highlightUp
          highlightDown:(BOOL)highlightDown
{
  NSRect up = [self stepperUpButtonRectWithFrame: cellFrame];
  NSRect down = [self stepperDownButtonRectWithFrame: cellFrame];
  BOOL flipped = [controlView isFlipped];
  BOOL enabled = [cell isEnabled];

  [self drawScrollArrowInRect: up flipped: flipped direction: 0
                      pressed: highlightUp enabled: enabled];
  [self drawScrollArrowInRect: down flipped: flipped direction: 1
                      pressed: highlightDown enabled: enabled];
}

#pragma mark - Sliders

- (void)drawSliderBorderAndBackground:(NSBorderType)aType
                                frame:(NSRect)cellFrame
                               inCell:(NSCell *)cell
                         isHorizontal:(BOOL)horizontal
{
  NSView *view = [cell controlView];
  NSRect track = cellFrame;

  if ([(NSSliderCell *)cell sliderType] != NSLinearSlider)
    {
      [super drawSliderBorderAndBackground: aType frame: cellFrame
                                   inCell: cell isHorizontal: horizontal];
      return;
    }
  // The track is a thin sunken groove down the middle of the cell, which the
  // knob then rides over.
  if (horizontal)
    {
      track.origin.y = round(NSMidY(cellFrame) - GeorgeSliderTrackThickness / 2.0);
      track.size.height = GeorgeSliderTrackThickness;
    }
  else
    {
      track.origin.x = round(NSMidX(cellFrame) - GeorgeSliderTrackThickness / 2.0);
      track.size.width = GeorgeSliderTrackThickness;
    }
  [self drawWellInRect: track flipped: [view isFlipped] fill: GeorgeGray(0xCC)];
}

- (void)drawBarInside:(NSRect)rect inCell:(NSCell *)cell flipped:(BOOL)flipped
{
  // The track is drawn by -drawSliderBorderAndBackground:..., so there is
  // nothing left to fill in here.
}

- (void)drawKnobInCell:(NSCell *)cell
{
  NSSliderCell *slider = (NSSliderCell *)cell;
  NSView *view = [cell controlView];
  BOOL flipped = [view isFlipped];

  if ([slider sliderType] != NSLinearSlider)
    {
      [super drawKnobInCell: cell];
      return;
    }
  [self drawSliderKnobInRect: [slider knobRectFlipped: flipped]
                     flipped: flipped
                     pressed: [slider isHighlighted]];
}

#pragma mark - Segmented control, color well, popup

- (void)drawSegmentedControlSegment:(NSCell *)cell
                          withFrame:(NSRect)cellFrame
                             inView:(NSView *)controlView
                              style:(NSSegmentStyle)style
                              state:(GSThemeControlState)state
                        roundedLeft:(BOOL)roundedLeft
                       roundedRight:(BOOL)roundedRight
{
  [self drawBevelButtonInRect: cellFrame
                     flipped: [controlView isFlipped]
                     pressed: GeorgeStateIsPressed(state)
                     enabled: (state != GSThemeDisabledState)];
}

- (NSRect)drawColorWellBorder:(NSColorWell *)well
                   withBounds:(NSRect)bounds
                     withClip:(NSRect)clipRect
{
  BOOL flipped = [well isFlipped];
  NSRect inside;

  if (![well isBordered])
    return bounds;
  [self drawBevelButtonInRect: bounds
                     flipped: flipped
                     pressed: ([[well cell] isHighlighted] || [well isActive])
                     enabled: [well isEnabled]];
  // The color sits in a sunken well inside the button, the way Platinum
  // shows a swatch.
  inside = NSInsetRect(bounds, 4, 4);
  [self drawWellInRect: inside flipped: flipped fill: nil];
  return NSInsetRect(inside, 2, 2);
}

- (void)drawPopUpButtonCellInteriorWithFrame:(NSRect)cellFrame
                                    withCell:(NSCell *)cell
                                      inView:(NSView *)controlView
{
  // The arrow is the registered common_3DArrowDown image, which NSPopUpButton
  // draws itself; nothing is added on top of the bevel here.
}

#pragma mark - Progress indicators

- (void)drawProgressIndicator:(NSProgressIndicator *)progress
                   withBounds:(NSRect)bounds
                     withClip:(NSRect)rect
                      atCount:(int)count
                     forValue:(double)val
{
  BOOL flipped = [progress isFlipped];
  NSRect r = NSIntegralRect(bounds);

  // Platinum has no spinner, so a spinning indicator gets the barber pole in
  // the square it was given.
  if ([progress style] == NSProgressIndicatorSpinningStyle)
    {
      [self drawWellInRect: r flipped: flipped fill: nil];
      [self drawBarberPoleInRect: NSInsetRect(r, 2, 2) flipped: flipped
                          phase: count];
      return;
    }

  [self drawWellInRect: r flipped: flipped fill: GeorgeGray(0xCC)];
  r = NSInsetRect(r, 2, 2);
  if (NSIsEmptyRect(r))
    return;
  if ([progress isIndeterminate])
    {
      [self drawBarberPoleInRect: r flipped: flipped phase: count];
      return;
    }
  if ([progress isVertical])
    {
      CGFloat height = round(NSHeight(r) * val);

      if (flipped)
        r.origin.y += NSHeight(r) - height;
      r.size.height = height;
    }
  else
    {
      r.size.width = round(NSWidth(r) * val);
    }
  if (NSIsEmptyRect(r))
    return;
  // The filled part is the scheme color, lit along its top left edges.
  GeorgeFill(r, flipped, 1, 0, 0, NSWidth(r), NSHeight(r), GeorgeSchemeColor(4));
  GeorgeFill(r, flipped, 1, 0, 0, NSWidth(r), 1, GeorgeSchemeColor(5));
  GeorgeFill(r, flipped, 1, 0, 0, 1, NSHeight(r), GeorgeSchemeColor(5));
}

#pragma mark - Tables and browsers

- (void)drawTableHeaderCell:(NSTableHeaderCell *)cell
                  withFrame:(NSRect)cellFrame
                     inView:(NSView *)controlView
                      state:(GSThemeControlState)state
{
  [self drawRaisedPanelInRect: cellFrame
                     flipped: [controlView isFlipped]
                     pressed: GeorgeStateIsPressed(state)];
}

- (void)drawTableCornerView:(NSView *)cornerView withClip:(NSRect)aRect
{
  [self drawRaisedPanelInRect: [cornerView bounds]
                     flipped: [cornerView isFlipped]
                     pressed: NO];
}

- (NSColor *)tableHeaderTextColorForState:(GSThemeControlState)state
{
  return GeorgeGray(state == GSThemeDisabledState ? 0x88 : 0x00);
}

- (void)drawBrowserHeaderCell:(NSTableHeaderCell *)cell
                    withFrame:(NSRect)rect
                       inView:(NSView *)view
{
  [self drawRaisedPanelInRect: rect flipped: [view isFlipped] pressed: NO];
  [cell drawInteriorWithFrame: rect inView: view];
}

- (NSColor *)browserHeaderTextColor
{
  return GeorgeGray(0x00);
}

#pragma mark - Toolbars

- (NSColor *)toolbarBackgroundColor
{
  return GeorgeGray(0xDD);
}

- (NSColor *)toolbarBorderColor
{
  return GeorgeGray(0x88);
}

- (BOOL)toolbarIsOpaque
{
  return YES;
}

#pragma mark - Switches

- (void)drawSwitchInRect:(NSRect)rect
                forState:(NSControlStateValue)state
                 enabled:(BOOL)enabled
{
  // Platinum has no switch; it has the checkbox, which is what the
  // registered common_Switch images draw.
  NSImage *image = [NSImage imageNamed: (state == NSControlStateValueOff
                                        ? @"common_SwitchOff" : @"common_SwitchOn")];

  [image drawInRect: rect
           fromRect: NSZeroRect
          operation: NSCompositeSourceOver
           fraction: (enabled ? 1.0 : 0.5)];
}

#pragma mark - Tab views

- (CGFloat)tabHeightForType:(NSTabViewType)type
{
  if (type == NSTopTabsBezelBorder || type == NSBottomTabsBezelBorder)
    return 22.0;
  return [super tabHeightForType: type];
}

#pragma mark - Window decorations

- (float)titlebarHeight
{
  return METRICS_TITLEBAR_HEIGHT;
}

/* Platinum title bars are square. */
- (CGFloat)titlebarCornerRadius
{
  return 0.0;
}

/* The resize bar of a window GNUstep decorates itself: a raised strip with
 * the grow box at its right end, which is where Platinum puts it. */
- (void)drawResizeBarRect:(NSRect)resizeBarRect
{
  CGFloat height = [self resizebarHeight];
  CGFloat notch = [self resizebarNotchWidth];
  // The bar is drawn with its own origin at zero, the way the default
  // implementation does.
  NSRect bar = NSMakeRect(0, 0, NSWidth(resizeBarRect), height);

  [self drawRaisedPanelInRect: bar flipped: NO pressed: NO];
  if (NSWidth(bar) < notch * 2)
    return;
  [self drawGrowBoxInRect: NSMakeRect(NSMaxX(bar) - notch, 0, notch, height)
                  flipped: NO];
}

- (void)drawWindowBorder:(NSRect)rect
               withFrame:(NSRect)frame
            forStyleMask:(unsigned int)styleMask
                   state:(int)inputState
                andTitle:(NSString *)title
{
  NSRect titlebar = NSMakeRect(0, NSHeight(frame) - [self titlebarHeight],
                               NSWidth(frame), [self titlebarHeight]);

  if ((styleMask & NSTitledWindowMask) == 0)
    return;
  [self drawTitlebarInRect: titlebar
                styleMask: styleMask
                   active: (inputState != 0)
                    title: title];
}

@end

@implementation George (WindowManager)

- (BOOL)drawsTitlebarButtons
{
  return YES;
}

- (NSRect)titlebarButtonRectForButton:(NSInteger)button
                        titlebarWidth:(CGFloat)width
                            styleMask:(NSUInteger)styleMask
{
  static const NSUInteger requiredMask[] = {
    [GeorgeWidgetClose] = NSClosableWindowMask,
    [GeorgeWidgetCollapse] = NSMiniaturizableWindowMask,
    [GeorgeWidgetZoom] = NSResizableWindowMask
  };

  if (button < GeorgeWidgetClose || button > GeorgeWidgetZoom)
    return NSZeroRect;
  if (!(styleMask & requiredMask[button]))
    return NSZeroRect;
  return [self widgetRectForButton: (GeorgeWidget)button
                    titlebarWidth: width
                        styleMask: styleMask];
}

- (void)drawtitleRect:(NSRect)rect
         forStyleMask:(unsigned int)styleMask
                state:(int)inputState
             andTitle:(NSString *)title
{
  // The window manager passes 0 for the key window and 1 or 2 for a window
  // that is only main or neither.
  [self drawTitlebarInRect: rect
                styleMask: styleMask
                   active: (inputState == 0)
                    title: title];
}

- (void)drawCloseButtonInRect:(NSRect)rect
                        state:(GSThemeControlState)state
                       active:(BOOL)active
{
  [self drawWidget: GeorgeWidgetClose inSlot: rect
            active: active hovered: (state != GSThemeNormalState)];
}

- (void)drawMinimizeButtonInRect:(NSRect)rect
                           state:(GSThemeControlState)state
                          active:(BOOL)active
{
  [self drawWidget: GeorgeWidgetCollapse inSlot: rect
            active: active hovered: (state != GSThemeNormalState)];
}

- (void)drawMaximizeButtonInRect:(NSRect)rect
                           state:(GSThemeControlState)state
                          active:(BOOL)active
{
  [self drawWidget: GeorgeWidgetZoom inSlot: rect
            active: active hovered: (state != GSThemeNormalState)];
}

@end
