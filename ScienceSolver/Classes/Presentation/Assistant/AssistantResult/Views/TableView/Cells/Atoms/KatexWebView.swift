//
//  KatexWebView.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 03.10.2024.
//

import WebKit

final class KatexWebView: UIView {
    lazy var webView = makeWebView()
    
    private let katex: String
    private let didUpdateLayout: () -> Void
    
    private lazy var heightConstraintId = UUID().uuidString
    
    init(katex: String, didUpdateLayout: @escaping () -> Void) {
        self.katex = katex
        self.didUpdateLayout = didUpdateLayout
        
        super.init(frame: .zero)
        
        makeConstraints()
        initialize()
        load()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: WKNavigationDelegate
extension KatexWebView: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let js = "document.body.scrollHeight;"
        
        webView.evaluateJavaScript(js) { [weak self] result, error in
            guard let self else { return }
            
            guard let height = result as? CGFloat else { return }
            
            let zoomScale = webView.scrollView.zoomScale
            let overlayHeight = height * zoomScale
            
            let heightConstraint = webView.constraints.first(where: { [weak self] constraint -> Bool in
                constraint.identifier == self?.heightConstraintId
            })
            if let heightConstraint {
                heightConstraint.isActive = false
                heightConstraint.constant = overlayHeight
                heightConstraint.isActive = true
            }
            
            didUpdateLayout()
        }
    }
}

// MARK: Private
private extension KatexWebView {
    func initialize() {
        backgroundColor = UIColor.clear
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    func load() {
        let htmlString = generateHTML(for: katex)
        webView.loadHTMLString(htmlString, baseURL: nil)
    }
    
    func generateHTML(for katex: String) -> String {
        let font = Fonts.Inter.regular(size: 16.scale)
        
        return """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <title>KaTeX Example</title>
            <!-- KaTeX CSS -->
            <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.16.11/dist/katex.min.css" integrity="sha384-nB0miv6/jRmo5UMMR1wu3Gz6NLsoTkbqJghGIsx//Rlm+ZU03BU6SQNC66uf4l5+" crossorigin="anonymous">

            <!-- KaTeX JS -->
            <script defer src="https://cdn.jsdelivr.net/npm/katex@0.16.11/dist/katex.min.js" integrity="sha384-7zkQWkzuo3B5mTepMUcHkMB5jZaolc2xDwL6VFqjFALcbeS9Ggm/Yr2r3Dy4lfFg" crossorigin="anonymous"></script>
             <script defer src="https://cdn.jsdelivr.net/npm/katex@0.16.11/dist/contrib/auto-render.min.js" integrity="sha384-43gviWU0YVjaDtb/GhzOouOXtZMP/7XUzwPTstBeZFe/+rCMvRwr4yROQP43s0Xk" crossorigin="anonymous"
                   onload="renderMathInElement(document.body);"></script>
             </head>
           </html>
            </script>
            <style>
                body {
                    font-family: \(font.fontName);
                    font-style: regular;
                    padding: 0px;
                    color: #000000;
                }
                p {
                    margin-bottom: 0px;
                    font-size: \(font.pointSize);
                    line-height: \(22.scale)px;
                }
            </style>
        </head>
        <body>
            \(katex)
        </body>
        </html>
        """
    }
}

// MARK: Make constraints
private extension KatexWebView {
    func makeConstraints() {
        let heightConstraint = webView.heightAnchor.constraint(equalToConstant: 0)
        heightConstraint.identifier = heightConstraintId
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: trailingAnchor),
            webView.topAnchor.constraint(equalTo: topAnchor),
            webView.bottomAnchor.constraint(equalTo: bottomAnchor),
            heightConstraint
        ])
    }
}

// MARK: Lazy initialization
private extension KatexWebView {
    func makeWebView() -> WKWebView {
        let disableZoomSource = "var meta = document.createElement('meta');" +
            "meta.name = 'viewport';" +
            "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';" +
            "var head = document.getElementsByTagName('head')[0];" +
            "head.appendChild(meta);"
        let disableZoomScript = WKUserScript(source: disableZoomSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        
        let userContentController = WKUserContentController()
        userContentController.addUserScript(disableZoomScript)
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController
        
        let view = WKWebView(frame: .zero, configuration: configuration)
        view.backgroundColor = UIColor.clear
        view.scrollView.contentInset = UIEdgeInsets()
        view.scrollView.layer.masksToBounds = false
        view.scrollView.isScrollEnabled = false
        view.scrollView.showsVerticalScrollIndicator = false
        view.scrollView.showsHorizontalScrollIndicator = false
        view.navigationDelegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
