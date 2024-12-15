#ifndef ADBRIDGE_H
#define ADBRIDGE_H

#include <QWidget>
#include <QPushButton>
#include <QVBoxLayout>
#include <QTimer>
#include <QDebug>

class AdBridge : public QWidget {
    Q_OBJECT

public:
    explicit AdBridge(QWidget *parent = nullptr);

private slots:
    void onAdClosed();
    void onShowBannerAdClicked();
    void onShowInterstitialAdClicked();
    void onHideBannerAdClicked();
    void checkInterstitialStatus();  // Timer check function

private:
    void setupBannerAd();
    void loadInterstitialAd();

    QPushButton *bannerAdButton;
    QPushButton *interstitialAdButton;
    QPushButton *hideBannerAdButton;
    QVBoxLayout *layout;

    QTimer *interstitialCheckTimer;  // Timer for polling
};

#endif  // ADBRIDGE_H
