#ifndef ADMOBMANAGER_H
#define ADMOBMANAGER_H

class AdMobManager {
public:
    static void initializeAdMob();
    static void showBannerAd();
    static void showInterstitialAd();
    static void loadInterstitialAd();
    static void hideBannerAd();
    
    // Interstitial Ad State Checkers
    static bool isInterstitialAdDismissed();
    static void resetInterstitialDismissFlag();
    
    // Callback Registration
    static void registerInterstitialAdClosedCallback(void (*callback)());
};

#endif  // ADMOBMANAGER_H
