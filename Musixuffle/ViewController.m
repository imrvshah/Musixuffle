//
//  ViewController.m
//  Musixuffle
//
//  Created by Ravi Shah on 7/23/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

#import "ViewController.h"
#import <HealthKit/HealthKit.h>
@import SDWebImage;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *imageView = nil;
    NSURL *url = [[NSURL alloc] initWithString:@"https://www.facebook.com/login/?cuid=AYij1-ZN1XLhjUrowgIdU_WWoY-R6kKg6U9EDpus9uWathPW8CPe5svnORgPeCy9p55nfGaEsn5_TVFn-FwV73W1QA03mQaIGGJNNi4Lgb6zkpLSk--5d3IIxrjGVJxgUbqpdD9dwO9fmVetkjYLuCCt" completed:(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        NSLog(@"%@", image);
    }];
    [imageView sd_setImageWithURL:url];
    
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)buttonHeartBeatClicked:(id)sender
{
    
    
    
}




@end
