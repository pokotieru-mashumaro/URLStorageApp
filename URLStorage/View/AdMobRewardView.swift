//
//  AdMobRewordView.swift
//  URLStorage
//
//  Created by iniad on 2023/03/23.
//

import SwiftUI
import UIKit // こちらも必要
import GoogleMobileAds // 忘れずに

class Reward: NSObject, ObservableObject ,GADFullScreenContentDelegate {
    // リワード広告を読み込んだかどうか
    @Published  var rewardLoaded: Bool = false
    // リワード広告が格納される
    var rewardedAd: GADRewardedAd? = nil

    func loadReward() {
        GADRewardedAd.load(withAdUnitID: "ca-app-pub-3940256099942544/1712485313", request: GADRequest(),completionHandler: { (ad, error) in
            if let _ = error {
                // 失敗
                // 処理を終了
                self.rewardLoaded = false
                return
            }
            // 成功
            // 読み込みフラグと広告を格納
            self.rewardLoaded = true
            self.rewardedAd = ad
            self.rewardedAd?.fullScreenContentDelegate = self
        })
    }
    
    func showReward() {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let rootVC = windowScene?.windows.first?.rootViewController
        if let ad = rewardedAd {
            ad.present(fromRootViewController: rootVC!, userDidEarnRewardHandler: {
                // 報酬を獲得
                self.rewardLoaded = false
            })
        } else {
            self.rewardLoaded = false
            self.loadReward()
        }
    }
    
    override init() {
        super.init()
    }
}
