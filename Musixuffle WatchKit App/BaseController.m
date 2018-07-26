//
//  BaseController.m
//  Musixuffle WatchKit App
//
//  Created by Daniel Wong on 7/25/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

#import "BaseController.h"

@implementation BaseController

+ (void) startWorkout:(id)delegate
{
    self.lableHeartRate.text = @"startWorkout";
    HKWorkoutConfiguration *config = [[HKWorkoutConfiguration alloc]init];
    config.activityType = HKWorkoutActivityTypeRunning;
    config.locationType = HKWorkoutSessionLocationTypeOutdoor;
    
    NSError *error = nil;
    HKWorkoutSession *workoutSession = [[HKWorkoutSession alloc] initWithConfiguration:config error:&error];
    workoutSession.delegate = delegate;
    
    [self.healthStore startWorkoutSession:workoutSession];
}

@end
