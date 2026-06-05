//
//  SettingsView.swift
//  TravelSchedule
//
//  Created by Павел Кузнецов on 27.05.2026.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkTheme") private var isDarkTheme = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(spacing: 16) {
                    HStack {
                        Text("Темная тема")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundStyle(Color(.ypBlack))
                        Spacer()
                        Toggle("", isOn: $isDarkTheme)
                            .labelsHidden()
                            .tint(Color(.ypBlue))
                    }

                    NavigationLink(destination: UserAgreementView()) {
                        HStack {
                            Text("Пользовательское соглашение")
                                .font(.system(size: 17, weight: .regular))
                                .foregroundStyle(Color(.ypBlack))
                            Spacer()
                            Image(systemName: SFSymbol.chevronRight)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Color(.ypBlack))
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)

                Spacer()

                VStack(spacing: 8) {
                    Text("Приложение использует API «Яндекс.Расписания»")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(Color(.ypBlack))
                        .multilineTextAlignment(.center)

                    Text("Версия 1.0 (beta)")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(Color(.ypBlack))
                        .multilineTextAlignment(.center)
                }
                .padding(.bottom, 32)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color(.ypWhite))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(.ypWhite), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .background(Color(.ypWhite).ignoresSafeArea())
        .preferredColorScheme(isDarkTheme ? .dark : .light)
    }
}

#Preview {
    SettingsView()
}
