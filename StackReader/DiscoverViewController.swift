//
//  DiscoverViewController.swift
//  StackReader
//
//  Created by Patrick Trudel on 2021-05-30.
//

import UIKit

class DiscoverViewController: UIViewController, TabBarControllerItem {

    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var publicationsByCategory = [Substack.Category: [Substack.Publication]]() {
        didSet {
            self.categories = publicationsByCategory.keys.sorted(by: { $0.rawValue < $1.rawValue })
        }
    }
    var categories = [Substack.Category]()
    
    lazy var searchController: UISearchController = {
        UISearchController(
            searchResultsController: SearchResultsViewController(
                collectionViewLayout: UICollectionViewFlowLayout()
            )
        )
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = searchController.searchResultsController as? UISearchResultsUpdating
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10)
        collectionView.register(
            PublicationSectionHeader.nib,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: PublicationSectionHeader.reuseId
        )
        collectionView.register(
            PublicationCell.nib,
            forCellWithReuseIdentifier: PublicationCell.reuseId
        )
        NetworkManager.shared.fetchDiscoverPageData { [weak self] res in
            switch res {
            case .success(let data):
                self?.publicationsByCategory = data
                self?.reloadCollectionView()
            case .failure(let err):
                print("Failed with err: \(err)")
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { [weak self] _ in
            self?.collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    func reloadCollectionView() {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
        }
    }
    
    func scrollToTop() {
        guard collectionView != nil else { return }
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredVertically, animated: true)
    }

}

// MARK: - UICollectionViewDataSource

extension DiscoverViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        publicationsByCategory[categories[section]]?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PublicationCell.reuseId, for: indexPath) as! PublicationCell
        if let publication = publicationsByCategory[categories[indexPath.section]]?[indexPath.item] {
            cell.configure(with: publication, didTapAdd: { collectionView.reloadData() })
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: PublicationSectionHeader.reuseId, for: indexPath) as! PublicationSectionHeader
        header.configure(with: categories[indexPath.section])
        return header
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension DiscoverViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let regularWidth = collectionView.bounds.inset(by: collectionView.contentInset).width
        let w = UIDevice.current.userInterfaceIdiom == .pad ? (regularWidth - 10) / 2.0 : regularWidth
        return CGSize(width: w, height: w)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let w = collectionView.bounds.inset(by: collectionView.contentInset).width
        return CGSize(width: w, height: 70)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        .zero
    }
    
}

extension DiscoverViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let publication = publicationsByCategory[categories[indexPath.section]]?[indexPath.item] {
            navigationController?.pushViewController(.vc(.publicationDetail(publication: publication)), animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration? {
        guard let publication = publicationsByCategory[categories[indexPath.section]]?[indexPath.item] else {
            return nil
        }
        return UIContextMenuConfiguration(
            identifier: "\(indexPath.section),\(indexPath.item)" as NSString,
            previewProvider: { () -> UIViewController? in
                return .vc(.publicationDetail(publication: publication))
            },
            actionProvider: { _ -> UIMenu? in
                return UIMenu(title: "Quick Actions", children: [publication.saveAction()])
            }
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        guard let components = (configuration.identifier as? String)?.components(separatedBy: ","),
              let section = Int(components.first ?? ""),
              let item = Int(components.last ?? ""),
              let publication = publicationsByCategory[categories[section]]?[item] else { return }
        animator.addCompletion { [weak self] in
            self?.navigationController?.pushViewController(.vc(.publicationDetail(publication: publication)), animated: true)
        }
    }
    
}
