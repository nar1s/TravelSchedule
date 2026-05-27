//
//  NoInternetView.swift
//  TravelSchedule
//
//  Created by Павел Кузнецов on 27.05.2026.
//

import SwiftUI

struct NoInternetView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("Нет интернета")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview {
    NoInternetView()
}
