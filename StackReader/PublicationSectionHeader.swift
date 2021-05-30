//
//  PublicationSectionHeader.swift
//  StackReader
//
//  Created by Patrick Trudel on 2021-05-30.
//

import UIKit

class PublicationSectionHeader: UICollectionReusableView {
    
    static let reuseId = "PublicationSectionHeader"
    static let nib = UINib(nibName: reuseId, bundle: .main)

    @IBOutlet weak var label: UILabel!
    
    func configure(with category: Substack.Category) {
        label.text = category.rawValue
    }
    
}
