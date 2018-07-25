//
//  Playlist.h
//  Musixuffle
//
//  Created by Daniel Wong on 7/24/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Player.h"

NS_ASSUME_NONNULL_BEGIN

@interface Playlist : UITableViewController
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) SPTAudioStreamingController *player;
@end

NS_ASSUME_NONNULL_END
