//
//  AppDelegate.m
//  Musixuffle
//
//  Created by Ravi Shah on 7/23/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

#import "AppDelegate.h"
#import <HealthKit/HealthKit.h>

#import <SpotifyAuthentication/SpotifyAuthentication.h>

#import <HealthKit/HealthKit.h>
@import SDWebImage;

#import <SpotifyAuthentication/SpotifyAuthentication.h>
#import <SpotifyMetadata/SpotifyMetadata.h>
#import <SpotifyAudioPlayback/SpotifyAudioPlayback.h>
#import "Config.h"

#import <SafariServices/SafariServices.h>
#import <WebKit/WebKit.h>
#import <WatchConnectivity/WatchConnectivity.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:255.0/255.0 green:69.0/255.0 blue:126.0/255.0 alpha:1]];

//    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:70.0/255.0 green:148.0/255.0 blue:255.0/255.0 alpha:1]];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:255.0/255.0 green:219.0/255.0 blue:69.0/255.0 alpha:1]];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)applicationShouldRequestHealthAuthorization:(UIApplication *)application{
    HKHealthStore *healthStore = [[HKHealthStore alloc]init];
    [healthStore handleAuthorizationForExtensionWithCompletion:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            NSLog(@"phone recieved health kit request");
        }
    }];
}

- (void) application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)(void))completionHandler
{
    return;
}


- (BOOL) application:(UIApplication *)application willContinueUserActivityWithType:(NSString *)userActivityType
{
    return YES;
}

- (BOOL) application:(UIApplication *)application openURL:(nonnull NSURL *)url options:(nonnull NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    SPTAuth *auth = [SPTAuth defaultInstance];
    
    SPTAuthCallback authCallback = ^(NSError *error, SPTSession *session) {
        // This is the callback that'll be triggered when auth is completed (or fails).
        
        if (error) {
            NSLog(@"*** Auth error: %@", error);
        } else {
            auth.session = session;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"sessionUpdated" object:self];
    };
    
    /*
     Handle the callback from the authentication service. -[SPAuth -canHandleURL:]
     helps us filter out URLs that aren't authentication URLs (i.e., URLs you use elsewhere in your application).
     */
    
    if ([auth canHandleURL:url]) {
        [auth handleAuthCallbackWithTriggeredAuthURL:url callback:authCallback];
        return YES;
    }
    
    return NO;}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    SPTAuth *auth = [SPTAuth defaultInstance];
    
    SPTAuthCallback authCallback = ^(NSError *error, SPTSession *session) {
        // This is the callback that'll be triggered when auth is completed (or fails).
        
        if (error) {
            NSLog(@"*** Auth error: %@", error);
        } else {
            auth.session = session;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"sessionUpdated" object:self];
    };
    
    /*
     Handle the callback from the authentication service. -[SPAuth -canHandleURL:]
     helps us filter out URLs that aren't authentication URLs (i.e., URLs you use elsewhere in your application).
     */
    
    if ([auth canHandleURL:url]) {
        [auth handleAuthCallbackWithTriggeredAuthURL:url callback:authCallback];
        return YES;
    }
    
    return NO;
}

@end
