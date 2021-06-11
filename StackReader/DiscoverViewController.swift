//
//  DiscoverViewController.swift
//  StackReader
//
//  Created by Patrick Trudel on 2021-05-30.
//

import UIKit

class DiscoverViewController: UIViewController, TabBarControllerItem {

    @IBOutlet weak var collectionView: UICollectionView!
    
    private var publicationsByCategory = [Substack.Category: [Substack.Publication]]() {
        didSet {
            self.categories = publicationsByCategory.keys.sorted(by: { $0.rawValue < $1.rawValue })
        }
    }
    private var categories = [Substack.Category]()
    private var taskByPublicationId = [Int: String]()
    
    lazy private var searchController: UISearchController = {
        let resultsVC = SearchResultsViewController(collectionViewLayout: UICollectionViewFlowLayout())
        let searchVC = UISearchController(searchResultsController: resultsVC)
        searchVC.searchBar.delegate = resultsVC
        return searchVC
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadCollectionView()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { [weak self] _ in
            self?.setupCollectionViewLayout()
        }
    }
    
    private func setup() {
        navigationItem.searchController = searchController
        setupCollectionViewLayout()
        collectionView.register(
            PublicationSectionHeader.nib,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: PublicationSectionHeader.reuseId
        )
        collectionView.register(
            PublicationCell.nib,
            forCellWithReuseIdentifier: PublicationCell.reuseId
        )
        refresh()
        collectionView.refreshControl = UIRefreshControl(
            frame: .zero,
            primaryAction: UIAction { [weak self] _ in
                self?.refresh()
        })
    }
    
    func setupCollectionViewLayout() {
        collectionView.setCollectionViewLayout(
            .orthogonalLayout(
                itemInset: .init(top: 2.0, leading: 2.0, bottom: 2.0, trailing: 2.0),
                sectionInset: .init(top: 8.0, leading: 16.0, bottom: 16.0, trailing: 32.0)
            ),
            animated: true
        )
    }
    
    @objc
    private func refresh() {
        collectionView.refreshControl?.beginRefreshing()
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
    
    private func reloadCollectionView() {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.refreshControl?.endRefreshing()
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

// MARK: - UICollectionViewDataSourcePrefetching

extension DiscoverViewController: UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for index in indexPaths {
            if let publication = publicationsByCategory[categories[index.section]]?[index.item] {
                ImageManager.shared.getImage(with: publication.logoUrl ?? "", taskId: "\(publication.id)")
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        for index in indexPaths {
            if let publication = publicationsByCategory[categories[index.section]]?[index.item] {
                NetworkManager.shared.cancel(taskWithId: "\(publication.id)")
            }
        }
    }
    
}


// MARK: - UICollectionViewDelegate

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
