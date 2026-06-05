//
//  UserAgreementView.swift
//  TravelSchedule
//
//  Created by Павел Кузнецов on 27.05.2026.
//

import SwiftUI
import WebKit

struct UserAgreementView: View {
    private let agreementURL = URL(string: Constants.agreementURLString)!

    var body: some View {
        WebView(url: agreementURL)
            .ignoresSafeArea(edges: .bottom)
            .navigationTitle("Пользовательское соглашение")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .tabBar)
    }
}

struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Обновления не нужны - URL константа
    }
}

#Preview {
    NavigationStack {
        UserAgreementView()
    }
}
