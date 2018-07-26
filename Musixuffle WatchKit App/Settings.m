//
//  Settings.m
//  Musixuffle WatchKit Extension
//
//  Created by Daniel Wong on 7/25/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

#import "Settings.h"

@implementation Settings
- (IBAction)onNextTapped {
    [[self class] reloadRootControllersWithNames:@[@"HeartRateInterfaceController",@"MusicInterfaceController", @"EndWorkOutInterfaceController"] contexts:nil];
}
@end
