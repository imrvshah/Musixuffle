//
//  HeartRateInterfaceController.h
//  Musixuffle WatchKit App
//
//  Created by Ravi Shah on 7/24/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface HeartRateInterfaceController : WKInterfaceController
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *labelCalories;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *labelSteps;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *labelHeartRate;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *labelDistance;
@property (nonatomic) float calories;
@property (nonatomic) NSInteger steps;
@property (nonatomic) NSInteger heartRate;
@property (nonatomic) float distance;

@end
