//
//  ConnectionManager.h
//  Receiver
//
//  Created by Aarav Gupta on 26/01/26.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, PacketType) {
    PacketTypeDraw = 0,
    PacketTypeCursor = 1,
    PacketTypeScroll = 2
};

@protocol ConnectionManagerDelegate <NSObject>
- (void)didReceivePacket:(PacketType)type x:(CGFloat)x y:(CGFloat)y state:(NSInteger)state;
@end

@interface ConnectionManager : NSObject <MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate>

@property (nonatomic, weak) id<ConnectionManagerDelegate> delegate;
@property (nonatomic, strong, readonly) MCSession *session;

- (void)startHosting; // for mac
- (void)startBrowsing; // for ipad
- (void)sendPacket:(PacketType)type x:(CGFloat)x y:(CGFloat)y state:(NSInteger)state;

@end

NS_ASSUME_NONNULL_END
