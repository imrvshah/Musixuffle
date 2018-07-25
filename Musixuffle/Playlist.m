//
//  Playlist.m
//  Musixuffle
//
//  Created by Daniel Wong on 7/24/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

#import "Playlist.h"

@interface Playlist ()

@end

@implementation Playlist

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)onDoneTapped:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


@end
