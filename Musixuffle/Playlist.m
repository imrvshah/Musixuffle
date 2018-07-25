//
//  Playlist.m
//  Musixuffle
//
//  Created by Daniel Wong on 7/24/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

#import "Playlist.h"
#import "SpotifyAPIController.h"
#import "PlaylistCell.h"

@import SDWebImage;

@interface Playlist ()
@property (atomic, strong) NSArray *viewItems;
@end

@implementation Playlist

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"PlaylistCell" bundle:nil] forCellReuseIdentifier:@"cell"];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self update];
}

- (IBAction)onDoneTapped:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void) update
{
    NSArray *copy = [[[SpotifyAPIController sharedInstance] getCurrentPlaylist] copy];
    _viewItems = copy;
    
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _viewItems.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 104;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PlaylistCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
    NSDictionary *dict = [_viewItems objectAtIndex:indexPath.row];
    if (dict)
    {
        cell.title.text = [dict objectForKey:@"name"];
        cell.subTitle.text = [dict objectForKey:@"albumName"];
        
        __weak typeof(cell) weakCell = cell;
        [weakCell.imgView2 sd_setImageWithURL:[dict objectForKey:@"imageURL"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            weakCell.imgView2.image = image;
            [weakCell setNeedsDisplay];
            [weakCell setNeedsLayout];
            [weakCell updateConstraints];
        }];
    }
    
    return cell;
}

@end
