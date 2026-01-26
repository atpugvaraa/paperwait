//
//  main.m
//  Receiver
//
//  Created by Aarav Gupta on 26/01/26.
//

#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        NSApplication *application = [NSApplication sharedApplication];
        AppDelegate *delegate = [[AppDelegate alloc] init];
        
        [application setDelegate:delegate];
        [application run];
    }
    
    return 0;
}
