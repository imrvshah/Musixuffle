//
//  TempViewController.m
//  Musixuffle
//
//  Created by Avi Dubey on 7/24/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

@import AFNetworking;
#import "TempViewController.h"
#import "SpotifyAPIController.h"

@interface TempViewController ()

@end

@implementation TempViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self spotifying];
}

- (void)spotifying
{
    NSString *baseURL = @"https://api.spotify.com/v1/";
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:baseURL]];
    
    [manager.requestSerializer setValue:SpotifyAPIController.sharedInstance.getBearerToken forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    NSString *minTempo = [[NSNumber numberWithInt:80] stringValue];
    NSString *maxTempo = [[NSNumber numberWithInt:150] stringValue];
    
    // other parameters: max_instrumentalness, max_energy
    
    NSArray *seedTrackArray = @[@"6rqhFgbbKwnb9MLmUQDhG6", @"0c6xIDDpzE81m2q797ordA"];
    
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

-(void) processRecommendations:(NSDictionary *)response
{
    NSString *firstTrackURL = response[@"tracks"][0][@"href"];
    NSURL *trackURL = [NSURL URLWithString:firstTrackURL];
    
    
    
    NSLog(@"%@", trackURL);
}
@end

