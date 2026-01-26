//
//  ViewController.m
//  Sender
//
//  Created by Aarav Gupta on 26/01/26.
//

#import "ViewController.h"
#import "ConnectionManager.h"
#import "CanvasBackgroundView.h"

@interface ViewController ()
@property (nonatomic, strong) ConnectionManager *connectionManager;
@property (nonatomic, assign) BOOL isTrackpadMode;
@property (nonatomic, strong) UISwitch *modeSwitch;
@property (nonatomic, strong) UIPanGestureRecognizer *scrollGesture;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CanvasBackgroundView *canvas = [[CanvasBackgroundView alloc] initWithFrame:self.view.bounds];
    canvas.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:canvas];
    [self.view sendSubviewToBack:canvas];
    
    self.modeSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(50, 50, 0, 0)];
    [self.modeSwitch addTarget:self action:@selector(toggleMode:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.modeSwitch];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(110, 50, 200, 31)];
    label.text = @"Drawing Mode";
    label.textColor = [UIColor whiteColor];
    [self.view addSubview:label];
    
    self.scrollGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleScroll:)];
    self.scrollGesture.minimumNumberOfTouches = 2;
    [self.view addGestureRecognizer:self.scrollGesture];
    
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    self.tapGesture.numberOfTouchesRequired = 2;
    [self.view addGestureRecognizer:self.tapGesture];
    
    self.connectionManager = [[ConnectionManager alloc] init];
    [self.connectionManager startBrowsing];
    
    NSLog(@"[iPad] Started browsing..");
}

- (void)toggleMode:(UISwitch *)sender {
    self.isTrackpadMode = sender.isOn;
}

- (void)handleScroll:(UIPanGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint vel = [gesture velocityInView:self.view];
        [self.connectionManager sendPacket:PacketTypeScroll x:vel.x * 0.05 y:vel.y * 0.05 state:0];
    }
}

- (void)handleTap:(UITapGestureRecognizer *)gesture {
    [self.connectionManager sendPacket:PacketTypeCursor x:0 y:0 state:0];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.connectionManager sendPacket:PacketTypeCursor x:0 y:0 state:2];
    });
}

- (void)handleTouch:(UITouch *)touch state:(NSInteger)state {
    if (self.scrollGesture.state == UIGestureRecognizerStateBegan || self.scrollGesture.state == UIGestureRecognizerStateChanged) { return; }
    
    if (!self.isTrackpadMode) {
        if (state == 1) {
            CGPoint prev = [touch previousLocationInView:self.view];
            CGPoint curr = [touch locationInView:self.view];
            CGSize screenSize = self.view.bounds.size;
            
            CGFloat delX = curr.x - prev.x;
            CGFloat delY = curr.y - prev.y;
            
            [self.connectionManager sendPacket:PacketTypeCursor x:delX y:delY state:1];
        }
    } else {
        CGPoint location = [touch locationInView:self.view];
        CGSize screenSize = self.view.bounds.size;
        
        CGFloat normalizedX = location.x / screenSize.width;
        CGFloat normalizedY = location.y / screenSize.height;
        
        [self.connectionManager sendPacket:PacketTypeDraw x:normalizedX y:normalizedY state:state];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self handleTouch:[touches anyObject] state:0]; // 0 = down
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self handleTouch:[touches anyObject] state:1]; // 1 = moved
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self handleTouch:[touches anyObject] state:2]; // 2 = up
}

@end
