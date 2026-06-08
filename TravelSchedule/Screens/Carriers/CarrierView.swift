//
//  CarrierView.swift
//  TravelSchedule
//
//  Created by Павел Кузнецов on 27.05.2026.
//

import SwiftUI

struct CarrierView: View {
    let carrier: Carrier
    
    @StateObject private var viewModel: CarrierViewModel

    init(carrier: Carrier, networkClient: any NetworkClientProtocol) {
        self.carrier = carrier
        _viewModel = StateObject(wrappedValue: CarrierViewModel(
            carrier: carrier,
            networkClient: networkClient
        ))
    }

    var body: some View {
        ZStack {
            Color(.ypWhite)
                .ignoresSafeArea()
            
            if viewModel.isLoading {
                ProgressView()
            } else if viewModel.hasError {
                errorView
            } else {
                content(details: viewModel.details)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(Color(.ypWhite), for: .navigationBar)
        .safeAreaInset(edge: .top, spacing: 0) {
            customNavigationBar
        }
        .task {
            await viewModel.load()
        }
    }
    
    // MARK: - Custom Navigation Bar
    
    private var customNavigationBar: some View {
        Text("Информация о перевозчике")
            .font(.system(size: 17, weight: .bold))
            .foregroundStyle(Color(.ypBlack))
            .lineLimit(1)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .overlay(alignment: .leading) {
                BackButton()
                    .padding(.leading, 16)
            }
            .background(Color(.ypWhite))
    }
    
    // MARK: - Private Views
    
    private func content(details: CarrierDetails?) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                logoView
                    .frame(maxWidth: .infinity)
                    .padding(.top, 24)
                
                Text(carrier.title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color(.ypBlack))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                contactInfoView(details: details)
            }
            .padding(.horizontal, 16)
        }
    }
    
    private var errorView: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(Color(.ypGray))
            
            Text("Не удалось загрузить информацию")
                .font(.system(size: 17))
                .foregroundStyle(Color(.ypBlack))
        }
    }
    
    @ViewBuilder
    private var logoView: some View {
        if let url = carrier.logoURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(height: 140)
                        .frame(maxWidth: .infinity)
                default:
                    placeholderLogo
                }
            }
        } else {
            placeholderLogo
        }
    }
    
    private var placeholderLogo: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(Color(.systemGray5))
            .frame(width: 140, height: 140)
            .overlay {
                Image(systemName: SFSymbol.tramFill)
                    .font(.system(size: 56))
                    .foregroundStyle(.secondary)
            }
    }
    
    @ViewBuilder
    private func contactInfoView(details: CarrierDetails?) -> some View {
        if let details, details.hasAnyInfo {
            VStack(alignment: .leading, spacing: 16) {
                if !details.email.isEmpty {
                    contactRow(title: "E-mail", value: details.email)
                }
                
                if !details.phone.isEmpty {
                    contactRow(title: "Телефон", value: details.phone)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private func contactRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(Color(.ypBlack))
            
            Text(value)
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(Color(.ypBlue))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Preview

#Preview("CarrierView") {
    return NavigationStack {
        CarrierView(
            carrier: Carrier(
                id: "1",
                title: "РЖД",
                logoURL: URL(string: ""),
                departure: Date(),
                arrival: Date().addingTimeInterval(7200),
                duration: 7200,
                hasTransfers: false,
                carrierCode: "12"
            ),
            networkClient: AppDependencies.preview.networkClient
        )
        .environment(SearchStore.preview)
        .environment(AppDependencies.preview)
    }
}
