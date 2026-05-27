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

    @State private var searchText = ""

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Поиск", text: $searchText)
                    .textFieldStyle(.plain)
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(10)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.top, 8)

            SearchableListContent(
                items: items,
                searchableText: searchableText,
                displayText: displayText,
                onSelect: onSelect,
                searchText: $searchText
            )
        }
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
        List(filteredItems) { item in
            Button(action: {
                onSelect(item)
            }) {
                Text(displayText(item))
                    .foregroundStyle(.primary)
            }
        }
        .listStyle(.plain)
    }
}
