//
//  DiscoverViewController.swift
//  TRTCAPP_AppStore
//
//  Created by origin 李 on 2021/6/10.
//

import UIKit
import WebKit

class DiscoverViewController: UIViewController {
    lazy var loading: UIActivityIndicatorView = {
        if #available(iOS 13, *) {
            let loading = UIActivityIndicatorView(style: .large)
            return loading
        } else {
            let loading = UIActivityIndicatorView(style: .whiteLarge)
            return loading
        }
    }()

    lazy var webView: WKWebView = {
        let webview = WKWebView(frame: .zero)
        webview.isOpaque = false
        webview.backgroundColor = .clear
        webview.scrollView.backgroundColor = .clear
        webview.navigationDelegate = self
        webview.uiDelegate = self
        if #available(iOS 11.0, *) {
            webview.scrollView.contentInsetAdjustmentBehavior = .never
        }
        return webview
    }()

    var backButton: UIBarButtonItem?
    let url: URL? = URL(string: "https://comm.qq.com/trtc-app-finding-page/#/")
    init() {
        super.init(nibName: nil, bundle: nil)
        webView.addObserver(self, forKeyPath: "URL", options: .new, context: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        webView.removeObserver(self, forKeyPath: "URL")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.bringSubviewToFront(loading)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor("F4F6F9")
        configNav()
        view.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        guard let url = self.url else { return }
        let req = URLRequest(url: url as URL)
        webView.load(req)
        view.addSubview(loading)
        loading.snp.makeConstraints { make in
            make.width.height.equalTo(40)
            make.centerX.centerY.equalTo(view)
        }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "URL" {
            if webView.url?.absoluteString == "https://comm.qq.com/trtc-app-finding-page/#/" {
                backButton?.customView?.isHidden = true
            } else {
                backButton?.customView?.isHidden = false
            }
        }
    }

    func configNav() {
        navigationController?.navigationBar.topItem?.title = MainLocalize("Demo.TRTC.Portal.Main.discover")

        navigationController?.navigationBar.titleTextAttributes =
            [
                NSAttributedString.Key.foregroundColor: UIColor.black,
                NSAttributedString.Key.font: UIFont(name: "PingFangSC-Semibold", size: 18) ?? UIFont.systemFont(ofSize: 18),
            ]
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.isTranslucent = false
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "main_mine_about_back"), for: .normal)
        btn.addTarget(self, action: #selector(backBtnClick), for: .touchUpInside)
        backButton = UIBarButtonItem(customView: btn)
        backButton?.tintColor = .black
        navigationItem.leftBarButtonItem = backButton
        backButton?.customView?.isHidden = true
    }

    @objc func backBtnClick() {
        if webView.canGoBack {
            webView.goBack()
        } else {
            backButton?.customView?.isHidden = true
        }
    }

    override public var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }
}

extension DiscoverViewController: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        loading.startAnimating()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loading.stopAnimating()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        loading.stopAnimating()
    }
}

extension DiscoverViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if !(navigationAction.targetFrame?.isMainFrame ?? false) {
            webView.load(navigationAction.request)
        }
        return nil
    }
}
