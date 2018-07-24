//
//  SplashScreenViewController.h
//  Musixuffle
//
//  Created by Daniel Wong on 7/24/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <SpotifyAudioPlayback/SpotifyAudioPlayback.h>

@interface SplashScreenViewController : UIViewController<SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate>

@end
