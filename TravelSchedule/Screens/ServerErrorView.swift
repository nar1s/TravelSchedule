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
            Image(systemName: "exclamationmark.icloud")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("Ошибка сервера")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
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
