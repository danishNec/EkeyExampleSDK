//
//  EkeyLoginView.swift
//  EkeyExampleSDK
//
//  Created by Syed Danish  on 30/07/2026.
//

import SwiftUI

struct EkeyLoginView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var controller: EkeyWebViewController

    init(onCompleted: @escaping (URL) -> Void) {
        _controller = StateObject(wrappedValue: EkeyWebViewController(onCompleted: onCompleted))
    }

    var body: some View {
        NavigationStack {
            EkeyWebView(webView: controller.webView)
                .navigationTitle("Ekey Login")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") { dismiss() }
                    }
                }
        }
        .onAppear { controller.start() }
        .onReceive(NotificationCenter.default.publisher(for: .ekeyLoginDidResume)) { _ in
            controller.resume()
        }
    }
}
