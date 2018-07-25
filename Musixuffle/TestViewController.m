//
//  TestViewController.m
//  Musixuffle
//
//  Created by Daniel Wong on 7/24/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

#import "TestViewController.h"
@import AFNetworking;
#import "SpotifyAPIController.h"
#import "SpotifyAuthPage.h"

@interface TestViewController ()

@end

@implementation TestViewController
- (IBAction)onWebTest:(id)sender
{
    NSString *baseURL = @"https://api.spotify.com/v1/recommendations";
    baseURL = [baseURL stringByAppendingString:@"seed_artists=4NHQUGzhtTLFvgF5SZesLK&seed_tracks=0c6xIDDpzE81m2q797ordA&min_energy=0.4&min_popularity=50&market=US"];
    [[AFHTTPSessionManager manager] GET:baseURL parameters:@{@"Authorization" : SpotifyAPIController.sharedInstance.getBearerToken} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@", responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
