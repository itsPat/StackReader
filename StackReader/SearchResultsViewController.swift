//
//  SearchResultsViewController.swift
//  StackReader
//
//  Created by Patrick Trudel on 2021-05-30.
//

import UIKit

class SearchResultsViewController: UICollectionViewController, TabBarControllerItem {
    
    var publications = [Substack.Publication]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .systemBackground
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        collectionView.register(
            PublicationCell.nib,
            forCellWithReuseIdentifier: PublicationCell.reuseId
        )
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

extension SearchResultsViewController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        publications.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PublicationCell.reuseId, for: indexPath) as! PublicationCell
        let publication = publications[indexPath.item]
        cell.configure(with: publication, didTapAdd: { collectionView.reloadData() })
        return cell
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension SearchResultsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let regularWidth = collectionView.bounds.inset(by: collectionView.contentInset).width
        let w = UIDevice.current.userInterfaceIdiom == .pad ? (regularWidth - 10) / 2.0 : regularWidth
        return CGSize(width: w, height: w)
    }
    
}

extension SearchResultsViewController {
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let publication = publications[indexPath.item]
        let nav = navigationController ?? presentingViewController?.navigationController
        nav?.pushViewController(.vc(.publicationDetail(publication: publication)), animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration? {
        let publication = publications[indexPath.item]
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
    
    override func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        guard let components = (configuration.identifier as? String)?.components(separatedBy: ","),
              let _ = Int(components.first ?? ""),
              let item = Int(components.last ?? "") else { return }
        let publication = publications[item]
        animator.addCompletion { [weak self] in
            let nav = self?.navigationController ?? self?.presentingViewController?.navigationController
            nav?.navigationController?.pushViewController(.vc(.publicationDetail(publication: publication)), animated: true)
        }
    }
    
}

extension SearchResultsViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        if let query = searchController.searchBar.text {
            NetworkManager.shared.searchPublications(query: query) { [weak self] res in
                switch res {
                case .success(let publications):
                    self?.publications = publications
                case .failure(let err):
                    self?.publications = []
                    print("\(#function) failed with err: \(err), query was: \(query)")
                }
                self?.reloadCollectionView()
            }
        }
    }
    
}
