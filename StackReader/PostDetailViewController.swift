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
        setupNavigationItem()
        reloadWebview()
    }
    
    func setupNavigationItem() {
        navigationItem.title = post?.title
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "textformat"),
            menu: UIMenu(title: "", identifier: .textSize, options: .displayInline, children: [
                UIAction(title: "Smaller", image: UIImage(systemName: "minus")) { [weak self] _ in
                    self?.fontMultiplier -= 0.1
                    self?.fontMultiplier = max(self?.fontMultiplier ?? 1.0, 1.0)
                    self?.adjustFontForMultipler()
                },
                UIAction(title: "Bigger", image: UIImage(systemName: "plus")) { [weak self] _ in
                    self?.fontMultiplier += 0.1
                    self?.fontMultiplier = min(self?.fontMultiplier ?? 2.0, 2.0)
                    self?.adjustFontForMultipler()
                }
            ])
        )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationItem.rightBarButtonItem = nil
    }
    
    @objc
    func didTapFormatText(sender: UIBarButtonItem) {
        fontMultiplier = fontMultiplier == 1.0 ? 1.25 : 1.0
        adjustFontForMultipler()
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
    
    
    func adjustFontForMultipler() {
        webview.evaluateJavaScript(
            "document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust='\(fontMultiplier * 100)%'",
            completionHandler: nil
        )
        disableHeader()
    }
    
    func disableHeader() {
        // TODO: - Observe onload events from the webview in javascript
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.webview.evaluateJavaScript(
                "document.getElementsByClassName(\"main-menu  animated   \")[0].style.display = \"none\";",
                completionHandler: nil
            )
        }
    }

}
extension PostDetailViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        navigationItem.title = webview.title
        disableHeader()
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        navigationItem.title = webview.title
    }
    
}
