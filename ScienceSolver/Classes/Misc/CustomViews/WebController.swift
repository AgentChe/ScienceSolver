//
//  WebController.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 17.11.2024.
//

import UIKit
import WebKit

final class WebController: UIViewController {
    private lazy var mainView = WebPageView()
    
    override func loadView() {
        view = mainView
    }
}

// MARK: Make
extension WebController {
    static func make(url: URL) -> WebController {
        let controller = WebController()
        controller.mainView.webView.load(URLRequest(url: url))
        return controller
    }
}

private final class WebPageView: UIView {
    lazy var webView = makeWebView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Make constraints
private extension WebPageView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: topAnchor),
            webView.bottomAnchor.constraint(equalTo: bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension WebPageView {
    func makeWebView() -> WKWebView {
        let view = WKWebView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
