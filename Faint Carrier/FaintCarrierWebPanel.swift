import SwiftUI
import WebKit

// Fullscreen WKWebView wrapper used by both the launch gate and the Settings Privacy sheet.
struct FaintCarrierWebPanel: UIViewRepresentable {
    let urlString: String

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        if #available(iOS 10.0, *) {
            config.mediaTypesRequiringUserActionForPlayback = []
        }
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.bounces = true
        // Belt-and-suspenders for the top safe area; the real fix is the frame in App.swift.
        webView.scrollView.contentInsetAdjustmentBehavior = .always
        webView.isOpaque = true
        webView.backgroundColor = UIColor(red: 0.02, green: 0.04, blue: 0.09, alpha: 1.0)
        if let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
        }
        return webView
    }

    // MUST stay empty — never reload on SwiftUI re-renders.
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
