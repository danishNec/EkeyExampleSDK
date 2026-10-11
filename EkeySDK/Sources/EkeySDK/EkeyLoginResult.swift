import Foundation

public enum EkeyLoginResult {
    /// The WebView reached the configured redirect_uri, its `state` matched the one this SDK
    /// generated for the request, and the SDK successfully exchanged the code for tokens.
    /// `redirectURL` carries the `code`/`state` query parameters, `codeVerifier` is the PKCE
    /// verifier generated for this same request, and `identity` carries the decoded ID token
    /// claims plus KYC data (if granted). See EkeyTokenExchange.swift for the security
    /// trade-off this implies (client_secret ships inside the app binary).
    case completed(redirectURL: URL, codeVerifier: String, identity: EkeyIdentityData)

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

    /// The code-for-token exchange or KYC data fetch failed. See `EkeyTokenExchangeError`.
    case tokenExchangeFailed(EkeyTokenExchangeError)
}
