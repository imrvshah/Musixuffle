//
//  MusicInterfaceController.h
//  Musixuffle WatchKit App
//
//  Created by Ravi Shah on 7/24/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface MusicInterfaceController : WKInterfaceController
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *lableSong;

- (IBAction)buttonLikeClicked;
- (IBAction)buttonDisLikeClicked;

@end
