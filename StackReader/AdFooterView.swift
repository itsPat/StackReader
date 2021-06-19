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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.borderWidth = 0.25
        layer.borderColor = UIColor.opaqueSeparator.cgColor
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        clearSubviews()
    }
    
    func clearSubviews() {
        subviews.forEach { $0.removeFromSuperview() }
    }
    
    func configure() {
        if let adView = AdManager.shared.nextNativeAdView {
            adView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(adView)
            NSLayoutConstraint.activate([
                adView.topAnchor.constraint(equalTo: topAnchor),
                adView.bottomAnchor.constraint(equalTo: bottomAnchor),
                adView.leftAnchor.constraint(equalTo: leftAnchor),
                adView.rightAnchor.constraint(equalTo: rightAnchor),
            ])
        }
    }
    
}
