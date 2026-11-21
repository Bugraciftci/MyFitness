//
//  ExerciseMotionPlayerView.swift
//  MyFitness
//

import SwiftUI
import Combine

/// Interactive 2-frame exercise demonstration viewer that smoothly cycles between
/// the start position (`0.jpg`) and peak contraction (`1.jpg`) from `free-exercise-db`.
struct ExerciseMotionPlayerView: View {
    let exercise: Exercise

    @State private var frames: [UIImage] = []
    @State private var currentFrameIndex = 0
    @State private var isPlaying = true
    @State private var isLoading = true

    private let timer = Timer.publish(every: 1.15, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottom) {
                // Visual Frame Stage
                ZStack {
                    Color.black.opacity(0.92)

                    if let activeImage = frames[safe: currentFrameIndex] {
                        Image(uiImage: activeImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .id(currentFrameIndex)
                            .transition(.opacity)
                            .animation(.easeInOut(duration: 0.35), value: currentFrameIndex)
                    } else if isLoading {
                        VStack(spacing: 10) {
                            ProgressView()
                                .tint(.white)
                            Text("Loading form guide...")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.75))
                        }
                    } else {
                        VStack(spacing: 8) {
                            Image(systemName: exercise.muscleGroup.symbolName)
                                .font(.system(size: 40))
                                .foregroundStyle(AppTheme.accentColor(for: exercise.muscleGroup))
                            Text("Offline preview unavailable")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.75))
                        }
                    }
                }
                .frame(height: 270)
                .clipped()

                // Bottom Overlay Control Pill
                if !frames.isEmpty {
                    HStack(spacing: 12) {
                        Button {
                            isPlaying.toggle()
                            HapticEngine.impact(.light)
                        } label: {
                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.white)
                                .frame(width: 30, height: 30)
                                .background(AppTheme.brandAccent, in: Circle())
                        }
                        .accessibilityLabel(isPlaying ? "Pause animation" : "Play animation")

                        VStack(alignment: .leading, spacing: 2) {
                            Text(currentFrameIndex == 0 ? "Phase 1 · Starting Position" : "Phase 2 · Peak Contraction")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.white)
                            Text("Tap phase pills to inspect form")
                                .font(.caption2)
                                .foregroundStyle(.white.opacity(0.72))
                        }

                        Spacer()

                        if frames.count > 1 {
                            HStack(spacing: 6) {
                                ForEach(0..<frames.count, id: \.self) { index in
                                    Button {
                                        isPlaying = false
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            currentFrameIndex = index
                                        }
                                        HapticEngine.impact(.soft)
                                    } label: {
                                        Text("\(index + 1)")
                                            .font(.caption2.weight(.bold))
                                            .foregroundStyle(currentFrameIndex == index ? .black : .white)
                                            .frame(width: 24, height: 24)
                                            .background(
                                                currentFrameIndex == index ? Color.white : Color.white.opacity(0.2),
                                                in: Circle()
                                            )
                                    }
                                    .accessibilityLabel("Show phase \(index + 1)")
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial)
                    .environment(\.colorScheme, .dark)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.lg, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.lg, style: .continuous)
                    .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
            )
        }
        .onReceive(timer) { _ in
            guard isPlaying, frames.count > 1 else { return }
            withAnimation(.easeInOut(duration: 0.35)) {
                currentFrameIndex = (currentFrameIndex + 1) % frames.count
            }
        }
        .task(id: exercise.id) {
            await loadAllFrames()
        }
    }

    private func loadAllFrames() async {
        isLoading = true
        currentFrameIndex = 0
        let urls = exercise.imageURLs
        guard !urls.isEmpty else {
            frames = []
            isLoading = false
            return
        }

        var loaded: [UIImage] = []
        for url in urls {
            if let img = await RemoteImageCache.shared.image(for: url) {
                loaded.append(img)
            }
        }
        frames = loaded
        isLoading = false
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    ExerciseMotionPlayerView(exercise: .sample)
        .padding()
}
