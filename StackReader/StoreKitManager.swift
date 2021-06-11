//
//  StoreKitManager.swift
//  StackReader
//
//  Created by Patrick Trudel on 2021-06-10.
//

import Foundation
import StoreKit

class StoreKitManager {
    
    static func requestReview(from viewController: UIViewController) {
        guard let scene = viewController.view.window?.windowScene else { return }
        SKStoreReviewController.requestReview(in: scene)
    }
    
}
