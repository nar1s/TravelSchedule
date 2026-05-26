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
        SearchableListContent(
            items: items,
            searchableText: searchableText,
            displayText: displayText,
            onSelect: onSelect,
            searchText: $searchText
        )
        .searchable(text: $searchText, prompt: "Поиск")
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
                dismissSearch()
                onSelect(item)
            }) {
                Text(displayText(item))
                    .foregroundStyle(.primary)
            }
        }
    }
}
