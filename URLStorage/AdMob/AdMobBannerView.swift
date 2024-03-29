//
//  AddMobBannerView.swift
//  URLStorage
//
//  Created by iniad on 2023/03/16.
//

import UIKit
import SwiftUI
import GoogleMobileAds

struct BannerView: UIViewRepresentable {
    let viewController: UIViewController
    let windowScene: UIWindowScene?
    
    func makeCoordinator() -> Coordinator {
        .init()
    }
    
    func makeUIView(context: Context) -> GADBannerView {
        let bannerView = GADBannerView()
        bannerView.delegate = context.coordinator
        bannerView.rootViewController = viewController
//        bannerView.adUnitID = "ca-app-pub-6121519581617103/6190426642"
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716" //testmode
        let request = GADRequest()
        request.scene = windowScene
        bannerView.load(request)
        return bannerView
    }
    
    func updateUIView(_ bannerView: GADBannerView, context: Context) {
    }
    
    class Coordinator: NSObject, GADBannerViewDelegate {
        func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        }
    }
}
