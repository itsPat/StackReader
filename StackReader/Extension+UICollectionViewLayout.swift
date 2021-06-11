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
        let isIpad = UIDevice.current.userInterfaceIdiom == .pad
        let isHorizontal = UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight
        
        // Large Item
        let largeItem = NSCollectionLayoutItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        )
        largeItem.contentInsets = itemInset
        
        // Horizontal Group
        let dimension: CGFloat = 0.75 * ((isIpad || isHorizontal) ? 0.5 : 1.0)
        let hGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(widthDimension: .fractionalWidth(dimension), heightDimension: .fractionalWidth(dimension)),
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
