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
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
        )
        largeItem.contentInsets = itemInset
        
        // Small item
        let smallItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.5))
        )
        smallItem.contentInsets = itemInset
        
        // Nested Group
        let nestedGroup = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.25), heightDimension: .fractionalHeight(1.0)),
            subitems: [smallItem]
        )
        
        // Outer Group
        let outerGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.5)),
            subitems: [largeItem] //, nestedGroup, nestedGroup]
        )
        
        // Section
        let section = NSCollectionLayoutSection(group: outerGroup)
        section.contentInsets = sectionInset
        section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
        
        // Supplementary Item
        let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [headerItem]
        return UICollectionViewCompositionalLayout(section: section)
    }
    
}
