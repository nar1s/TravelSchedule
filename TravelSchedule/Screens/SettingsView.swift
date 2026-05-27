//
//  SettingsView.swift
//  TravelSchedule
//
//  Created by Павел Кузнецов on 27.05.2026.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Настройки")
                    .foregroundStyle(Color(.ypBlack))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color(.ypWhite))
            .navigationTitle("Настройки")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(.ypWhite), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .background(Color(.ypWhite).ignoresSafeArea())
    }
}

#Preview {
    SettingsView()
}
