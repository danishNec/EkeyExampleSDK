import Foundation

public enum EkeyLoginResult {
    /// The WebView reached the configured redirect_uri and its `state` matched the one this
    /// SDK generated for the request. `redirectURL` carries the `code`/`state` query
    /// parameters, and `codeVerifier` is the PKCE verifier generated for this same request —
    /// your back-end needs both to exchange the code for tokens (integration guide §2.2.5,
    /// which lists `code_verifier` as a required token-exchange parameter). This SDK never
    /// performs the token exchange itself, since that requires the client_secret, which must
    /// not ship inside a mobile app.
    case completed(redirectURL: URL, codeVerifier: String)

    /// The user dismissed the login screen before completing the flow.
    case cancelled

    /// The flow reached redirect_uri but failed validation and was not treated as a
    /// successful login.
    case failed(EkeyLoginError)
}

public enum EkeyLoginError: Error {
    /// redirect_uri's `state` parameter was missing or didn't match the `state` this SDK
    /// generated for the original authorization request — a possible CSRF/session-mixup,
    /// so the result is rejected rather than treated as a successful login.
    case stateMismatch
}
