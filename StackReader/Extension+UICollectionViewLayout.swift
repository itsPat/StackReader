//
//  Extension+UICollectionViewLayout.swift
//  StackReader
//
//  Created by Patrick Trudel on 2021-06-10.
//

import UIKit

extension UICollectionViewLayout {
    
    static func orthogonalLayout(
        itemInset: NSDirectionalEdgeInsets = NSDirectionalEdgeInsets(top: 4.0, leading: 4.0, bottom: 4.0, trailing: 4.0),
        sectionInset: NSDirectionalEdgeInsets = NSDirectionalEdgeInsets(top: 4.0, leading: 4.0, bottom: 4.0, trailing: 4.0)
    ) -> UICollectionViewCompositionalLayout {
        // Large Item
        let largeItem = NSCollectionLayoutItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        )
        largeItem.contentInsets = itemInset
        
        // Horizontal Group
        let hGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(widthDimension: .fractionalWidth(0.75), heightDimension: .fractionalWidth(0.75)),
            subitems: [largeItem]
        )
        
        // Section
        let section = NSCollectionLayoutSection(group: hGroup)
        section.contentInsets = sectionInset
        section.orthogonalScrollingBehavior = .groupPaging
        
        // Supplementary Item
        let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(64)),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [headerItem]
        return UICollectionViewCompositionalLayout(section: section)
    }
    
}
