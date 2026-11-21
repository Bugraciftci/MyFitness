//
//  RemoteImageCache.swift
//  MyFitness
//

import UIKit

/// Thread-safe, actor-isolated memory + URLCache image loader for exercise form demonstrations.
actor RemoteImageCache {
    static let shared = RemoteImageCache()

    private let memoryCache: NSCache<NSURL, UIImage> = {
        let cache = NSCache<NSURL, UIImage>()
        cache.countLimit = 240
        cache.totalCostLimit = 64 * 1024 * 1024 // 64 MB
        return cache
    }()

    private var inFlightTasks: [URL: Task<UIImage?, Never>] = [:]
    private let session: URLSession

    init() {
        let config = URLSessionConfiguration.default
        config.urlCache = URLCache(
            memoryCapacity: 32 * 1024 * 1024,
            diskCapacity: 150 * 1024 * 1024,
            diskPath: "myfitness_exercise_images"
        )
        config.requestCachePolicy = .returnCacheDataElseLoad
        config.timeoutIntervalForRequest = 15
        self.session = URLSession(configuration: config)
    }

    func image(for url: URL) async -> UIImage? {
        if let cached = memoryCache.object(forKey: url as NSURL) {
            return cached
        }

        if let existingTask = inFlightTasks[url] {
            return await existingTask.value
        }

        let task = Task<UIImage?, Never> {
            do {
                let (data, response) = try await session.data(from: url)
                guard let http = response as? HTTPURLResponse,
                      (200...299).contains(http.statusCode),
                      let image = UIImage(data: data) else {
                    return nil
                }
                return image
            } catch {
                return nil
            }
        }

        inFlightTasks[url] = task
        let result = await task.value
        inFlightTasks[url] = nil

        if let result {
            let cost = Int(result.size.width * result.size.height * result.scale * 4)
            memoryCache.setObject(result, forKey: url as NSURL, cost: cost)
        }
        return result
    }

    func prefetch(urls: [URL]) {
        for url in urls {
            Task { _ = await self.image(for: url) }
        }
    }
}
