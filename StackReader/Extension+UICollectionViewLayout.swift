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
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.5))
        )
        item.contentInsets = itemInset
        
        // V Group
        let vGroup = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0)),
            subitems: [item, item]
        )
        
        // H Group
        let hGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.5), heightDimension: .fractionalWidth(1.5)),
            subitems: [vGroup, vGroup]
        )
        
        // Section
        let section = NSCollectionLayoutSection(group: hGroup)
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
