//
//  ViewController.m
//  Receiver
//
//  Created by Aarav Gupta on 26/01/26.
//

#import "ViewController.h"
#import "ConnectionManager.h"

@interface ViewController () <ConnectionManagerDelegate>
@property (nonatomic, strong) ConnectionManager *connectionManager;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    self.connectionManager = [[ConnectionManager alloc] init];
    self.connectionManager.delegate = self; // listen for events
    
    [self.connectionManager startHosting];
    
    NSLog(@"[Mac] Started Hosting..");
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (void)didReceivePacket:(PacketType)type x:(CGFloat)x y:(CGFloat)y state:(NSInteger)state {
    CGEventRef event = NULL;
    
    if (type == PacketTypeDraw) {
        CGDirectDisplayID displayID = CGMainDisplayID();
        CGFloat screenWidth = CGDisplayPixelsWide(displayID);
        CGFloat screenHeight = CGDisplayPixelsHigh(displayID);
        CGPoint point = CGPointMake(x * screenWidth, y * screenHeight);
        
        CGEventType eventType = (state == 0) ? kCGEventLeftMouseDown : (state == 1 ? kCGEventLeftMouseDragged : kCGEventLeftMouseUp);
        event = CGEventCreateMouseEvent(NULL, eventType, point, kCGMouseButtonLeft);
    } else if (type == PacketTypeCursor) {
        CGEventRef current = CGEventCreate(NULL);
        CGPoint pos = CGEventGetLocation(current);
        CFRelease(current);
        
        CGPoint newPos = CGPointMake(pos.x + (x * 2.0), pos.y + (y * 2.0));
        event = CGEventCreateMouseEvent(NULL, kCGEventMouseMoved, newPos, kCGMouseButtonLeft);
    } else if (type == PacketTypeScroll) {
        event = CGEventCreateScrollWheelEvent(NULL, kCGScrollEventUnitPixel, 2, (int)(y * 3), (int)(x*3));
    }
    
    if (event) {
        CGEventPost(kCGHIDEventTap, event);
        CFRelease(event);
    }
}

@end
