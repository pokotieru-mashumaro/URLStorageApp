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
//        "ca-app-pub-6121519581617103/8619861438"　本物
//        "ca-app-pub-3940256099942544/1712485313"　テスト
        GADRewardedAd.load(withAdUnitID: "ca-app-pub-6121519581617103/8619861438", request: GADRequest(),completionHandler: { (ad, error) in
            if let _ = error {
                // 失敗
                // 処理を終了
                self.rewardLoaded = false
                print("リワードロード失敗")
                return
            }
            // 成功
            // 読み込みフラグと広告を格納
            self.rewardLoaded = true
            self.rewardedAd = ad
            self.rewardedAd?.fullScreenContentDelegate = self
            print("リワードロード成功")

        })
    }
    
    func showReward() {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let rootVC = windowScene?.windows.first?.rootViewController
        if let ad = rewardedAd {
            print("リワードcm発動1")
            ad.present(fromRootViewController: rootVC!, userDidEarnRewardHandler: {
                // 報酬を獲得
                print("リワードcm発動2")
                self.rewardLoaded = false
            })
        } else {
            print("リワードcm失敗")
            self.rewardLoaded = false
            self.loadReward()
        }
    }
    
    override init() {
        super.init()
    }
}
