//
//  SDWebImageTestViewController.m
//  Musixuffle
//
//  Created by Daniel Wong on 7/23/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

#import "SDWebImageTestViewController.h"
@import SDWebImage;
@import AFNetworking;

@interface SDWebImageTestViewController ()

@end

@implementation SDWebImageTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[AFHTTPSessionManager manager] GET:@"http://facebook.com" parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
