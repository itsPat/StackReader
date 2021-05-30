//
//  PublicationDetailViewController.swift
//  StackReader
//
//  Created by Patrick Trudel on 2021-05-30.
//

import UIKit

class PublicationDetailViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var publication: Substack.Publication?
    var posts = [Substack.Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = publication?.name
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        collectionView.register(PostCell.nib, forCellWithReuseIdentifier: PostCell.reuseId)
        fetchPosts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func fetchPosts(offset: Int = 0) {
        guard let pub = publication else { return }
        if offset == 0 {
            posts.removeAll()
        }
        NetworkManager.shared.fetchPosts(for: pub, offset: offset) { [weak self] res in
            switch res {
            case .success(let posts):
                self?.posts.append(contentsOf: posts)
                self?.reloadCollectionView()
            case .failure(let err):
                print("\(#function) failed with error: \(err)")
            }
        }
    }
    
    func reloadCollectionView() {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
        }
    }
    
}


// MARK: - UICollectionViewDataSource

extension PublicationDetailViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostCell.reuseId, for: indexPath) as! PostCell
        let post = posts[indexPath.item]
        cell.configure(with: post, didTapSave: {
            print("User did tap save for post: \(post.title) ✅")
        })
        return cell
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension PublicationDetailViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = collectionView.bounds.inset(by: collectionView.contentInset).width
        return CGSize(width: w, height: 100.0)
    }
    
}

extension PublicationDetailViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let post = posts[indexPath.item]
        navigationController?.pushViewController(.vc(.postDetail(post: post)), animated: true)
    }
    
}
