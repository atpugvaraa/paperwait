//
//  CanvasBackgroundView.m
//  Sender
//
//  Created by Aarav Gupta on 26/01/26.
//

#import "CanvasBackgroundView.h"

@implementation CanvasBackgroundView

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor blackColor] setFill];
    CGContextFillRect(context, rect);
    
    [[UIColor colorWithWhite:0.3 alpha:1.0] setFill];
    
    CGFloat spacing = 40.0;
    CGFloat size = 2.0;
    
    for (CGFloat x = 0; x < rect.size.width; x += spacing) {
        for (CGFloat y = 0; y < rect.size.height; y += spacing) {
            CGContextFillEllipseInRect(context, CGRectMake(x, y, size, size));
        }
    }
}

@end
