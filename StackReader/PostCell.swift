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
    @IBOutlet weak var paidOnlyImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var savePostButton: UIButton!
    
    private let cellId: String = .uuid
    private var didTapSave: (() -> ())?
    private var post: Substack.Post?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = .systemBackground
        imageView.layer.cornerRadius = 8.0
        imageView.layer.cornerCurve = .continuous
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 0.25
        imageView.layer.borderColor = UIColor.systemGray6.cgColor
        paidOnlyImageView.layer.shadowPath = UIBezierPath(
            roundedRect: paidOnlyImageView.bounds,
            byRoundingCorners: .allCorners,
            cornerRadii: .init(width: 10.0, height: 10.0)
        ).cgPath
        paidOnlyImageView.layer.shadowColor = UIColor.black.cgColor
        paidOnlyImageView.layer.shadowOpacity = 0.15
        paidOnlyImageView.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        paidOnlyImageView.layer.shadowRadius = 2.0
        paidOnlyImageView.layer.masksToBounds = false
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        titleLabel.text = nil
        NetworkManager.shared.cancel(taskWithId: cellId)
        post = nil
    }
    
    func configure(with post: Substack.Post, didTapSave: @escaping () -> () = {}) {
        self.post = post
        self.didTapSave = didTapSave
        imageView.setImageWith(url: post.coverImageUrl ?? post.publication?.logoUrl ?? post.publication?.authorPhotoUrl, cellId: cellId)
        titleLabel.text = post.title
        dateLabel.text = post.relativePostDate?.localizedCapitalized
        dateLabel.isHidden = post.relativePostDate == nil
        paidOnlyImageView.isHidden = !post.isPaidOnly
        updateSavePostButton()
        layoutIfNeeded()
    }

    @IBAction private func didTapSave(_ sender: UIButton) {
        sender.pulse { [weak self] in
            self?.post?.toggleIsSaved()
            self?.didTapSave?()
            self?.updateSavePostButton()
        }
    }
    
    private func updateSavePostButton() {
        guard let post = self.post else { return }
        savePostButton.setImage(post.saveActionImage, for: .normal)
        savePostButton.tintColor = post.isSaved ? .stackBlue : .opaqueSeparator
    }

}
