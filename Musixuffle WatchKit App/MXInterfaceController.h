//
//  MXInterfaceController.h
//  Musixuffle WatchKit App
//
//  Created by Ravi Shah on 7/23/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface MXInterfaceController : WKInterfaceController
- (IBAction)buttonHeartBeatClicked;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *lableHeartRate;

@end
