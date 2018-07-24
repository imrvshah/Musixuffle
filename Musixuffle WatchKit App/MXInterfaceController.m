//
//  MXInterfaceController.m
//  Musixuffle WatchKit App
//
//  Created by Ravi Shah on 7/23/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

#import "MXInterfaceController.h"
#import <HealthKit/HealthKit.h>

@interface MXInterfaceController () <HKWorkoutSessionDelegate >
@property (strong, nonatomic) IBOutlet WKInterfaceImage *imageViewTest;

@end

@implementation MXInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
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

- (IBAction)buttonHeartBeatClicked
{
    [self takePermission];

    
//    NSURL *url = [[NSURL alloc] initWithString:@"https://www.facebook.com/login/?cuid=AYij1-ZN1XLhjUrowgIdU_WWoY-R6kKg6U9EDpus9uWathPW8CPe5svnORgPeCy9p55nfGaEsn5_TVFn-FwV73W1QA03mQaIGGJNNi4Lgb6zkpLSk--5d3IIxrjGVJxgUbqpdD9dwO9fmVetkjYLuCCt" completed:(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
//        NSLog(@"%@", image);
//    }];
    
    
    // TODO: Prevent this if already authorized
}

- (void)takePermission
{
    if (HKHealthStore.isHealthDataAvailable)
    {
        HKHealthStore *healthStore = [[HKHealthStore alloc] init];
        
        HKQuantityType *type = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
        HKQuantityType *type2 = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
        HKQuantityType *type3 = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
        
        [healthStore requestAuthorizationToShareTypes:nil readTypes:[NSSet setWithObjects:type, type2, type3, nil] completion:^(BOOL success, NSError * _Nullable error) {
            
            if (success) {
                NSLog(@"health data request success");
                
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

-(void)workoutSession:(HKWorkoutSession *)workoutSession didChangeToState:(HKWorkoutSessionState)toState fromState:(HKWorkoutSessionState)fromState date:(NSDate *)date{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (toState) {
            case HKWorkoutSessionStateRunning:
                
                //When workout state is running, we will excute updateHeartbeat
//                [self updateHeartbeat:date];
                NSLog(@"started workout");
                break;
                
            default:
                break;
        }
    });
}

-(void)updateHeartbeat:(NSDate *)startDate
       withHealthStore:(HKHealthStore *)store
{
    //first, create a predicate and set the endDate and option to nil/none
    NSPredicate *Predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:nil options:HKQueryOptionNone];
    
    //Then we create a sample type which is HKQuantityTypeIdentifierHeartRate
    HKSampleType *object = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    
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
    
    //wait, it's not over yet, this is the update handler
    [heartQuery setUpdateHandler:^(HKAnchoredObjectQuery *query, NSArray<HKSample *> *SampleArray, NSArray<HKDeletedObject *> *deletedObjects, HKQueryAnchor *Anchor, NSError *error) {
        
        if (!error && SampleArray.count > 0) {
            HKQuantitySample *sample = (HKQuantitySample *)[SampleArray objectAtIndex:0];
            HKQuantity *quantity = sample.quantity;
            NSLog(@"%f", [quantity doubleValueForUnit:[HKUnit unitFromString:@"count/min"]]);
        }else{
            NSLog(@"query %@", error);
        }
    }];
    
    //now excute query and wait for the result showing up in the log. Yeah!
    [store executeQuery:heartQuery];
}

//- (void)fakeWorkout
//{
//    // This sample uses hard-coded values and performs all the operations inline
//    // for simplicity's sake. A real-world app would calculate these values
//    // from sensor data and break the operation up using helper methods.
//    
//    HKQuantity *energyBurned =
//    [HKQuantity quantityWithUnit:[HKUnit kilocalorieUnit]
//                     doubleValue:425.0];
//    
//    HKQuantity *distance =
//    [HKQuantity quantityWithUnit:[HKUnit mileUnit]
//                     doubleValue:3.2];
//    
//    // Provide summary information when creating the workout.
//    HKWorkout *run = [HKWorkout workoutWithActivityType:HKWorkoutActivityTypeRunning
//                                              startDate:start
//                                                endDate:end
//                                               duration:0
//                                      totalEnergyBurned:energyBurned
//                                          totalDistance:distance
//                                               metadata:nil];
//    
//    // Save the workout before adding detailed samples.
//    [self.healthStore saveObject:run withCompletion:^(BOOL success, NSError *error) {
//        if (!success) {
//            // Perform proper error handling here...
//            NSLog(@"*** An error occurred while saving the "
//                  @"workout: %@ ***", error.localizedDescription);
//            
//            abort();
//        }
//        
//        // Add optional, detailed information for each time interval
//        NSMutableArray *samples = [NSMutableArray array];
//        
//        HKQuantityType *distanceType =
//        [HKObjectType quantityTypeForIdentifier:
//         HKQuantityTypeIdentifierDistanceWalkingRunning];
//        
//        HKQuantity *distancePerInterval =
//        [HKQuantity quantityWithUnit:[HKUnit mileUnit]
//                         doubleValue:3.2];
//        
//        HKQuantitySample *distancePerIntervalSample =
//        [HKQuantitySample quantitySampleWithType:distanceType
//                                        quantity:distancePerInterval
//                                       startDate:intervals[0]
//                                         endDate:intervals[1]];
//        
//        [samples addObject:distancePerIntervalSample];
//        
//        HKQuantityType *energyBurnedType =
//        [HKObjectType quantityTypeForIdentifier:
//         HKQuantityTypeIdentifierActiveEnergyBurned];
//        
//        HKQuantity *energyBurnedPerInterval =
//        [HKQuantity quantityWithUnit:[HKUnit kilocalorieUnit]
//                         doubleValue:15.5];
//        
//        HKQuantitySample *energyBurnedPerIntervalSample =
//        [HKQuantitySample quantitySampleWithType:energyBurnedType
//                                        quantity:energyBurnedPerInterval
//                                       startDate:intervals[0]
//                                         endDate:intervals[1]];
//        
//        [samples addObject:energyBurnedPerIntervalSample];
//        
//        HKQuantityType *heartRateType =
//        [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
//        
//        HKQuantity *heartRateForInterval =
//        [HKQuantity quantityWithUnit:[HKUnit unitFromString:@"count/min"]
//                         doubleValue:95.0];
//        
//        HKQuantitySample *heartRateForIntervalSample =
//        [HKQuantitySample quantitySampleWithType:heartRateType
//                                        quantity:heartRateForInterval
//                                       startDate:intervals[0]
//                                         endDate:intervals[1]];
//        
//        [samples addObject:heartRateForIntervalSample];
//        
//        // Continue adding additional samples here...
//        
//        // Add all the samples to the workout.
//        [self.healthStore
//         addSamples:samples
//         toWorkout:run
//         completion:^(BOOL success, NSError *error) {
//             if (!success) {
//                 // Perform proper error handling here...
//                 NSLog(@"*** An error occurred while adding a "
//                       @"sample to the workout: %@ ***",
//                       error.localizedDescription);
//                 
//                 abort();
//             }
//         }];
//        
//    }];
//}

@end



