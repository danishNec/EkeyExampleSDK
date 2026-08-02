//
//  EkeyWebView.swift
//  EkeyExampleSDK
//
//  Created by Syed Danish  on 30/07/2026.
//

import Combine
import SwiftUI
import WebKit

final class EkeyWebViewController: NSObject, ObservableObject, WKNavigationDelegate, WKUIDelegate {
    let webView: WKWebView
    private let onCompleted: (URL) -> Void
    private var didOpenEkeyApp = false

    init(onCompleted: @escaping (URL) -> Void) {
        webView = WKWebView()
        self.onCompleted = onCompleted
        super.init()
        webView.navigationDelegate = self
        webView.uiDelegate = self
    }

    func start() {
        didOpenEkeyApp = false
        let request = EkeyLoginConfig.makeAuthorizationRequest()
        print("Ekey PKCE code_verifier (needed for backend token exchange): \(request.codeVerifier)")
        webView.load(URLRequest(url: request.url))
    }

    /// Called when the app resumes via the `focusUri` custom scheme. The WKWebView instance
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

        let frameKind = navigationAction.targetFrame?.isMainFrame == true ? "main" : "subframe"
        print("Ekey NAV[\(frameKind)]: \(url.absoluteString)")

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
            print("Ekey POPUP: \(url.absoluteString)")
            _ = intercept(url)
        }
        return nil
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Ekey didFinish: \(webView.url?.absoluteString ?? "nil")")
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("Ekey didFail: \(error.localizedDescription)")
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("Ekey didFailProvisional: \(error.localizedDescription)")
    }

    /// Returns true if the URL was handed off (redirect completion or app-to-app handoff)
    /// and should not be loaded by the WebView itself.
    private func intercept(_ url: URL) -> Bool {
        if url.absoluteString.hasPrefix(EkeyLoginConfig.redirectUri) {
            onCompleted(url)
            return true
        }

        if !didOpenEkeyApp && EkeyLoginConfig.eKeyAppToAppDomains.contains(where: url.absoluteString.contains) {
            didOpenEkeyApp = true
            UIApplication.shared.open(url) { success in
                print("Ekey app-to-app handoff opened: \(success) — \(url.absoluteString)")
            }
            return true
        }

        return false
    }
}

struct EkeyWebView: UIViewRepresentable {
    let webView: WKWebView

    func makeUIView(context: Context) -> WKWebView {
        webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
