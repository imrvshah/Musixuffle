//
//  HeartRateInterfaceController.m
//  Musixuffle WatchKit App
//
//  Created by Ravi Shah on 7/24/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

#import "HeartRateInterfaceController.h"

@interface HeartRateInterfaceController ()

@end

@implementation HeartRateInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateHeartRate:)
                                                 name:@"heartRate"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateWalkingDistance:)
                                                 name:@"walkingDistance"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateSteps:)
                                                 name:@"steps"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateCalories:)
                                                 name:@"calories"
                                               object:nil];
    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateHeartRate:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.labelHeartRate.text = [NSString stringWithFormat:@"%d BPM", [[notification.object valueForKey:@"heartRate"] integerValue] ];
    });
}
- (void)updateWalkingDistance:(NSNotification *)notification
{
    self.distance += [[notification.object valueForKey:@"walkingDistance"] floatValue];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.labelDistance.text = [NSString stringWithFormat:@"%.2f m", self.distance ];
    });
}
- (void)updateSteps:(NSNotification *)notification
{
    self.steps += [[notification.object valueForKey:@"steps"] integerValue] ;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.labelSteps.text = [NSString stringWithFormat:@"%d steps", self.steps ];
    });
}
- (void)updateCalories:(NSNotification *)notification
{
    self.calories += [[notification.object valueForKey:@"calories"] floatValue];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.labelCalories.text = [NSString stringWithFormat:@"%.2f kcal", self.calories];
    });
}

@end



