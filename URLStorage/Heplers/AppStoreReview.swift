//
//  AppStoreReview.swift
//  URLStorage
//
//  Created by iniad on 2023/03/13.
//

import SwiftUI
import StoreKit

class AppStoreReview {
    /// 起動回数のUserDefaults
    @AppStorage("launchedCount") static var launchedCount = 0
    @AppStorage("firstLaunchedCount") static var firstLaunchedCount = 0

    /// しきい値
    static let threshold = 70
    
    /// 条件を満たしていれば、レビューリクエストを行う
    static func requestIfNeeded() {

        firstLaunchedCount += 2
        launchedCount += 1
        
        if firstLaunchedCount == 2 {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        }

        if launchedCount % threshold == 0 {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        }
    }
}
