//
//  MXInterfaceController.m
//  Musixuffle WatchKit App
//
//  Created by Ravi Shah on 7/23/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

#import "MXInterfaceController.h"
#import <HealthKit/HealthKit.h>
#import <WatchConnectivity/WatchConnectivity.h>


@interface MXInterfaceController () <HKWorkoutSessionDelegate, WCSessionDelegate>
@property(nonatomic, strong)HKHealthStore *healthStore;
@end

@implementation MXInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    self.healthStore = [[HKHealthStore alloc] init];
    if ([WCSession isSupported]) {
        WCSession *session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
        NSLog(@"WCSession is supported");
    }
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (IBAction)quickStartClicked
{
    [self takePermission];
    [self fakeWorkout];
    [self updateHeartbeat:[NSDate date]];
}
- (IBAction)startClicked
{
    [self takePermission];
   
}


- (IBAction)buttonHeartBeatClicked
{
   
//    [self fakeWorkout];
    // TODO: Prevent this if already authorized
}

- (void)takePermission
{
    if (HKHealthStore.isHealthDataAvailable)
    {
        HKQuantityType *type = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
        HKQuantityType *type2 = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
        HKQuantityType *type3 = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
         HKQuantityType *type5 = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
        
        HKObjectType *type4 = [HKObjectType workoutType];
        
        [ self.healthStore requestAuthorizationToShareTypes:[NSSet setWithObjects:type4, type, type2, type3, type5, nil] readTypes:[NSSet setWithObjects:type4, type, type2, type3, type5, nil] completion:^(BOOL success, NSError * _Nullable error) {
            
            if (success) {
                NSLog(@"health data request success");
               
                [self fakeWorkout];
//                [[self class] reloadRootControllersWithNames:@[@"MusicInterfaceController",@"HeartRateInterfaceController", @"EndWorkOutInterfaceController"] contexts:nil];
            }else{
                NSLog(@"error %@", error);
            }
        }];
    }
    else
    {
        NSLog(@"Health Data is not available");
    }
}

-(void)workoutSession:(HKWorkoutSession *)workoutSession didFailWithError:(NSError *)error{
    
    NSLog(@"session error %@", error);
}

- (void)workoutSession:(HKWorkoutSession *)workoutSession
      didChangeToState:(HKWorkoutSessionState)toState
             fromState:(HKWorkoutSessionState)fromState
                  date:(NSDate *)date
{
    self.lableHeartRate.text = @"Delegate";
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (toState) {
            case HKWorkoutSessionStateRunning:
                
                //When workout state is running, we will excute updateHeartbeat
                [self updateHeartbeat:date];
                NSLog(@"started workout");
                break;
                
            default:
                break;
        }
    });
}

- (void)workoutSession:(HKWorkoutSession *)workoutSession
      didGenerateEvent:(HKWorkoutEvent *)event
{
    
}

-(void)updateHeartbeat:(NSDate *)startDate
{
    self.lableHeartRate.text = @"updateHeartbeat";
    //first, create a predicate and set the endDate and option to nil/none
    NSPredicate *Predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:nil options:HKQueryOptionNone];
    
    //Then we create a sample type which is HKQuantityTypeIdentifierHeartRate
    HKSampleType *object = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    
//    HKSampleType *walkingDistance = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
//
//    HKSampleType *steps = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
//
//    //Then we create a sample type which is HKQuantityTypeIdentifierHeartRate
//    HKSampleType *calories = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
//
    
    //ok, now, create a HKAnchoredObjectQuery with all the mess that we just created.
    HKAnchoredObjectQuery *heartQuery = [[HKAnchoredObjectQuery alloc] initWithType:object predicate:Predicate anchor:0 limit:0 resultsHandler:^(HKAnchoredObjectQuery *query, NSArray<HKSample *> *sampleObjects, NSArray<HKDeletedObject *> *deletedObjects, HKQueryAnchor *newAnchor, NSError *error) {
        
        if (!error && sampleObjects.count > 0) {
            HKQuantitySample *sample = (HKQuantitySample *)[sampleObjects objectAtIndex:0];
            HKQuantity *quantity = sample.quantity;
            NSLog(@"%f", [quantity doubleValueForUnit:[HKUnit unitFromString:@"count/min"]]);
        }else{
            NSLog(@"query %@", error);
        }
        
    }];
    
//    HKAnchoredObjectQuery *walkingDistanceQuery = [[HKAnchoredObjectQuery alloc] initWithType:walkingDistance predicate:Predicate anchor:0 limit:0 resultsHandler:^(HKAnchoredObjectQuery *query, NSArray<HKSample *> *sampleObjects, NSArray<HKDeletedObject *> *deletedObjects, HKQueryAnchor *newAnchor, NSError *error) {
//
//        if (!error && sampleObjects.count > 0) {
//            HKQuantitySample *sample = (HKQuantitySample *)[sampleObjects objectAtIndex:0];
//            HKQuantity *quantity = sample.quantity;
//            NSLog(@"%f", [quantity doubleValueForUnit:[HKUnit unitFromString:@"m"]]);
//        }else{
//            NSLog(@"query %@", error);
//        }
//
//    }];
//
//    HKAnchoredObjectQuery *stepsQuery = [[HKAnchoredObjectQuery alloc] initWithType:steps predicate:Predicate anchor:0 limit:0 resultsHandler:^(HKAnchoredObjectQuery *query, NSArray<HKSample *> *sampleObjects, NSArray<HKDeletedObject *> *deletedObjects, HKQueryAnchor *newAnchor, NSError *error) {
//
//        if (!error && sampleObjects.count > 0) {
//            HKQuantitySample *sample = (HKQuantitySample *)[sampleObjects objectAtIndex:0];
//            HKQuantity *quantity = sample.quantity;
//            NSLog(@"%f", [quantity doubleValueForUnit:[HKUnit unitFromString:@"count/min"]]);
//        }else{
//            NSLog(@"query %@", error);
//        }
//
//    }];
//
//    HKAnchoredObjectQuery *caloriesQuery = [[HKAnchoredObjectQuery alloc] initWithType:calories predicate:Predicate anchor:0 limit:0 resultsHandler:^(HKAnchoredObjectQuery *query, NSArray<HKSample *> *sampleObjects, NSArray<HKDeletedObject *> *deletedObjects, HKQueryAnchor *newAnchor, NSError *error) {
//
//        if (!error && sampleObjects.count > 0) {
//            HKQuantitySample *sample = (HKQuantitySample *)[sampleObjects objectAtIndex:0];
//            HKQuantity *quantity = sample.quantity;
//            NSLog(@"%f", [quantity doubleValueForUnit:[HKUnit unitFromString:@"count/min"]]);
//        }else{
//            NSLog(@"query %@", error);
//        }
//
//    }];
    
    
    //wait, it's not over yet, this is the update handler
    [heartQuery setUpdateHandler:^(HKAnchoredObjectQuery *query, NSArray<HKSample *> *SampleArray, NSArray<HKDeletedObject *> *deletedObjects, HKQueryAnchor *Anchor, NSError *error) {
        
        if (!error && SampleArray.count > 0) {
            HKQuantitySample *sample = (HKQuantitySample *)[SampleArray objectAtIndex:0];
            HKQuantity *quantity = sample.quantity;
            NSLog(@"%f", [quantity doubleValueForUnit:[HKUnit unitFromString:@"count/min"]]);
            WCSession *session = [WCSession defaultSession];
            
            // Send heart rate to iPhone
            if(![session updateApplicationContext:
                 @{@"heartRate" : [NSNumber numberWithFloat:[quantity doubleValueForUnit:[HKUnit unitFromString:@"count/min"]]] }
                 error:&error])
            {
                NSLog(@"Updating the context failed: %@", error.localizedDescription);
            }
        }else{
            NSLog(@"query %@", error);
        }
    }];
    
//    //wait, it's not over yet, this is the update handler
//    [walkingDistanceQuery setUpdateHandler:^(HKAnchoredObjectQuery *query, NSArray<HKSample *> *SampleArray, NSArray<HKDeletedObject *> *deletedObjects, HKQueryAnchor *Anchor, NSError *error) {
//
//        if (!error && SampleArray.count > 0) {
//            HKQuantitySample *sample = (HKQuantitySample *)[SampleArray objectAtIndex:0];
//            HKQuantity *quantity = sample.quantity;
//            NSLog(@"%f", [quantity doubleValueForUnit:[HKUnit unitFromString:@"count/min"]]);
//            WCSession *session = [WCSession defaultSession];
//
//            // Send heart rate to iPhone
//            if(![session updateApplicationContext:
//                 @{@"heartRate" : [NSNumber numberWithFloat:[quantity doubleValueForUnit:[HKUnit unitFromString:@"count/min"]]] }
//                                            error:&error])
//            {
//                NSLog(@"Updating the context failed: %@", error.localizedDescription);
//            }
//        }else{
//            NSLog(@"query %@", error);
//        }
//    }];
//
//    //wait, it's not over yet, this is the update handler
//    [stepsQuery setUpdateHandler:^(HKAnchoredObjectQuery *query, NSArray<HKSample *> *SampleArray, NSArray<HKDeletedObject *> *deletedObjects, HKQueryAnchor *Anchor, NSError *error) {
//
//        if (!error && SampleArray.count > 0) {
//            HKQuantitySample *sample = (HKQuantitySample *)[SampleArray objectAtIndex:0];
//            HKQuantity *quantity = sample.quantity;
//            NSLog(@"%f", [quantity doubleValueForUnit:[HKUnit unitFromString:@"count/min"]]);
//            WCSession *session = [WCSession defaultSession];
//
//            // Send heart rate to iPhone
//            if(![session updateApplicationContext:
//                 @{@"heartRate" : [NSNumber numberWithFloat:[quantity doubleValueForUnit:[HKUnit unitFromString:@"count/min"]]] }
//                                            error:&error])
//            {
//                NSLog(@"Updating the context failed: %@", error.localizedDescription);
//            }
//        }else{
//            NSLog(@"query %@", error);
//        }
//    }];
//
//    //wait, it's not over yet, this is the update handler
//    [caloriesQuery setUpdateHandler:^(HKAnchoredObjectQuery *query, NSArray<HKSample *> *SampleArray, NSArray<HKDeletedObject *> *deletedObjects, HKQueryAnchor *Anchor, NSError *error) {
//
//        if (!error && SampleArray.count > 0) {
//            HKQuantitySample *sample = (HKQuantitySample *)[SampleArray objectAtIndex:0];
//            HKQuantity *quantity = sample.quantity;
//            NSLog(@"%f", [quantity doubleValueForUnit:[HKUnit unitFromString:@"count/min"]]);
//            WCSession *session = [WCSession defaultSession];
//
//            // Send heart rate to iPhone
//            if(![session updateApplicationContext:
//                 @{@"heartRate" : [NSNumber numberWithFloat:[quantity doubleValueForUnit:[HKUnit unitFromString:@"count/min"]]] }
//                                            error:&error])
//            {
//                NSLog(@"Updating the context failed: %@", error.localizedDescription);
//            }
//        }else{
//            NSLog(@"query %@", error);
//        }
//    }];
    
    //now excute query and wait for the result showing up in the log. Yeah!
    [self.healthStore executeQuery:heartQuery];
//    [self.healthStore executeQuery:walkingDistanceQuery];
//    [self.healthStore executeQuery:stepsQuery];
//    [self.healthStore executeQuery:caloriesQuery];
}

- (void)fakeWorkout
{
    self.lableHeartRate.text = @"fakeWorkOut";
    HKWorkoutConfiguration *config = [[HKWorkoutConfiguration alloc]init];
    config.activityType = HKWorkoutActivityTypeRunning;
    config.locationType = HKWorkoutSessionLocationTypeOutdoor;
    
    NSError *error = nil;
    HKWorkoutSession *workoutSession = [[HKWorkoutSession alloc] initWithConfiguration:config error:&error];
    workoutSession.delegate = self;
    
    [self.healthStore startWorkoutSession:workoutSession];
//    [self.healthStore endWorkoutSession:workoutSession];
}

- (void)session:(WCSession *)session didReceiveApplicationContext:(NSDictionary<NSString *, id> *)applicationContext
{
    NSLog(@"%@", applicationContext);
    self.lableHeartRate.text = @"didReceiveApplicationContext";
}

/** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
- (void)session:(WCSession *)session activationDidCompleteWithState:(WCSessionActivationState)activationState error:(nullable NSError *)error
{
    
}

@end



