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
        ZStack {
            Color(.ypWhite)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text(carrierName)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(Color(.ypBlack))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .navigationTitle("Перевозчик")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(Color(.ypWhite), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton()
            }
        }
    }
}

#Preview {
    NavigationStack {
        CarrierView(carrierName: "РЖД")
    }
}

