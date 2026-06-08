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
    @StateObject private var viewModel: StoriesViewerViewModel
    
    init(
        group: StoryGroup,
        onViewed: @escaping () -> Void,
        onFinished: @escaping () -> Void
    ) {
        self.group = group
        self.onViewed = onViewed
        let viewModel = StoriesViewerViewModel(
            group: group,
            onFinished: onFinished
        )
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            Color.ypBlackUniversal.ignoresSafeArea()

            Image(viewModel.currentStory.imageName)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 40))

            VStack {
                StoryProgressBar(
                    count: group.stories.count,
                    currentIndex: viewModel.currentIndex,
                    progress: viewModel.progress
                )
                .padding(.top, 8)

                Spacer()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.currentStory.title)
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(.white)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(2)

                    Text(viewModel.currentStory.description)
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
                    .onTapGesture { viewModel.previous() }

                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if !viewModel.next() {
                            dismiss()
                        }
                    }
            }

            VStack {
                HStack {
                    Spacer()
                    Button {
                        viewModel.stop()
                        dismiss()
                    } label: {
                        Image(systemName: SFSymbol.xmark)
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
                    viewModel.pause()
                }
                .onEnded { value in
                    let horizontalTranslation = value.translation.width
                    if horizontalTranslation < -50 {
                        if !viewModel.next() {
                            dismiss()
                        }
                    } else if horizontalTranslation > 50 {
                        viewModel.previous()
                    }
                    viewModel.resume()
                }
        )
        .onAppear { viewModel.start() }
        .onDisappear {
            viewModel.stop()
            onViewed()
        }
    }
}
