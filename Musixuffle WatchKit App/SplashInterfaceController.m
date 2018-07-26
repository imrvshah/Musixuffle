//
//  SplashInterfaceController.m
//  Musixuffle WatchKit Extension
//
//  Created by Ravi Shah on 7/25/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

#import "SplashInterfaceController.h"

@interface SplashInterfaceController ()

@end

@implementation SplashInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    [self performSelector:@selector(buttonTapped) withObject:nil afterDelay:30];
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
- (IBAction)buttonTapped {
    [self pushControllerWithName:@"heartBeat" context:nil];
}

@end



