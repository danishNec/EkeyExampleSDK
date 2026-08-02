import Foundation

public enum EkeyLoginResult {
    /// The WebView reached the configured redirect_uri. `redirectURL` carries the
    /// `code`/`state` query parameters — exchange them for tokens from your back-end
    /// (integration guide §2.2.5). This SDK never performs the token exchange itself,
    /// since that requires the client_secret, which must not ship inside a mobile app.
    case completed(redirectURL: URL)

    /// The user dismissed the login screen before completing the flow.
    case cancelled
}
