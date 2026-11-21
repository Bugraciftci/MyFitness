//
//  ExerciseRepository.swift
//  MyFitness
//

import Foundation

enum ExerciseRepositoryError: Error, LocalizedError, Equatable {
    case invalidResponse
    case decodingFailed
    case seedMissing
    case networkUnavailable

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "The exercise server returned an unexpected response."
        case .decodingFailed:
            return "Unable to decode the exercise catalog."
        case .seedMissing:
            return "Local offline exercise database could not be found."
        case .networkUnavailable:
            return "No internet connection. Showing offline exercise library."
        }
    }
}

enum ExerciseDataSource: String, Sendable {
    case offlineSeed = "Offline Library"
    case liveGitHub = "Free Exercise DB (Live)"
}

struct ExerciseLoadPayload: Sendable {
    let exercises: [Exercise]
    let source: ExerciseDataSource
}

protocol ExerciseRepositoryProtocol: Sendable {
    func loadOfflineSeed() -> Result<[Exercise], ExerciseRepositoryError>
    func fetchExercises() async -> Result<ExerciseLoadPayload, ExerciseRepositoryError>
}

/// Fetches 870+ public-domain exercises from `yuhonas/free-exercise-db`
/// with automatic zero-latency fallback to the bundled offline JSON seed.
struct FreeExerciseDBRepository: ExerciseRepositoryProtocol {
    static let remoteCatalogURL = URL(
        string: "https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/dist/exercises.json"
    )!

    private let session: URLSession
    private let bundle: Bundle

    init(session: URLSession = .shared, bundle: Bundle = .main) {
        self.session = session
        self.bundle = bundle
    }

    func loadOfflineSeed() -> Result<[Exercise], ExerciseRepositoryError> {
        guard let url = bundle.url(forResource: "exercises_seed", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return .failure(.seedMissing)
        }
        do {
            let decoded = try JSONDecoder().decode([Exercise].self, from: data)
            return .success(decoded)
        } catch {
            return .failure(.decodingFailed)
        }
    }

    func fetchExercises() async -> Result<ExerciseLoadPayload, ExerciseRepositoryError> {
        do {
            var request = URLRequest(url: Self.remoteCatalogURL)
            request.timeoutInterval = 12
            request.cachePolicy = .returnCacheDataElseLoad

            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                return fallbackToSeed()
            }
            let decoded = try JSONDecoder().decode([Exercise].self, from: data)
            let valid = decoded.filter { !$0.images.isEmpty && !$0.primaryMuscles.isEmpty }
            guard !valid.isEmpty else {
                return fallbackToSeed()
            }
            return .success(ExerciseLoadPayload(exercises: valid, source: .liveGitHub))
        } catch {
            return fallbackToSeed()
        }
    }

    private func fallbackToSeed() -> Result<ExerciseLoadPayload, ExerciseRepositoryError> {
        switch loadOfflineSeed() {
        case .success(let seed):
            return .success(ExerciseLoadPayload(exercises: seed, source: .offlineSeed))
        case .failure(let err):
            return .failure(err)
        }
    }
}
