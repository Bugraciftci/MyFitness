//
//  ProfileViewModel.swift
//  MyFitness
//

import Foundation
import SwiftUI

struct MuscleDistributionItem: Identifiable {
    let muscle: MuscleGroup
    let completedSets: Int
    var id: MuscleGroup { muscle }
}

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var preferences: UserPreferences {
        didSet {
            store.savePreferences(preferences)
        }
    }

    private let store: WorkoutStoreProtocol

    init(store: WorkoutStoreProtocol) {
        self.store = store
        self.preferences = store.loadPreferences()
    }

    var preferredColorScheme: ColorScheme? {
        switch preferences.appearance {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

    func muscleDistribution(from sessions: [WorkoutSession]) -> [MuscleDistributionItem] {
        var counts: [MuscleGroup: Int] = [:]
        for session in sessions {
            for entry in session.entries {
                counts[entry.muscleGroup, default: 0] += entry.completedSetsCount
            }
        }
        return counts
            .filter { $0.value > 0 }
            .map { MuscleDistributionItem(muscle: $0.key, completedSets: $0.value) }
            .sorted { $0.completedSets > $1.completedSets }
    }

    func resetAllData() {
        store.resetAllData()
        preferences = UserPreferences()
    }
}
