//
//  AdManager.swift
//  StackReader
//
//  Created by Patrick Trudel on 2021-06-15.
//

import Foundation
import UIKit
import GoogleMobileAds

protocol AdManagerDelegate: AnyObject {
    func didReceiveNativeAds()
}

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
    
    static let adFrequency = 6
    private var adLoader: GADAdLoader?
    private var appOpenAd: GADAppOpenAd?
    private var nativeAdQueue = [GADUnifiedNativeAd]()
    
    weak var delegate: AdManagerDelegate?
    
    var adQueueIsEmpty: Bool {
        nativeAdQueue.isEmpty
    }
    
    var nextNativeAd: GADUnifiedNativeAd? {
        guard !adQueueIsEmpty else { return nil }
        let first = nativeAdQueue.removeFirst()
        nativeAdQueue.append(first)
        return first
    }
    
    var nextNativeAdView: GADUnifiedNativeAdView? {
        guard let adView = UINib(nibName: "NativeAdView", bundle: .main)
                .instantiate(withOwner: nil, options: [:])[0] as? GADUnifiedNativeAdView,
              let ad = nextNativeAd else { return nil }
        ad.delegate = self
        (adView.headlineView as? UILabel)?.text = ad.headline
        adView.mediaView?.mediaContent = ad.mediaContent
        
        (adView.bodyView as? UILabel)?.text = ad.body
        adView.bodyView?.isHidden = ad.body == nil

        (adView.callToActionView as? UIButton)?.setTitle(ad.callToAction, for: .normal)
        adView.callToActionView?.isHidden = ad.callToAction == nil

        (adView.iconView as? UIImageView)?.image = ad.icon?.image
        adView.iconView?.isHidden = ad.icon == nil

        (adView.starRatingView as? UIImageView)?.image = UIImage()
        adView.starRatingView?.isHidden = ad.starRating == nil

        (adView.storeView as? UILabel)?.text = ad.store
        adView.storeView?.isHidden = ad.store == nil

        (adView.priceView as? UILabel)?.text = ad.price
        adView.priceView?.isHidden = ad.price == nil

        (adView.advertiserView as? UILabel)?.text = ad.advertiser
        adView.advertiserView?.isHidden = ad.advertiser == nil

        // In order for the SDK to process touch events properly, user interaction should be disabled.
        adView.callToActionView?.isUserInteractionEnabled = false
        adView.nativeAd = ad
        return adView
    }
    
    // MARK: - Methods
    
    func fetchAds(with rootVC: UIViewController) {
        let multipleAdsOption = GADMultipleAdsAdLoaderOptions()
        multipleAdsOption.numberOfAds = 4
        adLoader = GADAdLoader(
            adUnitID: nativeAdUnitId,
            rootViewController: rootVC,
            adTypes: [.unifiedNative],
            options: [multipleAdsOption]
        )
        adLoader?.delegate = self
        adLoader?.load(GADRequest())
    }
    
    func setupAppOpenAd() {
        GADAppOpenAd.load(
            withAdUnitID: AdManager.shared.appOpenAdUnitId,
            request: GADRequest(),
            orientation: .portrait
        ) { [weak self] ad, err in
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
    
    func userDeniedATTPermission() {
        GADMobileAds.sharedInstance().disableSDKCrashReporting()
    }
    
}

// MARK: - GADNativeAdLoaderDelegate

extension AdManager: GADAdLoaderDelegate, GADUnifiedNativeAdLoaderDelegate {
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADUnifiedNativeAd) {
        nativeAdQueue.append(nativeAd)
        guard nativeAdQueue.count == 1 else { return }
        delegate?.didReceiveNativeAds()
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
        print("❌ \(#function) failed with error: \(error)")
    }
    
}

// MARK: - GADNativeAdDelegate

extension AdManager: GADUnifiedNativeAdDelegate {
    
    func nativeAdDidRecordImpression(_ nativeAd: GADUnifiedNativeAd) {
        print("⭐️ \(#function)")
    }
    
    func nativeAdDidRecordClick(_ nativeAd: GADUnifiedNativeAd) {
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
