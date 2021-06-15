//
//  AdFooterView.swift
//  StackReader
//
//  Created by Patrick Trudel on 2021-06-15.
//

import UIKit
import GoogleMobileAds

class AdFooterView: UICollectionReusableView {
    
    static let reuseId = "AdFooterView"
    static let nib = UINib(nibName: reuseId, bundle: .main)

    @IBOutlet weak var mediaView: GADMediaView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var adBadge: UILabel!
    @IBOutlet weak var advertiserLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var ctaButton: UIButton!
    
    let adView = GADNativeAdView(frame: .zero)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupAdView()
        ctaButton.layer.cornerRadius = 4
        ctaButton.layer.cornerCurve = .continuous
        ctaButton.layer.masksToBounds = true
        adBadge.layer.cornerRadius = 4
        adBadge.layer.cornerCurve = .continuous
        adBadge.layer.masksToBounds = true
    }
    
    func setupAdView() {
        adView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(adView)
        NSLayoutConstraint.activate([
            adView.topAnchor.constraint(equalTo: topAnchor),
            adView.bottomAnchor.constraint(equalTo: bottomAnchor),
            adView.leftAnchor.constraint(equalTo: leftAnchor),
            adView.rightAnchor.constraint(equalTo: rightAnchor),
        ])
    }
    
    func configure(with ad: GADNativeAd) {
        ad.delegate = AdManager.shared
        
        iconImageView.image = ad.icon?.image
        iconImageView.isHidden = ad.icon?.image == nil
        
        headlineLabel.text = ad.headline
        headlineLabel.isHidden = ad.headline == nil
        
        let advertiser = ad.store ?? ad.advertiser
        advertiserLabel.text = advertiser
        advertiserLabel.isHidden = advertiser == nil
        
        bodyLabel.text = ad.body ?? String(repeating: "★", count: ad.starRating?.intValue ?? 0)
        bodyLabel.isHidden = ad.body == nil

        ctaButton.setTitle(ad.callToAction, for: .normal)
        ctaButton.isHidden = ad.callToAction == nil
        // In order for the SDK to process touch events properly, user interaction should be disabled.
        ctaButton.isUserInteractionEnabled = false
        
        mediaView.mediaContent = ad.mediaContent
    }
    
}
