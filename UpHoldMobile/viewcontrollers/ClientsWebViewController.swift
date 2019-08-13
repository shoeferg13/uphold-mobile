//
//  ClientsWebViewController.swift
//  UpHoldMobile
//
//  Created by Adam Ding on 7/24/19.
//  Copyright © 2019 Shannon Ferguson. All rights reserved.
//

import UIKit
import WebKit

class ClientsWebViewController: UIViewController, WKUIDelegate {

    var webView: WKWebView!
    var allTrends = [TrendsModel]()
    var trendsIndex: Int!
    
    override func loadView() {
        let webConfig = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfig)
        webView.uiDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: allTrends[trendsIndex].url!)
        let myRequest = URLRequest(url: url!)
        webView.load(myRequest)
    }
    

}
