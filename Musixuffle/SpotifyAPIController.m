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

- (void)getRelatedTracksForTracks:(NSArray *)seedTrackArray
{
    NSString *baseURL = @"https://api.spotify.com/v1/";
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:baseURL]];
    
    [manager.requestSerializer setValue:SpotifyAPIController.sharedInstance.getBearerToken forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSString *minTempo = [[NSNumber numberWithInt:80] stringValue];
    NSString *maxTempo = [[NSNumber numberWithInt:150] stringValue];
    // other parameters: max_instrumentalness, max_energy
    
    if ([seedTrackArray count] < 1) // default
    {
        seedTrackArray = @[@"6rqhFgbbKwnb9MLmUQDhG6", @"0c6xIDDpzE81m2q797ordA"];
    }
    
    [manager GET:@"recommendations"
      parameters:@{
                   @"seed_tracks" : [seedTrackArray componentsJoinedByString:@","],
                   @"min_tempo" : minTempo,
                   @"max_tempo" : maxTempo,
                   @"limit" : @"2"}
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self processRecommendations:responseObject];
     }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSLog(@"%@", error);
     }];
}

- (void)processRecommendations:(NSDictionary *)response
{
    NSMutableArray *trackObjArray = [[NSMutableArray alloc] init];
    for (id track in response[@"tracks"])
    {
        [trackObjArray addObject:track[@"href"]];
    }

//    return trackObjArray;
}

@end
