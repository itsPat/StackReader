//
//  DiscoverViewController.swift
//  StackReader
//
//  Created by Patrick Trudel on 2021-05-30.
//

import UIKit

class DiscoverViewController: UIViewController, TabBarControllerItem {
    
    // MARK: - Outlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Properties
    
    private var publicationsByCategory = [Substack.Category: [Substack.Publication]]() {
        didSet {
            self.categories = publicationsByCategory.keys.sorted(by: { $0.rawValue < $1.rawValue })
        }
    }
    private var categories = [Substack.Category]()
    private var taskByPublicationId = [Int: String]()
    
    // MARK: - Computed Properties
    
    lazy private var searchController: UISearchController = {
        let resultsVC = SearchResultsViewController(collectionViewLayout: UICollectionViewFlowLayout())
        let searchVC = UISearchController(searchResultsController: resultsVC)
        searchVC.searchBar.delegate = resultsVC
        return searchVC
    }()
    
    lazy var dataSource: UICollectionViewDiffableDataSource<Substack.Category, Substack.Publication> = {
        let dataSource = UICollectionViewDiffableDataSource<Substack.Category, Substack.Publication>(
            collectionView: collectionView,
            cellProvider: { collectionView, indexPath, publication in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PublicationCell.reuseId, for: indexPath) as! PublicationCell
                cell.configure(with: publication, didTapAdd: { collectionView.reloadData() })
                return cell
            }
        )
        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, index in
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: PublicationSectionHeader.reuseId, for: index) as! PublicationSectionHeader
            header.configure(with: Substack.Category.allCases[index.section])
            return header
        }
        return dataSource
    }()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { [weak self] _ in
            self?.setupCollectionViewLayout()
        }
    }
    
    // MARK: - Methods
    
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
        collectionView.dataSource = dataSource
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
        dataSource.apply(NSDiffableDataSourceSnapshot<Substack.Category, Substack.Publication>(), animatingDifferences: false)
        Substack.Category.allCases.forEach { category in
            NetworkManager.shared.fetchPublications(by: category) { [weak self] res in
                switch res {
                case .success(let publications):
                    self?.publicationsByCategory[category] = publications
                    self?.updateSnapshot(for: category, with: publications, animated: true)
                case .failure(let err):
                    print("\(#function) failed to fetch data for category: \(category) with err: \(err)")
                }
            }
        }
    }
    
    private func updateSnapshot(for category: Substack.Category, with publications: [Substack.Publication], animated: Bool = true) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            var snapshot = self.dataSource.snapshot()
            snapshot.appendSections([category])
            snapshot.appendItems(publications, toSection: category)
            self.dataSource.apply(snapshot, animatingDifferences: animated)
            self.collectionView.refreshControl?.endRefreshing()
        }
    }
    
    func scrollToTop() {
        guard collectionView != nil else { return }
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredVertically, animated: true)
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
