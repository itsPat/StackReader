//
//  Extension+UICollectionViewLayout.swift
//  StackReader
//
//  Created by Patrick Trudel on 2021-06-10.
//

import UIKit

extension UICollectionViewLayout {
    
    static var discoverLayout: UICollectionViewCompositionalLayout {
        let itemInset = NSDirectionalEdgeInsets(top: 0.0, leading: 4.0, bottom: 0.0, trailing: 4.0)
        let sectionInset = NSDirectionalEdgeInsets(top: 4.0, leading: 16.0, bottom: 20.0, trailing: 8.0)
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
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(64)),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [headerItem]
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    static var stacksLayout: UICollectionViewCompositionalLayout {
        let itemInset = NSDirectionalEdgeInsets(top: 2.0, leading: 0.0, bottom: 2.0, trailing: 16.0)
        let sectionInset = NSDirectionalEdgeInsets(top: 4.0, leading: 16.0, bottom: 20.0, trailing: 8.0)
        
        // Item
        let item = NSCollectionLayoutItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.33))
        )
        item.contentInsets = itemInset
        
        // Vertical Group
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: .init(widthDimension: .fractionalWidth(0.9), heightDimension: .absolute(300.0)),
            subitem: item,
            count: 3
        )
        
        // Section
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = sectionInset
        section.orthogonalScrollingBehavior = .groupPaging
        
        // Supplementary Item
        let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(64)),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [headerItem]
        return UICollectionViewCompositionalLayout(section: section)
    }
    
}
