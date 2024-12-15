#import "AdMobManager.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//#import <AppTrackingTransparency/AppTrackingTransparency.h>

#import <GoogleMobileAds/GoogleMobileAds.h>
//#import <FirebaseCore/FirebaseCore.h>

// C++ Callback Declaration
static void (*interstitialAdClosedCallback)() = nullptr;

// AdMobBridge Interface
@interface AdMobBridge : NSObject <GADFullScreenContentDelegate>
@property (nonatomic, strong) GADBannerView *bannerView;
@property (nonatomic, strong) GADInterstitialAd *interstitialAd;
@property (nonatomic) BOOL interstitialDismissed;

// Singleton Access
+ (instancetype)sharedInstance;

// Public Methods
+ (void)initializeAdMob;
+ (void)showBannerAd;
+ (void)loadInterstitialAd;
+ (void)showInterstitialAd;
+ (void)hideBannerAd;
+ (BOOL)isInterstitialAdDismissed;
+ (void)resetInterstitialDismissFlag;

@end

@implementation AdMobBridge

#pragma mark - Singleton Instance
+ (instancetype)sharedInstance {
    static AdMobBridge *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

#pragma mark - Initialize Google Mobile Ads
+ (void)initializeAdMob {
    
    // Enable Test Device for Testing
    GADMobileAds.sharedInstance.requestConfiguration.testDeviceIdentifiers = @[@"1028cfae597c00353edfba88d89a7921"];

    [[GADMobileAds sharedInstance] startWithCompletionHandler:nil];
    
    
    NSLog(@"✅ Google Mobile Ads Initialized.");
}

#pragma mark - Show Banner Ad
+ (void)showBannerAd {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    UIViewController *rootViewController = keyWindow.rootViewController;

    AdMobBridge *bridge = [AdMobBridge sharedInstance];
    if (!bridge.bannerView) {
        bridge.bannerView = [[GADBannerView alloc] initWithAdSize:GADAdSizeBanner];
        bridge.bannerView.adUnitID = @"ca-app-pub-3940256099942544/2934735716";  // Test Ad Unit ID
        bridge.bannerView.rootViewController = rootViewController;

        // Banner Frame Setup
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        bridge.bannerView.frame = CGRectMake(
            (screenSize.width - bridge.bannerView.frame.size.width) / 2,
            screenSize.height - bridge.bannerView.frame.size.height,
            bridge.bannerView.frame.size.width,
            bridge.bannerView.frame.size.height
        );

        [rootViewController.view addSubview:bridge.bannerView];
    }

    GADRequest *request = [GADRequest request];
    [bridge.bannerView loadRequest:request];
    NSLog(@"✅ Banner Ad Loaded and Displayed.");
}

#pragma mark - Load Interstitial Ad
+ (void)loadInterstitialAd {
    GADRequest *request = [GADRequest request];

    [GADInterstitialAd loadWithAdUnitID:@"ca-app-pub-3940256099942544/4411468910"
                                request:request
                      completionHandler:^(GADInterstitialAd *ad, NSError *error) {
        if (error) {
            NSLog(@"❌ Failed to Load Interstitial Ad: %@", error.localizedDescription);
            return;
        }

        AdMobBridge *bridge = [AdMobBridge sharedInstance];
        bridge.interstitialAd = ad;
        [bridge.interstitialAd setFullScreenContentDelegate:bridge];
        NSLog(@"✅ Interstitial Ad Loaded.");
    }];
}

#pragma mark - Show Interstitial Ad
+ (void)showInterstitialAd {
    AdMobBridge *bridge = [AdMobBridge sharedInstance];

    if (bridge.interstitialAd) {
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        UIViewController *rootViewController = keyWindow.rootViewController;

        dispatch_async(dispatch_get_main_queue(), ^{
            [bridge.interstitialAd presentFromRootViewController:rootViewController];
        });

        NSLog(@"✅ Interstitial Ad Shown.");
    } else {
        NSLog(@"❌ Interstitial Ad Not Ready.");
    }
}

#pragma mark - Interstitial Ad Delegate
- (void)adDidDismissFullScreenContent:(id<GADFullScreenPresentingAd>)ad {
    NSLog(@"✅ Interstitial Ad Dismissed.");
    self.interstitialDismissed = YES;

    // Clear Current Ad Reference
    self.interstitialAd = nil;

    // Trigger C++ Callback
    if (interstitialAdClosedCallback != nullptr) {
        interstitialAdClosedCallback();
    }

    // Reload Interstitial Ad
    [AdMobBridge loadInterstitialAd];

    // Reset the Key Window and Ensure Focus (Updated Logic)
    UIWindow *mainWindow = [UIApplication sharedApplication].keyWindow;
    if (mainWindow) {
        NSLog(@"🔧 Resetting Main Application Window.");
        [mainWindow makeKeyAndVisible];  // Ensure the main window is visible and active

        // Resign any active first responder
        [mainWindow endEditing:YES];  // Ensure no text input fields are focused
    } else {
        NSLog(@"❌ Main Application Window Not Found.");
    }

    // Ensure focus is reset
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication].keyWindow endEditing:YES];
    });
}

#pragma mark - Hide Banner Ad
+ (void)hideBannerAd {
    AdMobBridge *bridge = [AdMobBridge sharedInstance];
    if (bridge.bannerView) {
        [bridge.bannerView removeFromSuperview];
        bridge.bannerView = nil;
        NSLog(@"✅ Banner Ad Hidden.");
    }
}

#pragma mark - Ad State Management
+ (BOOL)isInterstitialAdDismissed {
    return [AdMobBridge sharedInstance].interstitialDismissed;
}

+ (void)resetInterstitialDismissFlag {
    [AdMobBridge sharedInstance].interstitialDismissed = NO;
}

@end

// C++ Callable Functions
void AdMobManager::initializeAdMob() {
    [AdMobBridge initializeAdMob];
}

void AdMobManager::showBannerAd() {
    [AdMobBridge showBannerAd];
}

void AdMobManager::loadInterstitialAd() {
    [AdMobBridge loadInterstitialAd];
}

void AdMobManager::showInterstitialAd() {
    [AdMobBridge showInterstitialAd];
}

void AdMobManager::hideBannerAd() {
    [AdMobBridge hideBannerAd];
}

bool AdMobManager::isInterstitialAdDismissed() {
    return [AdMobBridge isInterstitialAdDismissed];
}

void AdMobManager::resetInterstitialDismissFlag() {
    [AdMobBridge resetInterstitialDismissFlag];
}

// Register C++ Callback
void AdMobManager::registerInterstitialAdClosedCallback(void (*callback)()) {
    interstitialAdClosedCallback = callback;
}
