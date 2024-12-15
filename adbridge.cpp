#include "adbridge.h"
#include "AdMobManager.h"
#include <QCoreApplication>
#include <QMessageBox>

AdBridge::AdBridge(QWidget *parent) : QWidget(parent) {
    // Initialize AdMob SDK
    AdMobManager::initializeAdMob();
    AdMobManager::loadInterstitialAd();

    // Create Timer
    interstitialCheckTimer = new QTimer(this);
    connect(interstitialCheckTimer, &QTimer::timeout, this, &AdBridge::checkInterstitialStatus);

    // Create UI Elements
    bannerAdButton = new QPushButton("Show Banner Ad", this);
    interstitialAdButton = new QPushButton("Show Interstitial Ad", this);
    hideBannerAdButton = new QPushButton("Hide Banner Ad", this);

    // Connect Buttons to Slots
    connect(bannerAdButton, &QPushButton::clicked, this, &AdBridge::onShowBannerAdClicked);
    connect(interstitialAdButton, &QPushButton::clicked, this, &AdBridge::onShowInterstitialAdClicked);
    connect(hideBannerAdButton, &QPushButton::clicked, this, &AdBridge::onHideBannerAdClicked);

    // Setup UI Layout
    layout = new QVBoxLayout(this);
    layout->setSpacing(17);
    layout->setContentsMargins(17, 17, 17, 17);
    layout->addWidget(bannerAdButton);
    layout->addWidget(hideBannerAdButton);
    layout->addWidget(interstitialAdButton);
    setLayout(layout);
}

void AdBridge::onAdClosed() {
    qDebug() << "✅ Interstitial Ad Closed (Signal Received).";

    // Reset Ad State
    AdMobManager::resetInterstitialDismissFlag();

    // Show a Popup
    QMessageBox::information(
        this,
        tr("Ad Closed"),
        tr("The interstitial ad has been closed successfully."),
        QMessageBox::Ok
    );

    // Force Update UI
    repaint();  // Ensure the widget updates its appearance
    update();   // Trigger UI refresh if necessary

    // Optionally, focus the widget
    setFocus(Qt::ActiveWindowFocusReason);
}

void AdBridge::onShowBannerAdClicked() {
    AdMobManager::showBannerAd();
}

void AdBridge::onShowInterstitialAdClicked() {
    AdMobManager::showInterstitialAd();
    interstitialCheckTimer->start(500);  // Start checking every 500ms
}

void AdBridge::onHideBannerAdClicked() {
    AdMobManager::hideBannerAd();
}

void AdBridge::checkInterstitialStatus() {
    if (AdMobManager::isInterstitialAdDismissed()) {
        qDebug() << "✅ Interstitial Ad Dismissed (Polled by Timer).";
        interstitialCheckTimer->stop();
        onAdClosed();  // Handle the close event
    }
}

void AdBridge::setupBannerAd() {
    qDebug() << "🔧 Setting up Banner Ad.";
}

void AdBridge::loadInterstitialAd() {
    qDebug() << "🔧 Loading Interstitial Ad.";
}
