//
//  PlaylistCellTableViewCell.h
//  Musixuffle
//
//  Created by Daniel Wong on 7/24/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PlaylistCellTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *title;
@property (strong, nonatomic) IBOutlet UILabel *subTitle;

@end

NS_ASSUME_NONNULL_END
