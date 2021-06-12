//
//  SectionHeader.swift
//  StackReader
//
//  Created by Patrick Trudel on 2021-05-30.
//

import UIKit

class SectionHeader: UICollectionReusableView {
    
    static let reuseId = "SectionHeader"
    static let nib = UINib(nibName: reuseId, bundle: .main)

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    
    var didTapActionButton: (() -> Void)?
    
    func configure(with category: Substack.Category, didTapActionButton: (() -> Void)? = nil) {
        self.didTapActionButton = didTapActionButton
        label.text = category.title
        imageView.image = category.icon
    }
    
    @IBAction func didTapActionButton(_ sender: Any) {
        didTapActionButton?()
    }
    
}
