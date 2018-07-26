//
//  BaseController.h
//  Musixuffle WatchKit App
//
//  Created by Daniel Wong on 7/25/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@import WatchKit;
@import HealthKit;

@interface BaseController : NSObject <HKWorkoutSessionDelegate>
+ (HKWorkoutSession *) startWorkout:(WKInterfaceController *)delegate;
@end

