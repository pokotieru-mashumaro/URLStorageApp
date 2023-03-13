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

    /// しきい値
    static let threshold = 20
    
    /// 条件を満たしていれば、レビューリクエストを行う
    static func requestIfNeeded() {

        launchedCount += 1

        if launchedCount % threshold == 0 {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        }
    }
}
