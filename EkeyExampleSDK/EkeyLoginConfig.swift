//
//  EkeyLoginConfig.swift
//  EkeyExampleSDK
//
//  Created by Syed Danish  on 30/07/2026.
//

import CryptoKit
import Foundation
import Security

struct EkeyAuthorizationRequest {
    let url: URL
    let codeVerifier: String
    let state: String	
}

enum EkeyLoginConfig {
    static let authorizationBaseURL = "https://login.test.ekey-b.com/oidc/auth"
    static let clientId = "iZ4lBvruWxmSYqSWw-Wcf"
    static let redirectUri = "https://mobileapp.uat.necremit.com/RedirectURIC/WS_MobileAPICALLS.asmx"
    static let scope = "openid id-* id-*-additional id-*-photo ekyc-bhr-name ekyc-bhr-address ekyc-bhr-birth ekyc-bhr-nationality ekyc-bhr-contact ekyc-bhr-employment ekyc-bhr-passport ekyc-bhr-resident ekyc-bhr-photo ekyc-bhr-disability liveness_proof liveness_photo"
    static let customURLScheme = "necekey"
    static let focusUri = "\(customURLScheme)://callback"
    /// Per the integration guide's Environments section: production's App-to-App launch
    /// domain is app.ekey.bh, while the test/UAT environment (used here) hands t
    /// mobileLogin URL back on tools.test.ekey-b.com instead.
    static let eKeyAppToAppDomains = ["app.ekey.bh", "tools.test.ekey-b.com"]
    static func makeAuthorizationRequest() -> EkeyAuthorizationRequest {
        let codeVerifier = randomURLSafeString(byteCount: 32)
        let codeChallenge = Data(SHA256.hash(data: Data(codeVerifier.utf8))).base64URLEncodedString()
        let state = randomURLSafeString(byteCount: 16)

        var components = URLComponents(string: authorizationBaseURL)!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: scope),
            URLQueryItem(name: "redirect_uri", value: redirectUri),
            URLQueryItem(name: "code_challenge", value: codeChallenge),
            URLQueryItem(name: "state", value: state),
            URLQueryItem(name: "code_challenge_method", value: "S256"),
            URLQueryItem(name: "response_mode", value: "query"),
            URLQueryItem(name: "prompt", value: "consent"),
            URLQueryItem(name: "focus_uri", value: focusUri)
        ]

        return EkeyAuthorizationRequest(url: components.url!, codeVerifier: codeVerifier, state: state)
    }

    private static func randomURLSafeString(byteCount: Int) -> String {
        var bytes = [UInt8](repeating: 0, count: byteCount)
        _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        return Data(bytes).base64URLEncodedString()
    }
}

private extension Data {
    func base64URLEncodedString() -> String {
        base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
