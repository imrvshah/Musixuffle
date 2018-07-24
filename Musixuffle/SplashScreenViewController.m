//
//  SplashScreenViewController.m
//  Musixuffle
//
//  Created by Daniel Wong on 7/24/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

#import "SplashScreenViewController.h"
#import "SpotifyAuthPage.h"

@interface SplashScreenViewController ()

@end

@implementation SplashScreenViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    SpotifyAuthPage *authPage = [self.storyboard instantiateViewControllerWithIdentifier:@"loginPage"];
    UINavigationController *navC = [[UINavigationController alloc] initWithRootViewController:authPage];
    [self presentViewController:navC
                       animated:YES
                     completion:^{
                         
                     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
