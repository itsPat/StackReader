//
//  Extension+UIViewController.swift
//  StackReader
//
//  Created by Patrick Trudel on 2021-05-30.
//

import UIKit
import SafariServices

enum ViewController {
    
    case publicationDetail(publication: Substack.Publication)
    case postDetail(post: Substack.Post)
    case alert(title: String?,
               subtitle: String? = nil,
               actions: [UIAlertAction] = [UIAlertAction(title: "Ok", style: .default, handler: nil)],
               preferredStyle: UIAlertController.Style = .alert,
               barButtonItem: UIBarButtonItem? = nil,
               sourceView: UIView? = nil)
    
    var viewController: UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        switch self {
        case .publicationDetail(let publication):
            let vc = storyboard.instantiateViewController(withIdentifier: "PublicationDetailViewController") as! PublicationDetailViewController
            vc.publication = publication
            return vc
        case .postDetail(let post):
            guard let url = URL(string: post.postUrl ?? "") else {
                return .vc(.alert(title: "Oops", subtitle: "Unable to load a webview for this post."))
            }
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = post.isNewsletter
            config.barCollapsingEnabled = true
            let vc = SFSafariViewController(url: url, configuration: config)
            vc.dismissButtonStyle = .close
            vc.preferredBarTintColor = .systemBackground
            vc.preferredControlTintColor = .stackBlue
            return vc
        case .alert(let title, let subtitle, let actions, let style, let barButtonItem, let sourceView):
            let alertVC = UIAlertController(title: title, message: subtitle, preferredStyle: style)
            alertVC.popoverPresentationController?.barButtonItem = barButtonItem
            actions.forEach { alertVC.addAction($0) }
            if let sourceView = sourceView {
                alertVC.popoverPresentationController?.sourceView = sourceView
                alertVC.popoverPresentationController?.sourceRect = sourceView.frame
            }
            return alertVC
        }
    }
    
}

extension UIViewController {
    
    static func vc(_ type: ViewController) -> UIViewController {
        return type.viewController
    }
    
}
