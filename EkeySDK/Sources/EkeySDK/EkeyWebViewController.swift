import UIKit
import WebKit

final class EkeyWebViewController: NSObject, WKNavigationDelegate, WKUIDelegate {
    let webView: WKWebView
    private let onCompleted: (URL) -> Void
    private var didOpenEkeyApp = false

    init(onCompleted: @escaping (URL) -> Void) {
        self.onCompleted = onCompleted
        webView = WKWebView()
        super.init()
        webView.navigationDelegate = self
        webView.uiDelegate = self
    }

    func start() {
        didOpenEkeyApp = false
        let request = EkeyAuthorizationRequestBuilder.makeRequest()
        webView.load(URLRequest(url: request.url))
    }

    /// Called when the app resumes via the `focus_uri` custom scheme. The WKWebView instance
    /// (and its session cookies) is kept alive the whole time, so reloading it lets the
    /// server-side OIDC interaction continue from consented-login through to redirect_uri,
    /// instead of losing the session the way a torn-down WebView would.
    func resume() {
        webView.reload()
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }

        decisionHandler(intercept(url) ? .cancel : .allow)
    }

    /// The eKey login page opens `mobileLogin` via `window.open()`/`target="_blank"` rather
    /// than a same-frame navigation, so WKWebView routes it through the UI delegate's popup
    /// handling instead of `decidePolicyFor navigationAction`. Returning nil here (no new
    /// window created) after handing the URL off ourselves is what makes app-to-app work.
    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        if let url = navigationAction.request.url {
            _ = intercept(url)
        }
        return nil
    }

    /// Returns true if the URL was handed off (redirect completion or app-to-app handoff)
    /// and should not be loaded by the WebView itself.
    private func intercept(_ url: URL) -> Bool {
        let urlString = url.absoluteString

        if urlString.hasPrefix(EkeyLoginConfig.redirectUri) {
            onCompleted(url)
            return true
        }

        if !didOpenEkeyApp && EkeyLoginConfig.appToAppDomains.contains(where: urlString.contains) {
            didOpenEkeyApp = true
            UIApplication.shared.open(url)
            return true
        }

        return false
    }
}
