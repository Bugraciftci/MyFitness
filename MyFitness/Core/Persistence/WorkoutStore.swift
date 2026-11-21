//
//  WorkoutStore.swift
//  MyFitness
//

import Foundation

protocol WorkoutStoreProtocol: AnyObject {
    func loadFavoriteIDs() -> Set<String>
    func saveFavoriteIDs(_ ids: Set<String>)
    func loadSessions() -> [WorkoutSession]
    func saveSessions(_ sessions: [WorkoutSession])
    func loadPreferences() -> UserPreferences
    func savePreferences(_ preferences: UserPreferences)
    func resetAllData()
}

final class UserDefaultsWorkoutStore: WorkoutStoreProtocol {
    private enum Keys {
        static let favorites = "myfitness.v2.favoriteExerciseIDs"
        static let sessions = "myfitness.v2.workoutSessions"
        static let preferences = "myfitness.v2.userPreferences"
    }

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadFavoriteIDs() -> Set<String> {
        let array = defaults.stringArray(forKey: Keys.favorites) ?? []
        return Set(array)
    }

    func saveFavoriteIDs(_ ids: Set<String>) {
        defaults.set(Array(ids).sorted(), forKey: Keys.favorites)
    }

    func loadSessions() -> [WorkoutSession] {
        guard let data = defaults.data(forKey: Keys.sessions),
              let decoded = try? decoder.decode([WorkoutSession].self, from: data) else {
            return []
        }
        return decoded.sorted { $0.date > $1.date }
    }

    func saveSessions(_ sessions: [WorkoutSession]) {
        guard let data = try? encoder.encode(sessions) else { return }
        defaults.set(data, forKey: Keys.sessions)
    }

    func loadPreferences() -> UserPreferences {
        guard let data = defaults.data(forKey: Keys.preferences),
              let decoded = try? decoder.decode(UserPreferences.self, from: data) else {
            return UserPreferences()
        }
        return decoded
    }

    func savePreferences(_ preferences: UserPreferences) {
        guard let data = try? encoder.encode(preferences) else { return }
        defaults.set(data, forKey: Keys.preferences)
    }

    func resetAllData() {
        defaults.removeObject(forKey: Keys.favorites)
        defaults.removeObject(forKey: Keys.sessions)
        defaults.removeObject(forKey: Keys.preferences)
    }
}
