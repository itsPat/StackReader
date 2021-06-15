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
                // Cell Configuration
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PublicationCell.reuseId, for: indexPath) as! PublicationCell
                cell.configure(with: publication)
                return cell
            }
        )
        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, index in
            switch kind {
            case UICollectionView.elementKindSectionHeader:
                // Header Configuration
                let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: SectionHeader.reuseId, for: index) as! SectionHeader
                if let category = self?.dataSource.snapshot().sectionIdentifiers[index.section] {
                    header.configure(
                        with: category,
                        menu: UIMenu(
                            title: category.title,
                            children: [
                                category.seeAllAction(presenter: self?.navigationController)
                            ]
                        )
                    )
                }
                return header
            default:
                guard let ad = AdManager.shared.nextNativeAd,
                      let footer = collectionView.dequeueReusableSupplementaryView(
                        ofKind: kind,
                        withReuseIdentifier: AdFooterView.reuseId,
                        for: index
                      ) as? AdFooterView else {
                    return collectionView.dequeueReusableSupplementaryView(
                        ofKind: kind,
                        withReuseIdentifier: AdFooterView.reuseId,
                        for: index
                    )
                }
                footer.configure(with: ad)
                return footer
            }
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
        collectionView.dataSource = dataSource
        setupCollectionViewLayout()
        collectionView.register(
            SectionHeader.nib,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SectionHeader.reuseId
        )
        collectionView.register(
            AdFooterView.nib,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: AdFooterView.reuseId
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
        collectionView.setCollectionViewLayout(.discoverLayout, animated: true)
    }
    
    func resetSnapshot(animated: Bool = false) {
        var snapshot = NSDiffableDataSourceSnapshot<Substack.Category, Substack.Publication>()
        snapshot.appendSections(Substack.Category.allCases)
        dataSource.apply(snapshot, animatingDifferences: animated)
    }
    
    @objc
    private func refresh() {
        collectionView.refreshControl?.beginRefreshing()
        resetSnapshot()
        Substack.Category.allCases.forEach { category in
            NetworkManager.shared.fetchPublications(by: category) { [weak self] res in
                switch res {
                case .success(let publications):
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


// MARK: - UICollectionViewDelegate

extension DiscoverViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category = dataSource.snapshot().sectionIdentifiers[indexPath.section]
        let publication = dataSource.snapshot().itemIdentifiers(inSection: category)[indexPath.item]
        navigationController?.pushViewController(.vc(.publicationDetail(publication: publication)), animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration? {
        let category = dataSource.snapshot().sectionIdentifiers[indexPath.section]
        let publication = dataSource.snapshot().itemIdentifiers(inSection: category)[indexPath.item]
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
              let item = Int(components.last ?? "") else { return }
        let category = dataSource.snapshot().sectionIdentifiers[section]
        let publication = dataSource.snapshot().itemIdentifiers(inSection: category)[item]
        animator.addCompletion { [weak self] in
            self?.navigationController?.pushViewController(.vc(.publicationDetail(publication: publication)), animated: true)
        }
    }
    
}
