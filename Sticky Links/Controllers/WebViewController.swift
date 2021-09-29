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
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.title = selectedLink?.title
    }
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: (selectedLink?.link)!)!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
        // Do any additional setup after loading the view.
    }
    
}

//MARK: WebView
extension WebViewController:WKNavigationDelegate{
    
}
