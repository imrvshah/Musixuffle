//
//  SDWebImageTestViewController.m
//  Musixuffle
//
//  Created by Daniel Wong on 7/23/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

#import "SpotifyAuthPage.h"
@import SDWebImage;
@import AFNetworking;
#import <SpotifyAuthentication/SpotifyAuthentication.h>

#import <HealthKit/HealthKit.h>
@import SDWebImage;

#import <SpotifyAuthentication/SpotifyAuthentication.h>
#import <SpotifyMetadata/SpotifyMetadata.h>
#import <SpotifyAudioPlayback/SpotifyAudioPlayback.h>
#import "Config.h"

#import <SafariServices/SafariServices.h>
#import <WebKit/WebKit.h>
#import <WatchConnectivity/WatchConnectivity.h>
#import "SpotifyAPIController.h"

@interface SpotifyAuthPage ()<SFSafariViewControllerDelegate, WebViewControllerDelegate, SPTStoreControllerDelegate, WCSessionDelegate>

@property (nonatomic) WCSession* watchSession;
@property (atomic, readwrite) UIViewController *authViewController;
@property (atomic, readwrite) BOOL firstLoad;
@property (weak, nonatomic) IBOutlet UILabel *labelHeartRate;
@property (nonatomic, strong) UILabel *statusLabel;

@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation SpotifyAuthPage

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([WCSession isSupported])
    {
        self.watchSession = [WCSession defaultSession];
        self.watchSession.delegate = self;
        [self.watchSession activateSession];
        NSLog(@"WCSession is supported");
    }
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    UIImage *img = [UIImage imageNamed:@"Spotify_Icon_RGB_White"];
    self.imageView.image = [UIImage imageWithCGImage:[img CGImage] scale:[img scale]/10 orientation:UIImageOrientationUp];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionUpdatedNotification:) name:@"sessionUpdated" object:nil];
    [self animate];
}

- (void) animate
{
    static BOOL reverse = NO;
    __weak typeof(self) weakSelf = self;
    [UIView transitionWithView:self.titleLabel
                      duration:1.
                        options:UIViewAnimationOptionTransitionCrossDissolve
                     animations:^{
                         if (reverse)
                         {
                             [self.titleLabel setTextColor:[UIColor colorWithRed:255.0/255.0 green:69.0/255.0 blue:126.0/255.0 alpha:1]];
                         }
                         else
                         {
                              [self.titleLabel setTextColor:UIColor.whiteColor];
                         }
                     } completion:^(BOOL finished) {
                         if (finished)
                         {
                             reverse = !reverse;
                             [weakSelf performSelector:@selector(animate) withObject:nil afterDelay:1];
                         }
                     }];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;

}

- (IBAction)onSignInTapped:(id)sender
{
    SPTAuth *auth = [SPTAuth defaultInstance];
    if ([auth.session isValid])
    {
        [self showPlayer];
    }
    else
    {
        [self openLoginPage];
    }
}

- (IBAction)onClearCookies:(id)sender
{
    [[SpotifyAPIController sharedInstance] clearCookiesClicked];
}


- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.hidden = YES;
    [super viewWillAppear:animated];
    
    SPTAuth *auth = [SPTAuth defaultInstance];
    // Uncomment to turn off native/SSO/flip-flop login flow
    //auth.allowNativeLogin = NO;
    
    // Check if we have a token at all
    if (auth.session == nil) {
        self.statusLabel.text = @"";
        return;
    }
    
    // Check if it's still valid
    if ([auth.session isValid] && self.firstLoad) {
        // It's still valid, show the player.
        [self showPlayer];
        return;
    }
    
    // Oh noes, the token has expired, if we have a token refresh service set up, we'll call tat one.
    self.statusLabel.text = @"Token expired.";
    if (auth.hasTokenRefreshService) {
        [self renewTokenAndShowPlayer];
        return;
    }
    
    WCSession *session = [WCSession defaultSession];
    NSError *error;
    
    [session updateApplicationContext:@{@"firstItem": @"item1", @"secondItem":[NSNumber numberWithInt:2]} error:&error];
    
    // Else, just show login dialog
}

- (UIViewController *)authViewControllerWithURL:(NSURL *)url
{
    UIViewController *viewController;
//    if ([SFSafariViewController class]) {
//        SFSafariViewController *safari = [[SFSafariViewController alloc] initWithURL:url];
//        safari.delegate = self;
//        viewController = safari;
//    } else {
        WebViewController *webView = [[WebViewController alloc] initWithURL:url];
        webView.delegate = self;
        viewController = [[UINavigationController alloc] initWithRootViewController:webView];
//    }
    viewController.modalPresentationStyle = UIModalPresentationPageSheet;
    return viewController;
}

- (void)sessionUpdatedNotification:(NSNotification *)notification
{
    self.statusLabel.text = @"";
    
    SPTAuth *auth = [SPTAuth defaultInstance];
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    
    
    if (auth.session && [auth.session isValid]) {
        self.statusLabel.text = @"";
        [self showPlayer];
    } else {
        self.statusLabel.text = @"Login failed.";
        NSLog(@"*** Failed to log in");
    }
}

- (void)showPlayer
{
    self.firstLoad = NO;
    self.statusLabel.text = @"Logged in.";
    
    UIViewController *viewController = [[UIStoryboard storyboardWithName:@"Player" bundle:NSBundle.mainBundle] instantiateViewControllerWithIdentifier:@"Player"];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - SPTStoreControllerDelegate

- (void)productViewControllerDidFinish:(SPTStoreViewController *)viewController
{
    self.statusLabel.text = @"App Store Dismissed.";
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)openLoginPage
{
    self.statusLabel.text = @"Logging in...";
    SPTAuth *auth = [SPTAuth defaultInstance];
    auth.clientID = @kClientId;
    auth.redirectURL = [NSURL URLWithString:@kCallbackURL];
    auth.requestedScopes = @[SPTAuthStreamingScope, SPTAuthPlaylistReadPrivateScope, SPTAuthPlaylistReadCollaborativeScope, SPTAuthPlaylistModifyPublicScope, SPTAuthPlaylistModifyPrivateScope, SPTAuthUserFollowModifyScope, SPTAuthUserFollowReadScope, SPTAuthUserLibraryReadScope, SPTAuthUserLibraryModifyScope, SPTAuthUserReadPrivateScope, SPTAuthUserReadTopScope, SPTAuthUserReadBirthDateScope, SPTAuthUserReadEmailScope, @"user-read-recently-played"];
    if ([SPTAuth supportsApplicationAuthentication])
    {
        [[UIApplication sharedApplication] openURL:[auth spotifyAppAuthenticationURL] options:@{} completionHandler:nil];
    }
    else
    {
        self.authViewController = [self authViewControllerWithURL:[[SPTAuth defaultInstance] spotifyWebAuthenticationURL]];
        self.definesPresentationContext = YES;

        [self presentViewController:self.authViewController animated:YES completion:nil];
    }
}

- (void)renewTokenAndShowPlayer
{
    self.statusLabel.text = @"Refreshing token...";
    SPTAuth *auth = [SPTAuth defaultInstance];
    
    [auth renewSession:auth.session callback:^(NSError *error, SPTSession *session) {
        auth.session = session;
        
        if (error) {
            self.statusLabel.text = @"Refreshing token failed.";
            NSLog(@"*** Error renewing session: %@", error);
            return;
        }
        
        [self showPlayer];
    }];
}

#pragma mark WebViewControllerDelegate

- (void)webViewControllerDidFinish:(WebViewController *)controller
{
    // User tapped the close button. Treat as auth error
}

#pragma mark SFSafariViewControllerDelegate

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller
{
    // User tapped the close button. Treat as auth error
}

#pragma mark - IBActions

- (IBAction)loginClicked:(id)sender
{
    [self openLoginPage];
}

- (IBAction)showSpotifyAppStoreClicked:(id)sender
{
    self.statusLabel.text = @"Presenting App Store...";
    SPTStoreViewController *storeVC = [[SPTStoreViewController alloc] initWithCampaignToken:@"your_campaign_token"
                                                                              storeDelegate:self];
    [self presentViewController:storeVC animated:YES completion:nil];
}

- (IBAction)clearCookiesClicked:(id)sender
{
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        if ([cookie.domain rangeOfString:@"spotify."].length > 0 ||
            [cookie.domain rangeOfString:@"facebook."].length > 0) {
            [storage deleteCookie:cookie];
        }
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.statusLabel.text = @"Cookies cleared.";
}

- (void) session:(nonnull WCSession *)session didReceiveApplicationContext:(nonnull NSDictionary<NSString *,id> *)applicationContext
{
    if ([applicationContext objectForKey:@"heartRate"])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.labelHeartRate.text = [[applicationContext objectForKey:@"heartRate"] stringValue];
        });
        
    }
    else if ([applicationContext objectForKey:@"like"])
    {
        
    }
    else if ([applicationContext objectForKey:@"disLike"])
    {
        
    }
    
    
}

-(void)session:(WCSession *)session didReceiveMessageData:(NSData *)messageData replyHandler:(void(^)(NSData *replyMessageData))replyHandler
{
    NSLog(@"didReceiveMessageData");
}

/** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
- (void)session:(WCSession *)session activationDidCompleteWithState:(WCSessionActivationState)activationState error:(nullable NSError *)error
{
    
}
@end
