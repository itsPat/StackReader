//
//  SavedViewController.swift
//  StackReader
//
//  Created by Patrick Trudel on 2021-05-30.
//

import UIKit

class SavedViewController: UIViewController, TabBarControllerItem {
    

    @IBOutlet weak var collectionView: UICollectionView!
    
    var posts: [Substack.Post] {
        UserData.savedPosts
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }
    
    func setup() {
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        collectionView.register(
            PostCell.nib,
            forCellWithReuseIdentifier: PostCell.reuseId
        )
    }
    
    func scrollToTop() {
        guard collectionView != nil else { return }
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredVertically, animated: true)
    }

}

// MARK: - UICollectionViewDataSource

extension SavedViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostCell.reuseId, for: indexPath) as! PostCell
        let post = posts[indexPath.item]
        cell.configure(with: post, didTapSave: { collectionView.reloadData() })
        return cell
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension SavedViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = collectionView.bounds.inset(by: collectionView.contentInset).width
        return CGSize(width: w, height: 100)
    }
    
}

extension SavedViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let post = posts[indexPath.item]
        present(.vc(.postDetail(post: post)), animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration? {
        let post = posts[indexPath.item]
        return UIContextMenuConfiguration(
            identifier: "\(indexPath.item)" as NSString,
            previewProvider: { () -> UIViewController? in
                return .vc(.postDetail(post: post))
            },
            actionProvider: { _ -> UIMenu? in
                return UIMenu(title: "Quick Actions", children: [post.saveAction {
                    collectionView.reloadData()
                }])
            }
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        guard let item = Int(configuration.identifier as? String ?? ""),
              item < posts.count else { return }
        let post = posts[item]
        animator.addCompletion { [weak self] in
            self?.present(.vc(.postDetail(post: post)), animated: true, completion: nil)
        }
    }
    
}
