//
//  CarrierCardView.swift
//  TravelSchedule
//
//  Created by Павел Кузнецов on 27.05.2026.
//

import SwiftUI

struct CarrierCardView: View {
    let carrier: Carrier

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM"
        return formatter.string(from: carrier.departure)
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack(alignment: .top) {
                HStack(spacing: 8) {
                    logoView
                        .frame(width: 38, height: 38)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(carrier.title)
                            .font(.system(size: 17, weight: .regular))
                            .foregroundStyle(Color(.ypBlackUniversal))
                            .lineLimit(1)

                        if carrier.hasTransfers {
                            Text("С пересадкой")
                                .font(.system(size: 12))
                                .foregroundStyle(Color(.ypRed))
                        }
                    }
                }

                Spacer()

                Text(formattedDate)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(Color(.ypBlackUniversal))
            }

            HStack(spacing: 8) {
                Text(carrier.departure, style: .time)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(Color(.ypBlackUniversal))

                Rectangle()
                    .fill(Color(.ypGray))
                    .frame(height: 1)

                Text(durationText(from: carrier.duration))
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(Color(.ypBlackUniversal))

                Rectangle()
                    .fill(Color(.ypGray))
                    .frame(height: 1)

                Text(carrier.arrival, style: .time)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(Color(.ypBlackUniversal))
            }
        }
        .padding(14)
        .background(Color(.ypLightGray))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private var logoView: some View {
        if let url = carrier.logoURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFit()
                default:
                    placeholderLogo
                }
            }
        } else {
            placeholderLogo
        }
    }

    private var placeholderLogo: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(.systemGray5))
            .overlay {
                Image(systemName: SFSymbol.tramFill)
                    .foregroundStyle(.secondary)
            }
    }

    private func durationText(from interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = Int(interval) % 3600 / 60
        if hours > 0 {
            return "\(hours) ч \(minutes) мин"
        }
        return "\(minutes) мин"
    }
}

#Preview {
    CarrierCardView(carrier: Carrier(
        id: "1",
        title: "РЖД",
        logoURL: nil,
        departure: Date(),
        arrival: Date().addingTimeInterval(7200),
        duration: 7200,
        hasTransfers: false
    ))
}
