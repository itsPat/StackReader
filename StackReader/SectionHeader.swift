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
    
    var cellId: String = .uuid
    
    override func awakeFromNib() {
        super.awakeFromNib()
        actionButton.layer.cornerRadius = 16
        actionButton.layer.masksToBounds = true
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
        imageView.layer.borderColor = UIColor.systemGray6.cgColor
    }
    
    func removeBorder() {
        backgroundColor = .clear
        imageView.layer.borderWidth = 0.0
    }
    
    func configure(with category: Substack.Category, menu: UIMenu? = nil) {
        label.text = category.title
        imageView.image = category.icon
        actionButton.isHidden = menu == nil
        actionButton.showsMenuAsPrimaryAction = menu != nil
        actionButton.menu = menu
        removeBorder()
        layoutIfNeeded()
    }
    
    func configure(with publication: Substack.Publication, menu: UIMenu? = nil) {
        label.text = publication.name
        imageView.setImageWith(url: publication.logoUrl ?? publication.authorPhotoUrl, cellId: cellId)
        actionButton.isHidden = false
        actionButton.showsMenuAsPrimaryAction = menu != nil
        actionButton.menu = menu
        setupBorder()
        layoutIfNeeded()
    }
    
}
