//
//  AdMobInterstitialView.swift
//  URLStorage
//
//  Created by iniad on 2023/03/16.
//

import GoogleMobileAds

class Interstitial: NSObject, GADFullScreenContentDelegate, ObservableObject {
    @Published var interstitialAdLoaded: Bool = false
    var InterstitialAd: GADInterstitialAd?

    override init() {
        super.init()
    }

    // リワード広告の読み込み
    func LoadInterstitial() {
        GADInterstitialAd.load(withAdUnitID: "ca-app-pub-3940256099942544/4411468910", request: GADRequest()) { (ad, error) in
            if let _ = error {
                print("😭: 読み込みに失敗しました")
                self.interstitialAdLoaded = false
                return
            }
            print("😍: 読み込みに成功しました")
            self.interstitialAdLoaded = true
            self.InterstitialAd = ad
            self.InterstitialAd?.fullScreenContentDelegate = self
        }
    }

    // インタースティシャル広告の表示
    func ShowInterstitial() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let root = windowScene.windows.first?.rootViewController else {
            fatalError("Failed to retrieve window or root view controller")
        }
        if let ad = InterstitialAd {
            ad.present(fromRootViewController: root)
            self.interstitialAdLoaded = false
        } else {
            print("😭: 広告の準備ができていませんでした")
            self.interstitialAdLoaded = false
            self.LoadInterstitial()
        }
    }
    // 失敗通知
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("インタースティシャル広告の表示に失敗しました")
        self.interstitialAdLoaded = false
        self.LoadInterstitial()
    }

    // 表示通知
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("インタースティシャル広告を表示しました")
        self.interstitialAdLoaded = false
    }

    // クローズ通知
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("インタースティシャル広告を閉じました")
        self.interstitialAdLoaded = false
    }
}
