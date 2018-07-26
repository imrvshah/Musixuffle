//
//  PlaylistCellTableViewCell.m
//  Musixuffle
//
//  Created by Daniel Wong on 7/24/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

#import "PlaylistCell.h"

@implementation PlaylistCell

@synthesize imageView;

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setBackgroundColor:UIColor.blackColor];
    [self.contentView setBackgroundColor:UIColor.blackColor];
}

- (void) layoutSubviews
{
    for (UIView *view in self.contentView.subviews)
    {
        [view setBackgroundColor:UIColor.blackColor];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
