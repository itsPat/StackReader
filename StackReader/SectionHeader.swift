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
    @IBOutlet weak var chevronBackgroundView: UIView!
    @IBOutlet weak var chevronImageView: UIImageView!
    @IBOutlet weak var actionButton: UIButton!
    
    private var cellId: String = .uuid
    private var actionIdentifiers: [UIAction.Identifier] = []
    
    // MARK: - Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        chevronBackgroundView.layer.cornerRadius = 12
        chevronBackgroundView.layer.masksToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        actionIdentifiers.forEach {
            actionButton.removeAction(identifiedBy: $0, for: .touchUpInside)
        }
        actionIdentifiers = []
        NetworkManager.shared.cancel(taskWithId: cellId)
        imageView.image = nil
    }
    
    // MARK: - Private Methods
    
    private func setupBorder() {
        backgroundColor = .systemBackground
        imageView.layer.cornerRadius = 8.0
        imageView.layer.cornerCurve = .continuous
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 0.5
        imageView.layer.borderColor = UIColor.systemGray6.cgColor
    }
    
    private func removeBorder() {
        backgroundColor = .clear
        imageView.layer.borderWidth = 0.0
    }
    
    private func setupActionButton(title: String, actions: [UIAction]) {
        if actions.count > 1 {
            actionButton.menu = UIMenu(children: actions)
            actionButton.showsMenuAsPrimaryAction = true
            chevronImageView.image = UIImage(
                systemName: "ellipsis",
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .light)
            )
            actionButton.isHidden = false
        } else if let action = actions.first {
            actionIdentifiers.append(action.identifier)
            actionButton.menu = nil
            actionButton.showsMenuAsPrimaryAction = false
            chevronImageView.image = UIImage(
                systemName: "chevron.right",
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .light)
            )
            actionButton.addAction(action, for: .touchUpInside)
            actionButton.isHidden = false
        } else {
            actionButton.isHidden = true
        }
    }
    
    // MARK: - Public Methods
    
    func configure(with category: Substack.Category, actions: [UIAction]) {
        label.text = category.title
        imageView.isHidden = true
        setupActionButton(title: category.title, actions: actions)
        removeBorder()
        layoutIfNeeded()
    }
    
    func configure(with publication: Substack.Publication, actions: [UIAction]) {
        label.text = publication.name
        imageView.setImageWith(url: publication.logoUrl ?? publication.authorPhotoUrl, cellId: cellId)
        imageView.isHidden = false
        setupActionButton(title: publication.name, actions: actions)
        setupBorder()
        layoutIfNeeded()
    }
    
}
