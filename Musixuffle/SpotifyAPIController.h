//
//  SpotifyAPIController.h
//  Musixuffle
//
//  Created by Daniel Wong on 7/24/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SpotifyAPIController : NSObject
+ (instancetype) sharedInstance;
- (NSString *) getBearerToken;
- (void)clearCookiesClicked;
@end
