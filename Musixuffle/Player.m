//
//  SplashScreenViewController.m
//  Musixuffle
//
//  Created by Daniel Wong on 7/24/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

#import "Player.h"
#import "SpotifyAuthPage.h"
#import "Config.h"
#import "Playlist.h"
#import <SpotifyAuthentication/SpotifyAuthentication.h>
#import <SpotifyMetadata/SpotifyMetadata.h>
#import <AVFoundation/AVFoundation.h>

#import <SafariServices/SafariServices.h>
#import <WebKit/WebKit.h>
#import <WatchConnectivity/WatchConnectivity.h>

#import "SpotifyAPIController.h"

@interface Player () <WCSessionDelegate>

@property (weak, nonatomic) IBOutlet UILabel *trackTitle;
@property (weak, nonatomic) IBOutlet UILabel *artistTitle;
@property (weak, nonatomic) IBOutlet UIImageView *coverView;
@property (weak, nonatomic) IBOutlet UIImageView *coverView2;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
@property (weak, nonatomic) IBOutlet UILabel *playbackSourceTitle;
@property (nonatomic) WCSession* watchSession;

@property (weak, nonatomic) IBOutlet UIButton *playPauseButton;

@property (nonatomic, strong) SPTAudioStreamingController *player;

@property IBOutlet UIButton* nextButton;
@property IBOutlet UIButton* prevButton;

@property (nonatomic) BOOL isChangingProgress;

@end

@implementation Player

-(void)viewDidLoad
{
    if ([WCSession isSupported])
    {
        self.watchSession = [WCSession defaultSession];
        self.watchSession.delegate = self;
        [self.watchSession activateSession];
        NSLog(@"WCSession is supported");
    }
    
    [super viewDidLoad];
    
    self.title = @"Musixuffle";
    self.trackTitle.text = @" ";
    self.artistTitle.text = @" ";
    
    [self.playPauseButton.titleLabel setTextAlignment:NSTextAlignmentCenter];    
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

#pragma mark - Actions

-(IBAction)rewind:(id)sender {
    [self.player skipPrevious:nil];
}

-(IBAction)playPause:(id)sender {
    __weak typeof(self) weakSelf = self;
    BOOL wasPlaying = self.player.playbackState.isPlaying;
    [self.player setIsPlaying:!wasPlaying callback:^(NSError *error) {
        [weakSelf.playPauseButton setTitle:wasPlaying ? @"Play" : @"Pause" forState:UIControlStateNormal];
        NSLog(@"%@", error);
    }];
}

-(IBAction)fastForward:(id)sender {
    [self.player skipNext:nil];
}

- (IBAction)seekValueChanged:(id)sender {
    self.isChangingProgress = NO;
    NSUInteger dest = self.player.metadata.currentTrack.duration * self.progressSlider.value;
    [self.player seekTo:dest callback:nil];
}

- (IBAction)logoutClicked:(id)sender {
    if (self.player) {
        [self.player logout];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)proggressTouchDown:(id)sender {
    self.isChangingProgress = YES;
}


#pragma mark - Logic


- (UIImage *)applyBlurOnImage: (UIImage *)imageToBlur
                   withRadius: (CGFloat)blurRadius {
    
    CIImage *originalImage = [CIImage imageWithCGImage: imageToBlur.CGImage];
    CIFilter *filter = [CIFilter filterWithName: @"CIGaussianBlur"
                                  keysAndValues: kCIInputImageKey, originalImage,
                        @"inputRadius", @(blurRadius), nil];
    
    CIImage *outputImage = filter.outputImage;
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CGImageRef outImage = [context createCGImage: outputImage
                                        fromRect: [outputImage extent]];
    
    UIImage *ret = [UIImage imageWithCGImage: outImage];
    
    CGImageRelease(outImage);
    
    return ret;
}

-(void)updateUI {
    SPTAuth *auth = [SPTAuth defaultInstance];
    
    if (self.player.metadata == nil || self.player.metadata.currentTrack == nil) {
        self.coverView.image = nil;
        self.coverView2.image = nil;
        return;
    }
    
    [self.spinner startAnimating];
    
    self.nextButton.enabled = self.player.metadata.nextTrack != nil;
    self.prevButton.enabled = self.player.metadata.prevTrack != nil;
    self.trackTitle.text = self.player.metadata.currentTrack.name;
    self.artistTitle.text = self.player.metadata.currentTrack.artistName;
    self.playbackSourceTitle.text = self.player.metadata.currentTrack.playbackSourceName;
    
    [self.playPauseButton setTitle:@"Pause" forState:UIControlStateNormal];
    
    [SPTTrack trackWithURI: [NSURL URLWithString:self.player.metadata.currentTrack.uri]
               accessToken:auth.session.accessToken
                    market:nil
                  callback:^(NSError *error, SPTTrack *track) {
                      NSURL *imageURL = track.album.largestCover.imageURL;
                      if (imageURL == nil) {
                          NSLog(@"Album %@ doesn't have any images!", track.album);
                          self.coverView.image = nil;
                          self.coverView2.image = nil;
                          return;
                      }
                      
                      // Pop over to a background queue to load the image over the network.
                      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                          NSError *error = nil;
                          UIImage *image = nil;
                          NSData *imageData = [NSData dataWithContentsOfURL:imageURL options:0 error:&error];
                          
                          if (imageData != nil) {
                              image = [UIImage imageWithData:imageData];
                          }
                          
                          
                          // …and back to the main queue to display the image.
                          dispatch_async(dispatch_get_main_queue(), ^{
                              [self.spinner stopAnimating];
                              self.coverView.image = image;
                              if (image == nil) {
                                  NSLog(@"Couldn't load cover image with error: %@", error);
                                  return;
                              }
                          });
                          
                          // Also generate a blurry version for the background
                          UIImage *blurred = [self applyBlurOnImage:image withRadius:10.0f];
                          dispatch_async(dispatch_get_main_queue(), ^{
                              self.coverView2.image = blurred;
                          });
                      });
                      
                  }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self handleNewSession];
    //    self.playPauseButton.titleLabel.text = self.player.playbackState.isPlaying ? @"Pause" : @"Play";
}

-(void)handleNewSession {
    SPTAuth *auth = [SPTAuth defaultInstance];
    
    if (self.player == nil) {
        NSError *error = nil;
        self.player = [SPTAudioStreamingController sharedInstance];
        if ([self.player startWithClientId:auth.clientID audioController:nil allowCaching:YES error:&error]) {
            self.player.delegate = self;
            self.player.playbackDelegate = self;
            self.player.diskCache = [[SPTDiskCache alloc] initWithCapacity:1024 * 1024 * 6400];
            [self.player loginWithAccessToken:auth.session.accessToken];
        } else {
            self.player = nil;
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error init" message:[error description] preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
            [self closeSession];
        }
    }
}

- (void)closeSession {
    NSError *error = nil;
    if (![self.player stopWithError:&error]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error deinit" message:[error description] preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
    [SPTAuth defaultInstance].session = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Track Player Delegates

- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didReceiveMessage:(NSString *)message {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Message from Spotify"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangePlaybackStatus:(BOOL)isPlaying {
    NSLog(@"is playing = %d", isPlaying);
    if (isPlaying) {
        [self activateAudioSession];
    } else {
        [self deactivateAudioSession];
    }
}

-(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangeMetadata:(SPTPlaybackMetadata *)metadata {
    [self updateUI];
}

-(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didReceivePlaybackEvent:(SpPlaybackEvent)event withName:(NSString *)name {
    NSLog(@"didReceivePlaybackEvent: %zd %@", event, name);
    NSLog(@"isPlaying=%d isRepeating=%d isShuffling=%d isActiveDevice=%d positionMs=%f",
          self.player.playbackState.isPlaying,
          self.player.playbackState.isRepeating,
          self.player.playbackState.isShuffling,
          self.player.playbackState.isActiveDevice,
          self.player.playbackState.position);
}

- (void)audioStreamingDidLogout:(SPTAudioStreamingController *)audioStreaming {
    [self closeSession];
}

- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didReceiveError:(NSError* )error {
    NSLog(@"didReceiveError: %zd %@", error.code, error.localizedDescription);
    
    if (error.code == SPErrorNeedsPremium) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Premium account required" message:@"Premium account is required to showcase application functionality. Please login using premium account." preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action){
            [self closeSession];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
        
    }
}

- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangePosition:(NSTimeInterval)position {
    if (self.isChangingProgress) {
        return;
    }
    self.progressSlider.value = position/self.player.metadata.currentTrack.duration;
    
}

- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didStartPlayingTrack:(NSString *)trackUri {
    NSLog(@"Starting %@", trackUri);
    NSLog(@"Source %@", self.player.metadata.currentTrack.playbackSourceUri);
    // If context is a single track and the uri of the actual track being played is different
    // than we can assume that relink has happended.
    BOOL isRelinked = [self.player.metadata.currentTrack.playbackSourceUri containsString: @"spotify:track"]
    && ![self.player.metadata.currentTrack.playbackSourceUri isEqualToString:trackUri];
    NSLog(@"Relinked %d", isRelinked);
}

- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didStopPlayingTrack:(NSString *)trackUri {
    NSLog(@"Finishing: %@", trackUri);
}

- (void)audioStreamingDidLogin:(SPTAudioStreamingController *)audioStreaming {
    [self updateUI];
    
    __weak typeof(self) weakSelf = self;
    [[SpotifyAPIController sharedInstance] getMostRecentSong:^(NSArray *arr) {
        NSString *randomObject = arr[rand() % arr.count];
        
        [weakSelf.player playSpotifyURI:randomObject startingWithIndex:0 startingWithPosition:10 callback:^(NSError *error) {
            if (error != nil)
            {
                NSLog(@"*** failed to play: %@", error);
                return;
            }
            else
            {
                [[SpotifyAPIController sharedInstance] getRelatedTracksForTracks:@[] withCompletion:^(NSArray *next) {
                }];
            }
        }];
    }];
}

#pragma mark - Audio Session

- (void)activateAudioSession
{
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback
                                           error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}

- (void)deactivateAudioSession
{
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
}

- (IBAction)onOpenPlaylistTapped:(id)sender
{
    Playlist *p = Playlist.new;
    p.player = self.player;
    [self.navigationController pushViewController:p animated:YES];
}

- (void) session:(nonnull WCSession *)session didReceiveApplicationContext:(nonnull NSDictionary<NSString *,id> *)applicationContext
{
    if ([applicationContext objectForKey:@"heartRate"])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSUInteger inq = [[applicationContext objectForKey:@"heartRate"] unsignedIntegerValue];
            [[SpotifyAPIController sharedInstance] updateLastHeartRate:inq];
        });
        
    }
    else if ([applicationContext objectForKey:@"like"])
    {
        
    }
    else if ([applicationContext objectForKey:@"disLike"])
    {
        
    }
    
    
}

@end

