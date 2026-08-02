	//
//  ContentView.swift
//  EkeyExampleSDK
//
//  Created by Syed Danish  on 30/07/2026.
//

import SwiftUI

struct ContentView: View {
    @State private var showingEkeyLogin = false

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, NEC testing Flow!")
                .font(.title2)
                .fontWeight(.semibold)
            Button {
                print("Initiate Ekey Flow tapped")
                showingEkeyLogin = true
            } label: {
                Text("Initiate Ekey Flow")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
            }
            .background(
                LinearGradient(
                    colors: [Color.blue, Color.indigo],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(color: .blue.opacity(0.4), radius: 8, y: 4)
            .padding(.horizontal, 32)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [Color(.systemBackground), Color.blue.opacity(0.08)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .sheet(isPresented: $showingEkeyLogin) {
            EkeyLoginView { url in
                print("Ekey login completed: \(url.absoluteString)")
                showingEkeyLogin = false
            }
        }
    }
}

#Preview {
    ContentView()
}
