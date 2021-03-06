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

@interface SpotifyAPIController()
@property (atomic, strong) NSArray *playlist;
@property (atomic) NSUInteger heartRate;

@end

@implementation SpotifyAPIController
+ (instancetype) sharedInstance
{
    static SpotifyAPIController *controller = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        controller = [[SpotifyAPIController alloc] init];
        controller.heartRate = 100;
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


- (void)getRelatedTracksForTracks:(NSArray *)seedTrackArray withCompletion:(void (^)(NSArray *))completion
{
    NSString *baseURL = @"https://api.spotify.com/v1/";
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:baseURL]];
    
    [manager.requestSerializer setValue:SpotifyAPIController.sharedInstance.getBearerToken forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSString *minTempo = [@(80) stringValue];
    NSString *maxTempo = [@(150) stringValue];

    // other parameters: max_instrumentalness, max_energy
    
    if ([seedTrackArray count] < 1) // default
    {
        seedTrackArray = @[@"6rqhFgbbKwnb9MLmUQDhG6", @"0c6xIDDpzE81m2q797ordA"];
    }
    
    [manager GET:@"recommendations"
      parameters:@{
                   @"seed_tracks" : [seedTrackArray componentsJoinedByString:@","],
                   @"min_tempo" :  @(self.heartRate - 5),
                   @"max_tempo" :  @(self.heartRate + 5),
                   @"limit" : @"5"
                   }
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             
             id trackObjArray = [self processRecommendations:responseObject];
             
             NSString *first = @"";
             NSString *second = @"";
             
             if ([trackObjArray count])
             {
                 first = [trackObjArray[0][@"uri"] componentsSeparatedByString:@":"][2];
                 second = [trackObjArray[1][@"uri"] componentsSeparatedByString:@":"][2];
             }

             [manager GET:@"recommendations"
               parameters:@{
                            @"seed_tracks" : [NSString stringWithFormat:@"%@,%@", first, second],
                            @"min_tempo" :  @(self.heartRate - 5),
                            @"max_tempo" :  @(self.heartRate + 5),
                            @"limit" : @"5"
                            }
                 progress:nil
                  success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                      
                      id trackObjArray2 = [self processRecommendations:responseObject];
                      NSArray *allTrackObj = [trackObjArray arrayByAddingObjectsFromArray:trackObjArray2];
                      
                      if (completion && allTrackObj)
                      {
                          [self updatePlaylist:allTrackObj];
                          completion(allTrackObj);
                      }
                  }
                  failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                      if (completion && trackObjArray)
                      {
                          [self updatePlaylist:trackObjArray];
                          completion(trackObjArray);
                      }
                  }];
     }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSLog(@"%@", error);
             completion(nil);
     }];
}



- (NSMutableArray *)processRecommendations:(NSDictionary *)response
{
    NSMutableArray *trackObjArray = [[NSMutableArray alloc] init];
    for (id track in response[@"tracks"])
    {
        NSString *uri = [track objectForKey:@"uri"];
        NSString *name = [track objectForKey:@"name"];
        NSString *imgURL = track[@"album"][@"images"][0][@"url"];
        NSString *albumName = track[@"album"][@"name"];
        [trackObjArray addObject:@{@"uri" : uri,
                                   @"name" : name,
                                   @"imageURL" : imgURL,
                                   @"albumName" : albumName
                                   }];
    }

    return trackObjArray;
}

- (void) addHeadersForSDWebImage
{
    [SDWebImageDownloader.sharedDownloader setValue:self.getBearerToken forHTTPHeaderField:@"Authorization"];
}

- (void) getMostRecentSong:(void (^)(NSArray *))completion
{
    NSString *baseURL = @"https://api.spotify.com/v1/";
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:baseURL]];
    
    [manager.requestSerializer setValue:SpotifyAPIController.sharedInstance.getBearerToken forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [manager GET:@"me/player/recently-played"
      parameters:@{
                   @"limit" : @10,
                   @"type"  : @"track"
                   }
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             id trackObjArray = [self processMostRecents:responseObject];
             if (completion) completion (trackObjArray);
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSLog(@"%@", error);
             if (completion) completion (nil);
         }];
}
- (NSMutableArray *)processMostRecents:(NSDictionary *)response
{
    NSMutableArray *trackObjArray = [[NSMutableArray alloc] init];
    for (NSDictionary *item in response[@"items"])
    {
        NSDictionary *trackDictionary = item[@"track"];
//        for (NSDictionary *trackDictionary in item[@"track"])
        {
            NSArray *trackURI = [trackDictionary valueForKey:@"uri"];
            if (trackURI)
            {
                [trackObjArray addObject:trackURI];
            }
        }
    }
    
    return trackObjArray;
}

- (NSArray *) getCurrentPlaylist
{
    return  self.playlist;
}

- (void) updatePlaylist:(NSArray *)array
{
    @synchronized (self)
    {
        self.playlist = [array copy];
    }
}

- (void) replaceSongByRemovingAtIndex:(NSInteger)index withCompletion:(void (^)(void))completion
{
    NSMutableArray *items = self.playlist.mutableCopy;
    [items removeObjectAtIndex:index];

    
    // new recommendation
    NSString *baseURL = @"https://api.spotify.com/v1/";
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:baseURL]];
    
    [manager.requestSerializer setValue:SpotifyAPIController.sharedInstance.getBearerToken forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSString *first = [[[items firstObject] objectForKey:@"uri"] componentsSeparatedByString:@":"][2];
    NSString *last = [[[items lastObject] objectForKey:@"uri"] componentsSeparatedByString:@":"][2];
    
    [manager GET:@"recommendations"
      parameters:@{
                   @"seed_tracks" : [NSString stringWithFormat:@"%@,%@", first, last],
                   @"min_tempo" :  @(self.heartRate - 5),
                   @"max_tempo" :  @(self.heartRate + 5),
                   @"limit" : @"5"
                   }
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             
             id trackObjArray = [self processRecommendations:responseObject];
             
             for (id track in trackObjArray)
             {
                 if ([items containsObject:track])
                 {
                     
                 }
                 else
                 {
                     [items addObject:track];
                     [self updatePlaylist:items];
                     if (completion)
                     {
                         completion();
                     }
                     return;
                 }
             }
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSLog(@"%@", error);
         }];
}

- (void) updateLastHeartRate:(NSUInteger)heartRate
{
    NSLog(@"User heart rate %lu", heartRate);
    self.heartRate = heartRate;
}
@end
