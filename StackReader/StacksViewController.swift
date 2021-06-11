//
//  StacksViewController.swift
//  StackReader
//
//  Created by Patrick Trudel on 2021-06-02.
//

import UIKit

class StacksViewController: UIViewController, TabBarControllerItem {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var emptyStateView: UIStackView!
    
    private var publications: [Substack.Publication] {
        UserData.savedPublications
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView?.reloadData()
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { [weak self] _ in
            self?.collectionView?.collectionViewLayout.invalidateLayout()
        }
    }
    
    // MARK: - Methods
    
    private func setup() {
        collectionView?.clipsToBounds = false
        collectionView?.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        collectionView?.register(
            PublicationCell.nib,
            forCellWithReuseIdentifier: PublicationCell.reuseId
        )
    }
    
    func scrollToTop() {
        guard collectionView != nil else { return }
        collectionView?.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredVertically, animated: true)
    }

}

// MARK: - UICollectionViewDataSource

extension StacksViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = publications.count
        emptyStateView.isHidden = count > 0
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PublicationCell.reuseId, for: indexPath) as! PublicationCell
        let publication = publications[indexPath.item]
        cell.configure(with: publication, didTapAdd: { collectionView.reloadData() })
        return cell
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension StacksViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let regularWidth = collectionView.bounds.inset(by: collectionView.contentInset).width
        let w = UIDevice.current.userInterfaceIdiom == .pad ? (regularWidth - 10) / 2.0 : regularWidth
        return CGSize(width: w, height: w)
    }
    
}

extension StacksViewController: UICollectionViewDelegate {
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let publication = publications[indexPath.item]
        navigationController?.pushViewController(.vc(.publicationDetail(publication: publication)), animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration? {
        let publication = publications[indexPath.item]
        return UIContextMenuConfiguration(
            identifier: "\(indexPath.section),\(indexPath.item)" as NSString,
            previewProvider: { () -> UIViewController? in
                return .vc(.publicationDetail(publication: publication))
            },
            actionProvider: { _ -> UIMenu? in
                return UIMenu(title: "Quick Actions", children: [publication.saveAction {
                    collectionView.reloadData()
                }])
            }
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        guard let components = (configuration.identifier as? String)?.components(separatedBy: ","),
              let _ = Int(components.first ?? ""),
              let item = Int(components.last ?? "") else { return }
        let publication = publications[item]
        animator.addCompletion { [weak self] in
            self?.navigationController?.pushViewController(.vc(.publicationDetail(publication: publication)), animated: true)
        }
    }
    
}

