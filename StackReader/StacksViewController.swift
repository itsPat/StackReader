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
    
    // MARK: - Computed Properties
    
    lazy var dataSource: UICollectionViewDiffableDataSource<Substack.Publication, Substack.Item> = {
        let dataSource = UICollectionViewDiffableDataSource<Substack.Publication, Substack.Item>(
            collectionView: collectionView,
            cellProvider: { collectionView, indexPath, item in
                // Cell Configuration
                switch item {
                case .post(let post):
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostCell.reuseId, for: indexPath) as! PostCell
                    cell.configure(with: post)
                    return cell
                case .ad:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AdCell.reuseId, for: indexPath) as! AdCell
                    cell.configure()
                    return cell
                default:
                    fatalError("\(#function) has missing implementation for type: \(item)")
                }
            }
        )
        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, index in
            // Header Configuration
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: SectionHeader.reuseId, for: index) as! SectionHeader
            if let publication = self?.dataSource.snapshot().sectionIdentifiers[index.section] {
                header.configure(
                    with: publication,
                    menu: UIMenu(
                        title: publication.name,
                        children: [
                            publication.seeAllAction(presenter: self?.navigationController),
                            publication.saveAction { [weak self] in
                                self?.remove(publication: publication)
                            }
                        ]
                    )
                )
            }
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
        collectionView.dataSource = dataSource
        setupCollectionViewLayout()
        collectionView.register(
            SectionHeader.nib,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SectionHeader.reuseId
        )
        collectionView?.register(
            PostCell.nib,
            forCellWithReuseIdentifier: PostCell.reuseId
        )
        collectionView?.register(
            AdCell.nib,
            forCellWithReuseIdentifier: AdCell.reuseId
        )
        refresh()
        collectionView.refreshControl = UIRefreshControl(
            frame: .zero,
            primaryAction: UIAction { [weak self] _ in
                self?.refresh()
        })
    }
    
    func setupCollectionViewLayout() {
        collectionView.setCollectionViewLayout(.stacksLayout, animated: true)
    }
    
    func resetSnapshot(animated: Bool = false) {
        var snapshot = NSDiffableDataSourceSnapshot<Substack.Publication, Substack.Item>()
        snapshot.appendSections(UserData.savedPublications)
        dataSource.apply(snapshot, animatingDifferences: animated)
    }
    
    @objc
    private func refresh() {
        collectionView.refreshControl?.beginRefreshing()
        resetSnapshot()
        UserData.savedPublications.forEach { publication in
            NetworkManager.shared.fetchPosts(for: publication) { [weak self] res in
                switch res {
                case .success(let posts):
                    self?.updateSnapshot(for: publication, with: posts, animated: true)
                case .failure(let err):
                    print("\(#function) failed to fetch data for publication: \(publication) with err: \(err)")
                }
            }
        }
    }
    
    private func updateSnapshot(for publication: Substack.Publication, with posts: [Substack.Post], animated: Bool = true) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            var snapshot = self.dataSource.snapshot()
            let items = posts.map { Substack.Item.post($0) } // + (AdManager.shared.adQueueIsEmpty ? [] : [.ad()])
            snapshot.appendItems(items, toSection: publication)
            self.dataSource.apply(snapshot, animatingDifferences: animated)
            self.collectionView.refreshControl?.endRefreshing()
        }
    }
    
    func remove(publication: Substack.Publication) {
        UserData.remove(publication: publication)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            var snapshot = self.dataSource.snapshot()
            snapshot.deleteSections([publication])
            self.dataSource.apply(snapshot)
        }
    }
    
    func scrollToTop() {
        guard collectionView != nil else { return }
        collectionView?.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredVertically, animated: true)
    }

}

extension StacksViewController: UICollectionViewDelegate {
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let publication = dataSource.snapshot().sectionIdentifiers[indexPath.section]
        let item = dataSource.snapshot().itemIdentifiers(inSection: publication)[indexPath.item]
        switch item {
        case .post(let post):
            present(.vc(.postDetail(post: post)), animated: true, completion: nil)
        default:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration? {
        let publication = dataSource.snapshot().sectionIdentifiers[indexPath.section]
        let item = dataSource.snapshot().itemIdentifiers(inSection: publication)[indexPath.item]
        switch item {
        case .post(let post):
            return UIContextMenuConfiguration(
                identifier: "\(indexPath.section),\(indexPath.item)" as NSString,
                previewProvider: { () -> UIViewController? in
                    return .vc(.postDetail(post: post))
                },
                actionProvider: { _ -> UIMenu? in
                    return UIMenu(title: "Quick Actions", children: [post.saveAction {
                        collectionView.reloadData()
                    }])
                }
            )
        default:
            return nil
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        guard let components = (configuration.identifier as? String)?.components(separatedBy: ","),
              let sectionIndex = Int(components.first ?? ""),
              let itemIndex = Int(components.last ?? "") else { return }
        let publication = dataSource.snapshot().sectionIdentifiers[sectionIndex]
        let item = dataSource.snapshot().itemIdentifiers(inSection: publication)[itemIndex]
        switch item {
        case .post(let post):
            animator.addCompletion { [weak self] in
                self?.present(.vc(.postDetail(post: post)), animated: true, completion: nil)
            }
        default:
            break
        }
    }
    
}

