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
    private let cellId: String = .uuid
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        contentView.layer.cornerCurve = .continuous
        contentView.backgroundColor = .systemBackground
        layer.shadowPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 8.0, height: 8.0)).cgPath
        layer.shadowColor = UIColor.black.withAlphaComponent(0.66).cgColor
        layer.shadowOpacity = 0.66
        layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
        layer.shadowRadius = 8
        layer.masksToBounds = false
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
    
    func configure(with publication: Substack.Publication) {
        imageView.setImageWith(url: publication.logoUrl)
        titleLabel.text = publication.name
        descriptionLabel.text = publication.description
        descriptionLabel.isHidden = publication.description == nil
    }

}
