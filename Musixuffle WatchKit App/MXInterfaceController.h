//
//  MXInterfaceController.h
//  Musixuffle WatchKit App
//
//  Created by Ravi Shah on 7/23/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

#import "MXInterfaceController.h"
#import <HealthKit/HealthKit.h>
#import <WatchConnectivity/WatchConnectivity.h>
#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface MXInterfaceController : WKInterfaceController
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *lableHeartRate;
- (IBAction)quickStartClicked;
- (IBAction)startClicked;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *lblDummy;
@property(nonatomic, strong) HKHealthStore *healthStore;

@end
