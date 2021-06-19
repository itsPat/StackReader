//
//  TabBarController.swift
//  StackReader
//
//  Created by Patrick Trudel on 2021-05-30.
//

import UIKit
import AppTrackingTransparency

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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestATTPermission()
    }
    
    func requestATTPermission() {
        ATTrackingManager.requestTrackingAuthorization { status in
            switch status {
            case .authorized:
                print("Yay")
            default:
                AdManager.shared.userDeniedATTPermission()
            }
        }
    }
    
}

