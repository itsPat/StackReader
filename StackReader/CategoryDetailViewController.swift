//
//  CategoryDetailViewController.swift
//  StackReader
//
//  Created by Patrick Trudel on 2021-05-30.
//

import UIKit

class CategoryDetailViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var category: Substack.Category?
    var publications = [Substack.Publication]()
    var page = 0
    var isFetching = false
    var hasMorePublications = true
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    // MARK: - Methods
    
    func fetchPublications(reload: Bool = false) {
        guard let category = category else { return }
        isFetching = true
        
        if reload {
            page = 0
            publications.removeAll()
        }
        
        NetworkManager.shared.fetchPublications(by: category, page: page) { [weak self] res in
            self?.isFetching = false
            switch res {
            case .success(let result):
                self?.hasMorePublications = result.more
                self?.page += 1
                self?.publications.append(contentsOf: result.publications)
                self?.reloadCollectionView()
            case .failure(let err):
                print("\(#function) failed to fetch publications for category: \(category) with err: \(err)")
            }
        }
    }
    
    func setup() {
        navigationItem.title = category?.title
        collectionView?.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        collectionView?.register(PublicationCell.nib, forCellWithReuseIdentifier: PublicationCell.reuseId)
        fetchPublications(reload: true)
    }
    
    func reloadCollectionView() {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView?.reloadData()
        }
    }
    
}


// MARK: - UICollectionViewDataSource

extension CategoryDetailViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        publications.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PublicationCell.reuseId, for: indexPath) as! PublicationCell
        let publication = publications[indexPath.item]
        cell.configure(with: publication, didTapAdd: { collectionView.reloadData() })
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == publications.count - 1,
           !isFetching,
           hasMorePublications {
            fetchPublications(reload: false)
        }
    }
    
}

// MARK: - UICollectionViewDataSourcePrefetching

extension CategoryDetailViewController: UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for index in indexPaths {
            let publication = publications[index.item]
            ImageManager.shared.getImage(
                with: publication.logoUrl ?? publication.authorPhotoUrl ?? "",
                taskId: "\(publication.id)"
            )
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        for index in indexPaths {
            let publication = publications[index.item]
            NetworkManager.shared.cancel(taskWithId: "\(publication.id)")
        }
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension CategoryDetailViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfColumns: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 3 : 1
        let spacing: CGFloat = 10 * (numberOfColumns - 1)
        let w: CGFloat = (collectionView.bounds.inset(by: collectionView.contentInset).width - spacing) / numberOfColumns
        return CGSize(width: w, height: w)
    }
    
}

extension CategoryDetailViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let publication = publications[indexPath.item]
        navigationController?.pushViewController(.vc(.publicationDetail(publication: publication)), animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration? {
        let publication = publications[indexPath.item]
        return UIContextMenuConfiguration(
            identifier: "\(indexPath.item)" as NSString,
            previewProvider: { () -> UIViewController? in
                return .vc(.publicationDetail(publication: publication))
            },
            actionProvider: { _ -> UIMenu? in
                return UIMenu(title: "Quick Actions", children: [publication.saveAction()])
            }
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        guard let item = Int(configuration.identifier as? String ?? ""),
              item < publications.count else { return }
        let publication = publications[item]
        animator.addCompletion { [weak self] in
            self?.navigationController?.pushViewController(.vc(.publicationDetail(publication: publication)), animated: true)
        }
    }
    
}
