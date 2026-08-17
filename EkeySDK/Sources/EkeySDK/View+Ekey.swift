import SwiftUI

public extension View {
    /// Forwards every URL the app is opened with to `Ekey.shared.handleOpenURL(_:)`, so the SDK
    /// can catch the `focus_uri` callback and resume the login flow. Apply this once, to
    /// whatever view is inside your `WindowGroup`.
    ///
    /// ```swift
    /// WindowGroup {
    ///     ContentView().ekeyURLHandling()
    /// }
    /// ```
    ///
    /// iOS only ever delivers URL-open events to the app itself (never directly to a
    /// framework), so this one call is unavoidable — but it's the only place `Ekey` is
    /// mentioned in app code for this purpose.
    func ekeyURLHandling() -> some View {
        onOpenURL { url in
            Ekey.shared.handleOpenURL(url)
        }
    }
}
