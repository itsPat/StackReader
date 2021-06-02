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
    var fontMultiplier: CGFloat = 1.0
    
    var post: Substack.Post?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webview.navigationDelegate = self
        navigationItem.title = post?.title
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "textformat"),
            style: .plain,
            target: self,
            action: #selector(didTapFormatText)
        )
        reloadWebview()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationItem.rightBarButtonItem = nil
    }
    
    @objc
    func didTapFormatText() {
        fontMultiplier = fontMultiplier == 1.0 ? 1.25 : 1.0
        adjustFont(to: fontMultiplier)
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
    
    
    func adjustFont(to multiplier: CGFloat) {
        webview.evaluateJavaScript(
            "document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust='\(multiplier * 100)%'",
            completionHandler: nil
        )
    }

}
extension PostDetailViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        navigationItem.title = webview.title
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        navigationItem.title = webview.title
    }
    
}
