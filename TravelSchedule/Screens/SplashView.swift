//
//  SplashView.swift
//  TravelSchedule
//
//  Created by Павел Кузнецов on 25.05.2026.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        Image("Splash Screen")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .ignoresSafeArea()
    }
}

#Preview {
    SplashView()
}
