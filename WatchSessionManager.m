//
//  WatchSessionManager.m
//  Musixuffle
//
//  Created by Ravi Shah on 7/24/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

#import "WatchSessionManager.h"

@implementation WatchSessionManager


+ (instancetype)sharedInstance
{
    static WatchSessionManager *sessionManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sessionManager = [[WatchSessionManager alloc] init];
    });
    return sessionManager;
}

-(void)startSession
{
    self.session = [WCSession defaultSession];
    self.session.delegate = self;
    [self.session activateSession];    
}

-(void)fire
{
    NSError *error = nil;
    // Send heart rate to iPhone
    if(![self.session updateApplicationContext:
         @{@"disLike" : [NSNumber numberWithInt:1] }
                                    error:&error])
    {
        NSLog(@"Updating the context failed : %@", error.localizedDescription);
    }
}



@end
