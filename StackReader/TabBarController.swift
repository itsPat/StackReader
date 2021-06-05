//
//  TabBarController.swift
//  StackReader
//
//  Created by Patrick Trudel on 2021-05-30.
//

import UIKit

protocol TabBarControllerItem {
    func scrollToTop()
}

class TabBarController: UITabBarController {
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if let index = tabBar.items?.firstIndex(of: item),
           let nav = viewControllers?[index] as? UINavigationController,
           let vc = nav.viewControllers.first as? TabBarControllerItem {
            vc.scrollToTop()
        }
    }
    
}

