//
//  AdManager.swift
//  StackReader
//
//  Created by Patrick Trudel on 2021-06-15.
//

import Foundation
import UIKit
import GoogleMobileAds

class AdManager: NSObject {
    
    static let shared = AdManager()
    private override init() {}
    
    // MARK: - Identifiers
    
    private let admobAppId = "ca-app-pub-5610582410461852~1485004036"
    private var nativeAdUnitId: String {
        #if DEBUG
        "ca-app-pub-3940256099942544/3986624511"
        #else
        "ca-app-pub-5610582410461852/5396328881"
        #endif
    }
    private var appOpenAdUnitId: String {
        #if DEBUG
        "ca-app-pub-3940256099942544/5662855259"
        #else
        "ca-app-pub-5610582410461852/7639348847"
        #endif
    }
    
    // MARK: - Properties
    
    private var adLoader: GADAdLoader?
    private var appOpenAd: GADAppOpenAd?
    private var nativeAdQueue = [GADNativeAd]()
    
    private var nextNativeAd: GADNativeAd? {
        guard !nativeAdQueue.isEmpty else { return nil }
        let first = nativeAdQueue.removeFirst()
        nativeAdQueue.append(first)
        return first
    }
    
    // MARK: - Methods
    
    func setupAdLoader(rootVC: UIViewController) {
        let multipleAdsOption = GADMultipleAdsAdLoaderOptions()
        multipleAdsOption.numberOfAds = 4
        adLoader = GADAdLoader(
            adUnitID: admobAppId,
            rootViewController: rootVC,
            adTypes: [.native],
            options: [multipleAdsOption]
        )
        adLoader?.load(GADRequest())
    }
    
    func setupAppOpenAd() {
        GADAppOpenAd.load(
            withAdUnitID: AdManager.shared.appOpenAdUnitId,
            request: GADRequest(),
            orientation: .portrait) { [weak self] ad, err in
            if let err = err {
                print("\(#function) failed with error: \(err)")
            } else {
                self?.appOpenAd = ad
                ad?.fullScreenContentDelegate = self
            }
        }
    }
    
    func presentAppOpenAd(from vc: UIViewController) {
        if let ad = appOpenAd {
            ad.present(fromRootViewController: vc)
        } else {
            setupAppOpenAd()
        }
    }
    
}

// MARK: - GADNativeAdLoaderDelegate

extension AdManager: GADNativeAdLoaderDelegate {
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        nativeAd.delegate = self
        print("⭐️ Did get native ad")
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        print("❌ Failed to get native ad")
    }
    
}

// MARK: - GADNativeAdDelegate

extension AdManager: GADNativeAdDelegate {
    
    func nativeAdDidRecordImpression(_ nativeAd: GADNativeAd) {
        print("⭐️ \(#function)")
    }
    
    func nativeAdDidRecordClick(_ nativeAd: GADNativeAd) {
        print("⭐️ \(#function)")
    }
    
}

// MARK: - GADFullScreenContentDelegate

extension AdManager: GADFullScreenContentDelegate {
    
    func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("⭐️ \(#function)")
    }
    
    func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        print("⭐️ \(#function)")
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("⭐️ \(#function)")
    }
    
}
