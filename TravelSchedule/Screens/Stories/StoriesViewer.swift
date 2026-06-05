//
//  StoriesViewer.swift
//  TravelSchedule
//
//  Created by Павел Кузнецов on 05.06.2026.
//

import SwiftUI

struct StoriesViewer: View {
    let group: StoryGroup
    let onViewed: () -> Void
    
    @Environment(\.dismiss) private var dismiss

    @State private var currentIndex: Int = 0
    @State private var progress: Double = 0
    @State private var timerTask: Task<Void, Never>?
    @State private var isPaused: Bool = false

    private let duration: Double = 5.0
    private let tick: Double = 0.05
    
    private var currentStory: Story {
        group.stories[currentIndex]
    }

    var body: some View {
        ZStack {
            Color.ypBlackUniversal.ignoresSafeArea()

            Image(currentStory.imageName)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 40))

            VStack {
                StoryProgressBar(
                    count: group.stories.count,
                    currentIndex: currentIndex,
                    progress: progress
                )
                .padding(.top, 8)

                Spacer()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(currentStory.title)
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(.white)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(2)

                    Text(currentStory.description)
                        .font(.system(size: 20, weight: .regular))
                        .foregroundStyle(.white)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(3)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }

            HStack(spacing: 0) {
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .onTapGesture { previous() }

                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .onTapGesture { next() }
            }

            VStack {
                HStack {
                    Spacer()
                    Button {
                        stop()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color(.ypWhiteUniversal))
                            .frame(width: 30, height: 30)
                            .background(Color(.ypBlackUniversal))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 50)

                Spacer()
            }
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPaused {
                        isPaused = true
                        pause()
                    }
                }
                .onEnded { value in
                    let horizontalTranslation = value.translation.width
                    if horizontalTranslation < -50 {
                        next()
                    }
                    else if horizontalTranslation > 50 {
                        previous()
                    }
                    isPaused = false
                    resume()
                }
        )
        .onAppear { start() }
        .onDisappear {
            stop()
            onViewed()
        }
    }

    private func start() {
        stop()
        timerTask = Task { @MainActor in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: UInt64(tick * 1_000_000_000))
                if !isPaused {
                    progress += tick / duration
                    if progress >= 1.0 {
                        if currentIndex < group.stories.count - 1 {
                            currentIndex += 1
                            progress = 0
                        } else {
                            stop()
                            dismiss()
                            return
                        }
                    }
                }
            }
        }
    }

    private func stop() {
        timerTask?.cancel()
        timerTask = nil
    }

    private func pause() {
        stop()
    }

    private func resume() {
        if !isPaused {
            start()
        }
    }

    private func next() {
        if currentIndex < group.stories.count - 1 {
            currentIndex += 1
            progress = 0
        } else {
            stop()
            dismiss()
        }
    }

    private func previous() {
        if currentIndex > 0 {
            currentIndex -= 1
            progress = 0
        } else {
            progress = 0
        }
    }
}
