//
//  StoryModel.swift
//  TravelSchedule
//
//  Created by Павел Кузнецов on 05.06.2026.
//

import Foundation

struct Story: Identifiable, Hashable {
    let id: UUID = UUID()
    let imageName: String
    let title: String
    let description: String
}

struct StoryGroup: Identifiable, Hashable {
    let id: UUID = UUID()
    let previewImageName: String
    let stories: [Story]
}

enum StoriesData {
    static let groups: [StoryGroup] = (1...9).map { index in
        let preview = "story_preview_\(index)"
        let firstStory = Story(
            imageName: "story_\((index - 1) * 2 + 1)",
            title: "Text Text Text Text Text Text Text Text Text Text",
            description: "Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text"
        )
        let secondStory = Story(
            imageName: "story_\(index * 2)",
            title: "Text Text Text Text Text Text Text Text Text Text",
            description: "Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text"
        )
        return StoryGroup(previewImageName: preview, stories: [firstStory, secondStory])
    }
}
