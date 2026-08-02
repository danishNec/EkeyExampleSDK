//
//  EkeyExampleSDKApp.swift
//  EkeyExampleSDK
//
//  Created by Syed Danish  on 30/07/2026.
//

import SwiftUI

@main
struct EkeyExampleSDKApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    print("Ekey focus URI received: \(url.absoluteString)")
                    NotificationCenter.default.post(name: .ekeyLoginDidResume, object: url)
                }
        }
    }
}

extension Notification.Name {
    static let ekeyLoginDidResume = Notification.Name("ekeyLoginDidResume")
}
