//
//  StoriesViewerViewModel.swift
//  TravelSchedule
//
//  Created by Павел Кузнецов on 08.06.2026.
//

import Foundation
import Combine

@MainActor
final class StoriesViewerViewModel: ObservableObject {
    @Published private(set) var currentIndex: Int = 0
    @Published private(set) var progress: Double = 0
    @Published private(set) var isPaused: Bool = false

    let group: StoryGroup
    let duration: Double
    let tick: Double

    private let onStoriesFinished: @MainActor () -> Void

    private var timerTask: Task<Void, Never>?

    init(
        group: StoryGroup,
        duration: Double = 5.0,
        tick: Double = 0.05,
        onStoriesFinished: @escaping @MainActor () -> Void = {}
    ) {
        self.group = group
        self.duration = duration
        self.tick = tick
        self.onStoriesFinished = onStoriesFinished
    }

    deinit {
        timerTask?.cancel()
    }

    // MARK: - Computed

    var currentStory: Story {
        group.stories[currentIndex]
    }

    var hasNext: Bool {
        currentIndex < group.stories.count - 1
    }

    var hasPrevious: Bool {
        currentIndex > 0
    }

    func start() {
        stop()
        timerTask = Task { @MainActor [weak self] in
            while !Task.isCancelled {
                let tick = self?.tick ?? 0.05
                try? await Task.sleep(nanoseconds: UInt64(tick * 1_000_000_000))
                guard let self else { return }
                self.tickProgress()
            }
        }
    }

    func stop() {
        timerTask?.cancel()
        timerTask = nil
    }

    func pause() {
        guard !isPaused else { return }
        isPaused = true
        stop()
    }

    func resume() {
        guard isPaused else { return }
        isPaused = false
        start()
    }

    @discardableResult
    func next() -> Bool {
        if hasNext {
            currentIndex += 1
            progress = 0
            return true
        } else {
            stop()
            return false
        }
    }

    @discardableResult
    func previous() -> Bool {
        if hasPrevious {
            currentIndex -= 1
            progress = 0
            return true
        } else {
            progress = 0
            return false
        }
    }

    private func tickProgress() {
        guard !isPaused else { return }
        progress += tick / duration
        if progress >= 1.0 {
            if hasNext {
                currentIndex += 1
                progress = 0
            } else {
                stop()
                onStoriesFinished()
            }
        }
    }
}
