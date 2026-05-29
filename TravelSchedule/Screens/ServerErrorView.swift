//
//  ServerErrorView.swift
//  TravelSchedule
//
//  Created by Павел Кузнецов on 27.05.2026.
//

import SwiftUI

struct ServerErrorView: View {
    @Environment(SearchStore.self) private var store

    var body: some View {
        VStack(spacing: 16) {
            Image(.serverError)
                .font(.system(size: 48))

            Text("Ошибка сервера")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Color(.ypBlack))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.ypWhite))
        .task {
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled else { return }
            store.path.removeAll()
            store.carriers = []
            store.carriersError = nil
        }
    }
}

#Preview {
    ServerErrorView()
        .environment(SearchStore.preview)
}
