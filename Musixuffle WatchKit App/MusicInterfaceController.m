//
//  MusicInterfaceController.m
//  Musixuffle WatchKit App
//
//  Created by Ravi Shah on 7/24/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

#import "MusicInterfaceController.h"
#import <WatchConnectivity/WatchConnectivity.h>

@interface MusicInterfaceController ()

@end

@implementation MusicInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    if ([WCSession isSupported]) {
        WCSession *session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
        NSLog(@"WCSession is supported");
    }
    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (IBAction)buttonLikeClicked {
    WCSession *session = [WCSession defaultSession];
    NSError *error = nil;
    // Send heart rate to iPhone
    if(![session updateApplicationContext:
         @{@"like" : [NSNumber numberWithInt:1] }
                                    error:&error])
    {
        NSLog(@"Updating the context failed: %@", error.localizedDescription);
    }
    
}

- (IBAction)buttonDisLikeClicked {
    WCSession *session = [WCSession defaultSession];
    NSError *error = nil;
    // Send heart rate to iPhone
    if(![session updateApplicationContext:
         @{@"disLike" : [NSNumber numberWithInt:1] }
                                    error:&error])
    {
        NSLog(@"Updating the context failed: %@", error.localizedDescription);
    }
}

/** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
- (void)session:(WCSession *)session activationDidCompleteWithState:(WCSessionActivationState)activationState error:(nullable NSError *)error
{
    
}

@end



