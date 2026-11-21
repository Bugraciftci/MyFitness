//
//  AsyncCachedImage.swift
//  MyFitness
//

import SwiftUI

/// Lazy-loading image view backed by `RemoteImageCache` with smooth crossfade and SF Symbol fallback.
struct AsyncCachedImage: View {
    let url: URL?
    var contentMode: ContentMode = .fill
    var fallbackSymbol: String = "figure.strengthtraining.traditional"

    @State private var loadedImage: UIImage?
    @State private var isLoading = false

    var body: some View {
        ZStack {
            if let loadedImage {
                Image(uiImage: loadedImage)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .transition(.opacity.animation(.easeInOut(duration: 0.2)))
            } else {
                Rectangle()
                    .fill(Color.primary.opacity(0.06))
                    .overlay {
                        if isLoading {
                            ProgressView()
                                .controlSize(.small)
                        } else {
                            Image(systemName: fallbackSymbol)
                                .font(.title2)
                                .foregroundStyle(.secondary)
                        }
                    }
            }
        }
        .task(id: url) {
            await load()
        }
    }

    private func load() async {
        guard let url else {
            loadedImage = nil
            return
        }
        isLoading = true
        let image = await RemoteImageCache.shared.image(for: url)
        withAnimation(.easeInOut(duration: 0.2)) {
            loadedImage = image
            isLoading = false
        }
    }
}
