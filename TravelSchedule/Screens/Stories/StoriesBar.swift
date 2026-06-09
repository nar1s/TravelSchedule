//
//  StoriesBar.swift
//  TravelSchedule
//
//  Created by Павел Кузнецов on 05.06.2026.
//

import SwiftUI

struct StoriesBar: View {
    let groups: [StoryGroup] = StoriesData.groups
    @State private var selectedGroup: StoryGroup?
    
    @AppStorage("viewedStoryGroups") private var viewedGroupsJSON: String = "[]"
    
    private var viewedGroups: Set<UUID> {
        guard
            let data = viewedGroupsJSON.data(using: .utf8),
            let ids = try? JSONDecoder().decode([UUID].self, from: data)
        else {
            return []
        }
        return Set(ids)
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(groups) { group in
                    let isViewed = viewedGroups.contains(group.id)
                    Button {
                        selectedGroup = group
                    } label: {
                        Image(group.previewImageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 92, height: 140)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        
                            .overlay(alignment: .bottomLeading) {
                                Text(group.stories.first?.title ?? "")
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundStyle(.white)
                                    .lineLimit(3)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .padding(8)
                            }
                        
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .strokeBorder(
                                        isViewed ? Color.clear : Color.ypBlue,
                                        lineWidth: 4
                                    )
                            )
                            .opacity(isViewed ? 0.5 : 1.0)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .fullScreenCover(item: $selectedGroup) { group in
            StoriesViewer(
                group: group,
                onStoryGroupViewed: {
                    var current = viewedGroups
                    current.insert(group.id)
                    if
                        let data = try? JSONEncoder().encode(Array(current)),
                        let str = String(data: data, encoding: .utf8)
                    {
                        viewedGroupsJSON = str
                    }
                },
                onStoriesFinished: {
                    selectedGroup = nil
                }
            )
        }
    }
}
