//
//  PostCell.swift
//  StackReader
//
//  Created by Patrick Trudel on 2021-05-30.
//

import UIKit

class PostCell: UICollectionViewCell {
    
    static let reuseId = "PostCell"
    static let nib = UINib(nibName: reuseId, bundle: .main)
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    private let cellId: String = .uuid
    private var didTapSave: (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = .systemBackground
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.separator.cgColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 8.0, height: 8.0)).cgPath
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        titleLabel.text = nil
        descriptionLabel.text = nil
        NetworkManager.shared.tasks[cellId]?.cancel()
        NetworkManager.shared.tasks[cellId] = nil
    }
    
    func configure(with post: Substack.Post, didTapSave: @escaping () -> ()) {
        imageView.setImageWith(url: post.coverImageUrl ?? post.publication?.logoUrl ?? post.publication?.authorPhotoUrl)
        titleLabel.text = post.title
        descriptionLabel.text = post.subtitle
        self.didTapSave = didTapSave
    }

    @IBAction func didTapSave(_ sender: Any) {
        didTapSave?()
    }

}
