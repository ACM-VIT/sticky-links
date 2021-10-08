//
//  WebViewController.swift
//  Sticky Links
//
//  Created by Samridh Agarwal on 29/09/21.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    
    var webView: WKWebView!
    var selectedLink : Items?
    private lazy var url: URL? = {
        if let selectedLink = selectedLink,
           let link = selectedLink.link {
            return URL(string: (link))
        } else {
            return nil
        }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = url {
            webView.load(URLRequest(url: url))
            webView.allowsBackForwardNavigationGestures = true
        }
    }
}

//MARK: WebView
extension WebViewController:WKNavigationDelegate{
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
}

// MARK: - Share Button
extension WebViewController {
    @IBAction func shareButtonPressed(_ sender: Any) {
        if let url = url {
            let activityController = UIActivityViewController(
                activityItems: [url],
                applicationActivities: nil
            )
            navigationController?.present(activityController, animated: true, completion: nil)
        }
    }
}
