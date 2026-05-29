//
//  BackButton.swift
//  TravelSchedule
//
//  Created by Павел Кузнецов on 27.05.2026.
//

import SwiftUI

struct BackButton: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Button(action: { dismiss() }) {
            Image(systemName: SFSymbol.chevronLeft)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color(.ypBlack))
        }
    }
}
