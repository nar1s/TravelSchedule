//
//  FilterView.swift
//  TravelSchedule
//
//  Created by Павел Кузнецов on 27.05.2026.
//

import SwiftUI

struct FilterView: View {
    @Environment(SearchStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var draft: FilterState = FilterState()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Время отправления")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Color(.ypBlack))
                .padding(.horizontal, 16)
                .padding(.top, 24)
                .padding(.bottom, 16)

            VStack(spacing: 0) {
                ForEach(TimeSlot.allCases) { slot in
                    checkboxRow(slot: slot)
                }
            }
            .padding(.horizontal, 16)

            Text("Показывать варианты с пересадками")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Color(.ypBlack))
                .padding(.horizontal, 16)
                .padding(.top, 24)
                .padding(.bottom, 16)

            VStack(spacing: 0) {
                radioRow(title: "Да", isSelected: draft.showWithTransfers) {
                    draft.showWithTransfers = true
                }
                radioRow(title: "Нет", isSelected: !draft.showWithTransfers) {
                    draft.showWithTransfers = false
                }
            }
            .padding(.horizontal, 16)

            Spacer()

            Button {
                let newFilter = draft
                dismiss()
                Task { await store.applyFilter(newFilter) }
            } label: {
                Text("Применить")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.ypWhiteUniversal)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color(.ypBlue))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
            }
        }
        .background(Color(.ypWhite))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            draft = store.filter
        }
    }

    @ViewBuilder
    private func checkboxRow(slot: TimeSlot) -> some View {
        let isSelected = draft.selectedTimeSlots.contains(slot)

        Button {
            if isSelected {
                draft.selectedTimeSlots.remove(slot)
            } else {
                draft.selectedTimeSlots.insert(slot)
            }
        } label: {
            HStack {
                Text("\(slot.rawValue) \(slot.subtitle)")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(Color(.ypBlack))

                Spacer()

                RoundedRectangle(cornerRadius: 4)
                    .stroke(isSelected ? Color(.ypBlack) : Color(.ypGray), lineWidth: 1.5)
                    .frame(width: 24, height: 24)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(isSelected ? Color(.ypBlack) : Color.clear)
                    )
                    .overlay(
                        Image(systemName: SFSymbol.checkmark)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.ypWhiteUniversal)
                            .opacity(isSelected ? 1 : 0)
                    )
            }
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func radioRow(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(Color(.ypBlack))

                Spacer()

                Circle()
                    .stroke(isSelected ? Color(.ypBlack) : Color(.ypGray), lineWidth: 1.5)
                    .frame(width: 24, height: 24)
                    .background(
                        Circle()
                            .fill(isSelected ? Color(.ypBlack) : Color.clear)
                            .padding(4)
                    )
            }
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    FilterView()
        .environment(SearchStore.preview)
}

