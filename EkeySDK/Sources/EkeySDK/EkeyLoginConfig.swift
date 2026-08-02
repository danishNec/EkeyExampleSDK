import Foundation

/// All eKey 2.0 integration config lives here, inside the SDK. Consuming apps only ever call
/// `EkeySDK.shared.initiateLogin(from:completion:)` and `EkeySDK.shared.handleOpenURL(_:)` —
/// nothing to configure from the app side.
enum EkeyLoginConfig {
    static let authorizationBaseURL = "https://login.test.ekey-b.com/oidc/auth"
    static let clientId = "iZ4lBvruWxmSYqSWw-Wcf"
    static let redirectUri = "https://mobileapp.uat.necremit.com/RedirectURIC/WS_MobileAPICALLS.asmx"
    static let scope = "openid id-* id-*-additional id-*-photo ekyc-bhr-name ekyc-bhr-address " +
        "ekyc-bhr-birth ekyc-bhr-nationality ekyc-bhr-contact ekyc-bhr-employment " +
        "ekyc-bhr-passport ekyc-bhr-resident ekyc-bhr-photo ekyc-bhr-disability " +
        "liveness_proof liveness_photo"
    static let customURLScheme = "necekey"
    static let focusUri = "\(customURLScheme)://callback"

    // Per the integration guide's Environments section: production's App-to-App launch
    // domain is app.ekey.bh, while the test/UAT environment (used here) hands the
    // mobileLogin URL back on tools.test.ekey-b.com instead.
    static let appToAppDomains = ["app.ekey.bh", "tools.test.ekey-b.com"]
}
