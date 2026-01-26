//
//  AppDelegate.m
//  Receiver
//
//  Created by Aarav Gupta on 26/01/26.
//

#import "AppDelegate.h"
#import <CoreGraphics/CoreGraphics.h>
#import "ConnectionManager.h"

@interface AppDelegate ()
@property (nonatomic, strong) NSStatusItem *statusItem;
@property (nonatomic, strong) ConnectionManager *manager;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    self.manager = [[ConnectionManager alloc] init];
    self.manager.delegate = self;
    [self.manager startHosting];
    
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    self.statusItem.button.image = [NSImage imageWithSystemSymbolName:@"ipad.and.arrow.forward" accessibilityDescription:@"paperwait"];
    
    NSMenu *menu = [[NSMenu alloc] init];
    [menu addItemWithTitle:@"Active" action:nil keyEquivalent:@""];
    [menu addItem:[NSMenuItem separatorItem]];
    [menu addItemWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@"q"];
    self.statusItem.menu = menu;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)didReceivePacket:(PacketType)type x:(CGFloat)x y:(CGFloat)y state:(NSInteger)state {
    CGEventRef event = NULL;
    
    if (type == PacketTypeDraw) {
        CGDirectDisplayID displayID = CGMainDisplayID();
        CGFloat screenWidth = CGDisplayPixelsWide(displayID);
        CGFloat screenHeight = CGDisplayPixelsHigh(displayID);
        CGPoint point = CGPointMake(x * screenWidth, y * screenHeight);
        
        CGEventType eventType;
        if (state == 0) eventType = kCGEventLeftMouseDown;
        else if (state == 1) eventType = kCGEventLeftMouseDragged;
        else eventType = kCGEventLeftMouseUp;
        
        event = CGEventCreateMouseEvent(NULL, eventType, point, kCGMouseButtonLeft);
    } else if (type == PacketTypeCursor) {
        CGEventRef current = CGEventCreate(NULL);
        CGPoint pos = CGEventGetLocation(current);
        CFRelease(current);
        
        CGEventType eventType = kCGEventMouseMoved;
        CGPoint newPos = pos;
        
        if (state == 1) {
            newPos = CGPointMake(pos.x + (x * 3.0), pos.y + (y * 3.0));
            eventType = kCGEventMouseMoved;
        } else if (state == 0) {
            eventType = kCGEventLeftMouseDown;
        } else if (state == 2) {
            eventType = kCGEventLeftMouseUp;
        }
        
        event = CGEventCreateMouseEvent(NULL, eventType, newPos, kCGMouseButtonLeft);
    } else if (type == PacketTypeScroll) {
        event = CGEventCreateScrollWheelEvent(NULL, kCGScrollEventUnitPixel, 2, (int)(y * 3), (int)(x*3));
    }
    
    if (event) {
        CGEventPost(kCGHIDEventTap, event);
        CFRelease(event);
    }
}

- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}

@end
