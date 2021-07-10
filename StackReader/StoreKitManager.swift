//
//  StoreKitManager.swift
//  StackReader
//
//  Created by Patrick Trudel on 2021-06-10.
//

import Foundation
import StoreKit
import SafariServices

class StoreKitManager: NSObject {
    
    static let shared = StoreKitManager()
    private override init() {}
    
    private var postDetailOpenedAt: Date?
    private var lastPresenter: UIViewController?
    /// The minimum amount of time to spend in the postDetail view controller to trigger a review request on dismiss.
    private var timeSpentThreshold: TimeInterval = 120.0
    
    func requestReview(from viewController: UIViewController) {
        guard let scene = viewController.view.window?.windowScene else { return }
        SKStoreReviewController.requestReview(in: scene)
    }
    
    func willPresent(controller: SFSafariViewController) {
        postDetailOpenedAt = Date()
        lastPresenter = controller.presentingViewController
        controller.delegate = self
    }
    
}

extension StoreKitManager: SFSafariViewControllerDelegate {
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        if let openDate = postDetailOpenedAt,
           Date().timeIntervalSince(openDate) > 120,
           let lastPresenter = lastPresenter {
            requestReview(from: lastPresenter)
        }
    }
    
}
