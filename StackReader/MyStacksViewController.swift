//
//  MyStacksViewController.swift
//  StackReader
//
//  Created by Patrick Trudel on 2021-06-02.
//

import UIKit

class MyStacksViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var publications: [Substack.Publication] {
        UserData.savedPublications
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        collectionView.register(
            PublicationCell.nib,
            forCellWithReuseIdentifier: PublicationCell.reuseId
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        collectionView.reloadData()
    }

}

// MARK: - UICollectionViewDataSource

extension MyStacksViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        publications.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PublicationCell.reuseId, for: indexPath) as! PublicationCell
        let publication = publications[indexPath.item]
        cell.configure(
            with: publication,
            didTapAdd: {
                UserData.add(publication: publication)
            }
        )
        return cell
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension MyStacksViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = collectionView.bounds.inset(by: collectionView.contentInset).width
        return CGSize(width: w, height: w)
    }
    
}

extension MyStacksViewController: UICollectionViewDelegate {
    
    
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
                return UIMenu(title: "Quick Actions", children: [
                    UIAction(title: "Add Publication", image: UIImage(systemName: "plus.circle")) { _ in
                        UserData.add(publication: publication)
                    }
                ])
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

