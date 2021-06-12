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
    var cellId: String = .uuid
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        NetworkManager.shared.cancel(taskWithId: cellId)
        imageView.image = nil
    }
    
    func setupBorder() {
        backgroundColor = .systemBackground
        imageView.layer.cornerRadius = 8.0
        imageView.layer.cornerCurve = .continuous
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 0.5
        imageView.layer.borderColor = UIColor.opaqueSeparator.cgColor
    }
    
    func removeBorder() {
        backgroundColor = .clear
        imageView.layer.borderWidth = 0.0
    }
    
    func configure(with category: Substack.Category, didTapActionButton: (() -> Void)? = nil) {
        self.didTapActionButton = didTapActionButton
        label.text = category.title
        imageView.image = category.icon
        actionButton.isHidden = true
        removeBorder()
        layoutIfNeeded()
    }
    
    func configure(with publication: Substack.Publication, didTapActionButton: (() -> Void)? = nil) {
        self.didTapActionButton = didTapActionButton
        label.text = publication.name
        imageView.setImageWith(url: publication.logoUrl ?? publication.authorPhotoUrl, cellId: cellId)
        actionButton.isHidden = false
        setupBorder()
        layoutIfNeeded()
    }
    
    @IBAction func didTapActionButton(_ sender: Any) {
        didTapActionButton?()
    }
    
}
