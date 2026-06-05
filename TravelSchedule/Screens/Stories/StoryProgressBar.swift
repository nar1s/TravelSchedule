//
//  StoryProgressBar.swift
//  TravelSchedule
//
//  Created by Павел Кузнецов on 05.06.2026.
//

import SwiftUI

struct StoryProgressBar: View {
    let count: Int
    let currentIndex: Int
    let progress: Double

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<count, id: \.self) { index in
                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.ypWhiteUniversal)
                        Capsule()
                            .fill(Color.ypBlue)
                            .frame(width: width(for: index, totalWidth: proxy.size.width))
                    }
                }
                .frame(height: 6)
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 28)
    }

    private func width(for index: Int, totalWidth: CGFloat) -> CGFloat {
        if index < currentIndex {
            return totalWidth
        } else if index == currentIndex {
            return totalWidth * CGFloat(progress)
        } else {
            return 0
        }
    }
}
