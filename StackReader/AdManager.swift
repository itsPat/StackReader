//
//  AdManager.swift
//  StackReader
//
//  Created by Patrick Trudel on 2021-06-15.
//

import Foundation
import UIKit
import GoogleMobileAds
import AppTrackingTransparency

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
        if nativeAdQueue.count < 2 {
            fetchMoreNativeAds()
        }
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
        (adView.callToActionView as? UIButton)?.layer.borderWidth = 1
        (adView.callToActionView as? UIButton)?.layer.borderColor = UIColor(
            red: 0,
            green: 150/255,
            blue: 255/255,
            alpha: 0.66
        ).cgColor
        
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
    
    var nextThinNativeAdView: GADUnifiedNativeAdView? {
        guard let adView = UINib(nibName: "ThinNativeAdView", bundle: .main)
                .instantiate(withOwner: nil, options: [:])[0] as? GADUnifiedNativeAdView,
              let ad = nextNativeAd else { return nil }
        ad.delegate = self
        (adView.headlineView as? UILabel)?.text = ad.headline
        adView.mediaView?.mediaContent = ad.mediaContent
        
        (adView.bodyView as? UILabel)?.text = ad.body
        adView.bodyView?.isHidden = ad.body == nil

        (adView.callToActionView as? UIButton)?.setTitle(ad.callToAction, for: .normal)
        (adView.callToActionView as? UIButton)?.layer.borderWidth = 1
        (adView.callToActionView as? UIButton)?.layer.borderColor = UIColor(
            red: 0,
            green: 150/255,
            blue: 255/255,
            alpha: 0.66
        ).cgColor
        
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
        requestIDFAPermission { [weak self] in
            let multipleAdsOption = GADMultipleAdsAdLoaderOptions()
            multipleAdsOption.numberOfAds = 4
            self?.adLoader = GADAdLoader(
                adUnitID: self?.nativeAdUnitId ?? "",
                rootViewController: rootVC,
                adTypes: [.unifiedNative],
                options: [multipleAdsOption]
            )
            self?.adLoader?.delegate = self
            self?.adLoader?.load(GADRequest())
        }
    }
    
    func fetchMoreNativeAds(count: Int = 4) {
        adLoader?.load(GADRequest())
    }
    
    private func requestIDFAPermission(completion: @escaping () -> ()) {
        ATTrackingManager.requestTrackingAuthorization { status in
            print("ATTrackingManager.AuthorizationStatus is: \(status)")
            completion()
        }
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
