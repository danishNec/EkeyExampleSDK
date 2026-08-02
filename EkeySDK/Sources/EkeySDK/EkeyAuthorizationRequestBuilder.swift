import CryptoKit
import Foundation
import Security

struct EkeyAuthorizationRequest {
    let url: URL
    let codeVerifier: String
    let state: String
}

enum EkeyAuthorizationRequestBuilder {
    static func makeRequest() -> EkeyAuthorizationRequest {
        let codeVerifier = randomURLSafeString(byteCount: 32)
        let codeChallenge = Data(SHA256.hash(data: Data(codeVerifier.utf8))).base64URLEncodedString()
        let state = randomURLSafeString(byteCount: 16)

        var components = URLComponents(string: EkeyLoginConfig.authorizationBaseURL)!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: EkeyLoginConfig.clientId),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: EkeyLoginConfig.scope),
            URLQueryItem(name: "redirect_uri", value: EkeyLoginConfig.redirectUri),
            URLQueryItem(name: "code_challenge", value: codeChallenge),
            URLQueryItem(name: "state", value: state),
            URLQueryItem(name: "code_challenge_method", value: "S256"),
            URLQueryItem(name: "response_mode", value: "query"),
            URLQueryItem(name: "prompt", value: "consent"),
            URLQueryItem(name: "focus_uri", value: EkeyLoginConfig.focusUri)
        ]

        return EkeyAuthorizationRequest(url: components.url!, codeVerifier: codeVerifier, state: state)
    }

    private static func randomURLSafeString(byteCount: Int) -> String {
        var bytes = [UInt8](repeating: 0, count: byteCount)
        _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        return Data(bytes).base64URLEncodedString()
    }
}

extension Data {
    func base64URLEncodedString() -> String {
        base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
