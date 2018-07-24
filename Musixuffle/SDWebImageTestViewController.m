//
//  SDWebImageTestViewController.m
//  Musixuffle
//
//  Created by Daniel Wong on 7/23/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

#import "SDWebImageTestViewController.h"
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


@interface SDWebImageTestViewController ()<SFSafariViewControllerDelegate, WebViewControllerDelegate, SPTStoreControllerDelegate, WCSessionDelegate>
@property (atomic, readwrite) UIViewController *authViewController;
@property (atomic, readwrite) BOOL firstLoad;
@property (nonatomic, strong) UILabel *statusLabel;
@end

@implementation SDWebImageTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([WCSession isSupported]) {
        WCSession *session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
        NSLog(@"WCSession is supported");
    }
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionUpdatedNotification:) name:@"sessionUpdated" object:nil];
    
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


- (BOOL)prefersStatusBarHidden
{
    return YES;
}


- (UIViewController *)authViewControllerWithURL:(NSURL *)url
{
    UIViewController *viewController;
    if ([SFSafariViewController class]) {
        SFSafariViewController *safari = [[SFSafariViewController alloc] initWithURL:url];
        safari.delegate = self;
        viewController = safari;
    } else {
        WebViewController *webView = [[WebViewController alloc] initWithURL:url];
        webView.delegate = self;
        viewController = [[UINavigationController alloc] initWithRootViewController:webView];
    }
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
//    [self performSegueWithIdentifier:@"ShowPlayer" sender:nil];
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
    auth.requestedScopes = @[SPTAuthStreamingScope];
    auth.redirectURL = [NSURL URLWithString:@kCallbackURL];
#ifdef kTokenSwapServiceURL
    auth.tokenSwapURL = [NSURL URLWithString:@kTokenSwapServiceURL];
#endif
#ifdef kTokenRefreshServiceURL
    auth.tokenRefreshURL = [NSURL URLWithString:@kTokenRefreshServiceURL];
#endif
    auth.sessionUserDefaultsKey = @kSessionUserDefaultsKey;
    
//    [[UIApplication sharedApplication] openURL:[auth spotifyAppAuthenticationURL] options:nil completionHandler:^(BOOL success) {
//
//    }];
//    else
//    {
        self.authViewController = [self authViewControllerWithURL:[auth spotifyWebAuthenticationURL]];
        self.definesPresentationContext = YES;
        [self presentViewController:self.authViewController animated:YES completion:nil];
//    }
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
