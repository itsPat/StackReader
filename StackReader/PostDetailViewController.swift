//
//  PostDetailViewController.swift
//  StackReader
//
//  Created by Patrick Trudel on 2021-05-30.
//

import UIKit
import WebKit

class PostDetailViewController: UIViewController {

    @IBOutlet weak var webview: WKWebView!
    
    var post: Substack.Post?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = post?.title
        reloadWebview()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func fetchPostDetails() {
        guard let post = post else { return }
        NetworkManager.shared.fetchDetails(for: post) { [weak self] res in
            switch res {
            case .success(let post):
                self?.post = post
                self?.reloadWebview()
            case .failure(let err):
                print("\(#function) failed with error: \(err)")
            }
        }
    }
    
    func reloadWebview() {
        DispatchQueue.main.async { [weak self] in
            guard let urlStr = self?.post?.postUrl,
                  let url = URL(string: urlStr) else { return }
            self?.webview.load(URLRequest(url: url))
        }
    }

}
