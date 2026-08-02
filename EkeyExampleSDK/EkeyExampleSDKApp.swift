//
//  EkeyExampleSDKApp.swift
//  EkeyExampleSDK
//
//  Created by Syed Danish  on 30/07/2026.
//

import EkeySDK
import SwiftUI

@main
struct EkeyExampleSDKApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    Ekey.shared.handleOpenURL(url)
                }
        }
    }
}
