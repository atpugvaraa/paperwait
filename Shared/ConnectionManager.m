//
//  ConnectionManager.m
//  Receiver
//
//  Created by Aarav Gupta on 26/01/26.
//

#import "ConnectionManager.h"

#define SERVICE_TYPE @"paperwait-wacom"

@implementation ConnectionManager {
    MCNearbyServiceAdvertiser *_advertiser;
    MCNearbyServiceBrowser *_browser;
    MCPeerID *_peerId;
}

- (instancetype)init {
    self = [super init];
    if (self) {
#if TARGET_OS_IOS
        _peerId = [[MCPeerID alloc] initWithDisplayName:[UIDevice currentDevice].name];
#else
        _peerId = [[MCPeerID alloc] initWithDisplayName:[NSHost currentHost].localizedName];
#endif
        
        _session = [[MCSession alloc] initWithPeer:_peerId securityIdentity:nil encryptionPreference:MCEncryptionNone];
        _session.delegate = self;
    }
    
    return self;
}

- (void)startHosting {
    _advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:_peerId discoveryInfo:nil serviceType:SERVICE_TYPE];
    _advertiser.delegate = self;
    [_advertiser startAdvertisingPeer];
    NSLog(@"[Network] Advertising..");
}

- (void)startBrowsing {
    _browser = [[MCNearbyServiceBrowser alloc] initWithPeer:_peerId serviceType:SERVICE_TYPE];
    _browser.delegate = self;
    [_browser startBrowsingForPeers];
    NSLog(@"[Network] Browsing..");
}

- (void)sendPacket:(PacketType)type x:(CGFloat)x y:(CGFloat)y state:(NSInteger)state {
    if (_session.connectedPeers.count == 0) return;
    
    // package CGPoints(x, y, state) as data (0 = begin, 1=moved, 2=ended)
    NSString *payload = [NSString stringWithFormat:@"%ld,%f,%f,%ld", (long)type, x, y, (long)state];
    NSData *data = [payload dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error;
    [_session sendData:data toPeers:_session.connectedPeers withMode:MCSessionSendDataUnreliable error:&error];
}

// found a peer? send invite
- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary<NSString *,NSString *> *)info {
    NSLog(@"[Network] Found peer: %@", peerID.displayName);
    [browser invitePeer:peerID toSession:_session withContext:nil timeout:10];
}

// received an invite? accept that shit
- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession * _Nullable))invitationHandler {
    NSLog(@"[Network] Accepting Invite from: %@", peerID.displayName);
    invitationHandler(YES, _session);
}

// received data? decode it and update delegate abt it
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    NSString *received = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSArray *components = [received componentsSeparatedByString:@","];
    
    if (components.count == 4) {
        NSInteger type = [components[0] integerValue];
        CGFloat x = [components[1] floatValue];
        CGFloat y = [components[2] floatValue];
        NSInteger state = [components[3] integerValue];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(didReceivePacket:x:y:state:)]) {
                [self.delegate didReceivePacket:(PacketType)type x:x y:y state:state];
            }
        });
    }
}

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    if (state == MCSessionStateConnected) {
        NSLog(@"Connected to: %@", peerID.displayName);
    } else if (state == MCSessionStateConnecting) {
        NSLog(@"Connecting to: %@", peerID.displayName);
    } else if (state == MCSessionStateNotConnected) {
        NSLog(@"Disconnected from: %@", peerID.displayName);
    }
}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID {}
- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress {}
- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error {}

@end
