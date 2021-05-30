//
//  Extension+UIViewController.swift
//  StackReader
//
//  Created by Patrick Trudel on 2021-05-30.
//

import UIKit

enum ViewController {
    
    case publicationDetail(publication: Substack.Publication)
    case postDetail(post: Substack.Post)
    
    
    var viewController: UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        switch self {
        case .publicationDetail(let publication):
            let vc = storyboard.instantiateViewController(withIdentifier: "PublicationDetailViewController") as! PublicationDetailViewController
            vc.publication = publication
            return vc
        case .postDetail(let post):
            let vc = storyboard.instantiateViewController(withIdentifier: "PostDetailViewController") as! PostDetailViewController
            vc.post = post
            return vc
        }
    }
    
}

extension UIViewController {
    
    static func vc(_ type: ViewController) -> UIViewController {
        return type.viewController
    }
    
}
