//
//  WatchSessionManager.h
//  Musixuffle
//
//  Created by Ravi Shah on 7/24/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WatchConnectivity/WatchConnectivity.h>
@interface WatchSessionManager : NSObject
@property(nonatomic, strong) WCSession *session;
-(void)startSession;
-(void)fire;
+ (instancetype)sharedInstance;
@end
