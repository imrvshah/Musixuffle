//
//  SpotifyAPIController.m
//  Musixuffle
//
//  Created by Daniel Wong on 7/24/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

#import "SpotifyAPIController.h"

#import "SpotifyAuthPage.h"
@import SDWebImage;
@import AFNetworking;
#import <SpotifyAuthentication/SpotifyAuthentication.h>

#import <HealthKit/HealthKit.h>
@import SDWebImage;

#import <SpotifyAuthentication/SpotifyAuthentication.h>
#import <SpotifyMetadata/SpotifyMetadata.h>
#import <SpotifyAudioPlayback/SpotifyAudioPlayback.h>
#import "Config.h"

#import <SafariServices/SafariServices.h>
#import <WatchConnectivity/WatchConnectivity.h>

@implementation SpotifyAPIController
+ (instancetype) sharedInstance
{
    static SpotifyAPIController *controller = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        controller = [[SpotifyAPIController alloc] init];
    });
    
    return controller;
}

- (NSString *) getBearerToken
{
    SPTAuth *auth = [SPTAuth defaultInstance];
    if ([auth.session isValid])
    {
        return [NSString stringWithFormat:@"Bearer %@", [auth.session accessToken]];
    }
    
    return nil;
}

- (void)clearCookiesClicked
{
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        if ([cookie.domain rangeOfString:@"spotify."].length > 0 ||
            [cookie.domain rangeOfString:@"facebook."].length > 0) {
            [storage deleteCookie:cookie];
        }
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end
