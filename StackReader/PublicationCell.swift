//
//  PublicationCell.swift
//  StackReader
//
//  Created by Patrick Trudel on 2021-05-30.
//

import UIKit

class PublicationCell: UICollectionViewCell {
    
    static let reuseId = "PublicationCell"
    static let nib = UINib(nibName: reuseId, bundle: .main)
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var addToStacksButton: UIButton!
    
    private let cellId: String = .uuid
    private var didTapAdd: (() -> ())?
    private var publication: Substack.Publication?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        contentView.layer.cornerCurve = .continuous
        contentView.backgroundColor = .systemBackground
        contentView.layer.borderWidth = 0.5
        contentView.layer.borderColor = UIColor.separator.cgColor
        layer.shadowColor = UIColor.black.withAlphaComponent(0.5).cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        layer.shadowRadius = 4
        layer.masksToBounds = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: .allCorners,
            cornerRadii: CGSize(width: 8.0, height: 8.0)
        ).cgPath
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        titleLabel.text = nil
        descriptionLabel.text = nil
        NetworkManager.shared.tasks[cellId]?.cancel()
        NetworkManager.shared.tasks[cellId] = nil
        publication = nil
    }
    
    func configure(with publication: Substack.Publication, didTapAdd: @escaping () -> ()) {
        self.publication = publication
        self.didTapAdd = didTapAdd
        imageView.setImageWith(url: publication.logoUrl ?? publication.authorPhotoUrl, cellId: cellId)
        titleLabel.text = publication.name
        descriptionLabel.text = publication.description
        descriptionLabel.isHidden = publication.description == nil
        updateAddToStacksButton()
    }

    @IBAction func didTapAdd(_ sender: Any) {
        publication?.toggleIsSaved()
        didTapAdd?()
        updateAddToStacksButton()
    }
    
    func updateAddToStacksButton() {
        guard let pub = publication else { return }
        addToStacksButton.setImage(pub.saveActionImage, for: .normal)
    }
    
}
