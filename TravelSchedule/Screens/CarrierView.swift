//
//  CarrierView.swift
//  TravelSchedule
//
//  Created by Павел Кузнецов on 27.05.2026.
//

import SwiftUI
struct CarrierView: View {
    let carrierName: String

    var body: some View {
        VStack(spacing: 20) {
            Text(carrierName)
                .font(.title)
                .fontWeight(.bold)
        }
        .navigationTitle("Перевозчик")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        CarrierView(carrierName: "РЖД")
    }
}

