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
            Image(.noInternet)
                .font(.system(size: 48))

            Text("Нет интернета")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Color(.ypBlack))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.ypWhite))
    }
}

#Preview {
    NoInternetView()
}
