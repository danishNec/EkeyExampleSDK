import Foundation

/// The result of a completed login: the decoded ID token claims, and the KYC data payload if
/// any `ekyc-bhr-*` scopes were requested and granted.
public struct EkeyIdentityData {
    public let claims: [String: Any]
    public let kycData: [String: Any]?
}

public enum EkeyTokenExchangeError: Error {
    case network(Error)
    case badResponse
    case malformedIdToken
}

/// Performs the token exchange (integration guide §2.2.5) and KYC data fetch (§6.2) directly
/// inside the SDK. This requires `EkeyLoginConfig.clientSecret`, which — unlike everywhere else
/// in this SDK — means a secret credential ships inside the compiled app binary. That's a
/// deliberate trade-off for this sandbox SDK, not an oversight.
/// Mirrors EkeyTokenExchange.kt on the Android SDK.
enum EkeyTokenExchange {
    /// `completion` is always called on the main queue.
    static func exchangeAndFetchKyc(
        code: String,
        codeVerifier: String,
        completion: @escaping (Result<EkeyIdentityData, EkeyTokenExchangeError>) -> Void
    ) {
        let finish: (Result<EkeyIdentityData, EkeyTokenExchangeError>) -> Void = { result in
            DispatchQueue.main.async { completion(result) }
        }

        let params = [
            ("grant_type", "authorization_code"),
            ("code", code),
            ("client_id", EkeyLoginConfig.clientId),
            ("client_secret", EkeyLoginConfig.clientSecret),
            ("code_verifier", codeVerifier),
            ("redirect_uri", EkeyLoginConfig.redirectUri)
        ]

        var request = URLRequest(url: URL(string: EkeyLoginConfig.tokenURL)!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = formURLEncode(params).data(using: .utf8)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                print("[EkeyTokenExchange] Token exchange network error: \(error)")
                finish(.failure(.network(error)))
                return
            }

            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            guard (200...299).contains(statusCode), let data else {
                let errorBody = data.flatMap { String(data: $0, encoding: .utf8) } ?? ""
                print("[EkeyTokenExchange] Token exchange failed: HTTP \(statusCode) from \(EkeyLoginConfig.tokenURL): \(errorBody)")
                finish(.failure(.badResponse))
                return
            }

            guard
                let tokenResponse = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any],
                let idToken = tokenResponse["id_token"] as? String, !idToken.isEmpty
            else {
                finish(.failure(.badResponse))
                return
            }

            guard let claims = decodeJWTPayload(idToken) else {
                finish(.failure(.malformedIdToken))
                return
            }

            let kycDataURLString = claims["urn:oneid:ekyc:bhr:data"] as? String
            let accessToken = (tokenResponse["access_token"] as? String).flatMap { $0.isEmpty ? nil : $0 }

            guard let kycDataURLString, let accessToken else {
                // No KYC scopes granted (or no access_token) — still a successful login, just
                // without a KYC payload to fetch.
                finish(.success(EkeyIdentityData(claims: claims, kycData: nil)))
                return
            }

            fetchKycData(urlString: kycDataURLString, accessToken: accessToken) { kycData in
                finish(.success(EkeyIdentityData(claims: claims, kycData: kycData)))
            }
        }.resume()
    }

    private static func fetchKycData(
        urlString: String,
        accessToken: String,
        completion: @escaping ([String: Any]?) -> Void
    ) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, _ in
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            guard (200...299).contains(statusCode), let data else {
                completion(nil)
                return
            }
            completion((try? JSONSerialization.jsonObject(with: data)) as? [String: Any])
        }.resume()
    }

    /// Decodes a JWT's payload segment WITHOUT verifying its signature. Fine for reading the
    /// KYC data URL claim; per integration guide §2.2.6, a production system should still
    /// verify the signature (against eKey's JWKS), `iss`, `aud`, `exp`, and `iat` before
    /// trusting any claim as authenticated user identity.
    private static func decodeJWTPayload(_ jwt: String) -> [String: Any]? {
        let segments = jwt.split(separator: ".")
        guard segments.count >= 2 else { return nil }

        var base64 = String(segments[1])
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        while base64.count % 4 != 0 { base64 += "=" }

        guard let decoded = Data(base64Encoded: base64) else { return nil }
        return (try? JSONSerialization.jsonObject(with: decoded)) as? [String: Any]
    }

    private static func formURLEncode(_ params: [(String, String)]) -> String {
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: "-._~")
        return params
            .map { key, value in
                let k = key.addingPercentEncoding(withAllowedCharacters: allowed) ?? key
                let v = value.addingPercentEncoding(withAllowedCharacters: allowed) ?? value
                return "\(k)=\(v)"
            }
            .joined(separator: "&")
    }
}
