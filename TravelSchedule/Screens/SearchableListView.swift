//
//  SearchableListView.swift
//  TravelSchedule
//
//  Created by Павел Кузнецов on 26.05.2026.
//

import SwiftUI

struct SearchableListView<Item: Identifiable & Hashable>: View {
    let title: String
    let items: [Item]
    let searchableText: (Item) -> String
    let displayText: (Item) -> String
    let onSelect: (Item) -> Void
    let emptyMessage: String

    @State private var searchText = ""
    @Environment(\.colorScheme) private var colorScheme

    private var searchFieldBackground: Color {
        colorScheme == .dark ? Color(uiColor: .tertiarySystemFill) : Color(.ypLightGray)
    }

    init(
        title: String,
        items: [Item],
        searchableText: @escaping (Item) -> String,
        displayText: @escaping (Item) -> String,
        onSelect: @escaping (Item) -> Void,
        emptyMessage: String = "Ничего не найдено"
    ) {
        self.title = title
        self.items = items
        self.searchableText = searchableText
        self.displayText = displayText
        self.onSelect = onSelect
        self.emptyMessage = emptyMessage
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color(.ypGray))

                TextField(
                    "",
                    text: $searchText,
                    prompt: Text("Введите запрос").foregroundStyle(Color(.ypGray))
                )
                .textFieldStyle(.plain)
                .foregroundStyle(.primary)

                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color(.ypGray))
                    }
                }
            }
            .padding(10)
            .background(searchFieldBackground)
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.top, 8)

            SearchableListContent(
                items: items,
                searchableText: searchableText,
                displayText: displayText,
                onSelect: onSelect,
                searchText: $searchText,
                emptyMessage: emptyMessage
            )
        }
        .background(Color(.ypWhite).ignoresSafeArea())
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct SearchableListContent<Item: Identifiable & Hashable>: View {
    let items: [Item]
    let searchableText: (Item) -> String
    let displayText: (Item) -> String
    let onSelect: (Item) -> Void
    @Binding var searchText: String
    let emptyMessage: String

    @Environment(\.dismissSearch) private var dismissSearch

    private var filteredItems: [Item] {
        if searchText.isEmpty {
            return items
        }
        return items.filter { item in
            searchableText(item).localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        if filteredItems.isEmpty && !searchText.isEmpty {
            VStack(spacing: 16) {
                Spacer()
                Text(emptyMessage)
                    .font(.system(size: 24, weight: .bold))
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            List(filteredItems) { item in
                Button(action: {
                    onSelect(item)
                }) {
                    HStack {
                        Text(displayText(item))
                            .font(.system(size: 17, weight: .regular))
                            .foregroundStyle(Color(.ypBlack))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Color(.ypBlack))
                    }
                    .frame(height: 60)
                    .contentShape(Rectangle())
                }
                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color(.ypWhite))
            }
            .scrollContentBackground(.hidden)
            .background(Color(.ypWhite))
            .listStyle(.plain)
        }
    }
}
