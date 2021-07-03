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
        let sectionInset = NSDirectionalEdgeInsets(top: 4.0, leading: 16.0, bottom: 20.0, trailing: 16.0)
        let isIpad = UIDevice.current.userInterfaceIdiom == .pad
        let isHorizontal = UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight
        let layout = UICollectionViewCompositionalLayout { sectionIndex, environment in
            // Large Item
            let largeItem = NSCollectionLayoutItem(
                layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            )
            largeItem.contentInsets = itemInset
            
            // Horizontal Group
            let hGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: isIpad || isHorizontal ?
                    .init(widthDimension: .fractionalWidth(0.45), heightDimension: .fractionalWidth(0.45)) :
                    .init(widthDimension: .fractionalWidth(0.9), heightDimension: .fractionalWidth(0.9)),
                subitems: [largeItem]
            )
            
            // Section
            let section = NSCollectionLayoutSection(group: hGroup)
            section.contentInsets = sectionInset
            section.orthogonalScrollingBehavior = .groupPaging
            
            // Supplementary Items
            let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(64)),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            let footerItem = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.9 * (isIpad ? 0.75 : 1.0) * (isHorizontal ? 0.75 : 1.0)),
                    heightDimension: .estimated(500)
                ),
                elementKind: UICollectionView.elementKindSectionFooter,
                alignment: .bottom
            )
            let showAd = sectionIndex % AdManager.adFrequency == 0 &&
                sectionIndex != 0 &&
                !AdManager.shared.adQueueIsEmpty
            section.boundarySupplementaryItems = showAd ? [headerItem, footerItem] : [headerItem]
            return section
        }
        return layout
    }
    
    static var hierarchicalLayout: UICollectionViewCompositionalLayout {
        let itemInset = NSDirectionalEdgeInsets(top: 4.0, leading: 4.0, bottom: 4.0, trailing: 4.0)
        let sectionInset = NSDirectionalEdgeInsets(top: 4.0, leading: 16.0, bottom: 20.0, trailing: 16.0)
        let isIpad = UIDevice.current.userInterfaceIdiom == .pad
        let isHorizontal = UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight
        let layout = UICollectionViewCompositionalLayout { sectionIndex, environment in
            // Large Item
            let largeItem = NSCollectionLayoutItem(
                layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1.0))
            )
            largeItem.contentInsets = itemInset
            
            // Small Item
            let smallItem = NSCollectionLayoutItem(
                layoutSize: .init(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalWidth(0.5))
            )
            smallItem.contentInsets = itemInset
            
            // Horizontal Group
            let hGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.25)),
                subitems: [smallItem, smallItem]
            )
            
            // Vertical Group
            let vGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1.5)),
                subitems: [
                    largeItem,
                    hGroup
                ]
            )
            
            // Section
            let section = NSCollectionLayoutSection(group: vGroup)
            section.contentInsets = sectionInset
            
            let footerItem = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.9 * (isIpad ? 0.75 : 1.0) * (isHorizontal ? 0.75 : 1.0)),
                    heightDimension: .estimated(500)
                ),
                elementKind: UICollectionView.elementKindSectionFooter,
                alignment: .bottom
            )
            let showAd = sectionIndex % AdManager.adFrequency == 0 &&
                sectionIndex != 0 &&
                !AdManager.shared.adQueueIsEmpty
            section.boundarySupplementaryItems = showAd ? [footerItem] : []
            return section
        }
        return layout
    }
    
    static var stacksLayout: UICollectionViewCompositionalLayout {
        let itemInset = NSDirectionalEdgeInsets(top: 2.0, leading: 0.0, bottom: 2.0, trailing: 16.0)
        let sectionInset = NSDirectionalEdgeInsets(top: 4.0, leading: 16.0, bottom: 20.0, trailing: 8.0)
        let isIpad = UIDevice.current.userInterfaceIdiom == .pad
        let isHorizontal = UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight
        
        // Item
        let item = NSCollectionLayoutItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.33))
        )
        item.contentInsets = itemInset
        
        // Vertical Group
        let vGroup = NSCollectionLayoutGroup.vertical(
            layoutSize: .init(widthDimension: .fractionalWidth(0.925), heightDimension: .absolute(330.0)),
            subitem: item,
            count: 3
        )
        
        // Horizontal Group
        let hGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(
                widthDimension: isIpad || isHorizontal ? .fractionalWidth(0.475) : .fractionalWidth(0.9),
                heightDimension: .absolute(330)
            ),
            subitems: [vGroup]
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
    
}
