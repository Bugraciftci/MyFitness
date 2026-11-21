//
//  AppContainer.swift
//  MyFitness
//

import Foundation
import SwiftUI

/// Composition root providing protocol-backed dependencies to all feature ViewModels.
@MainActor
final class AppContainer: ObservableObject {
    let exerciseRepository: ExerciseRepositoryProtocol
    let workoutStore: WorkoutStoreProtocol

    let discoverViewModel: DiscoverViewModel
    let workoutViewModel: WorkoutViewModel
    let profileViewModel: ProfileViewModel

    init(
        exerciseRepository: ExerciseRepositoryProtocol = FreeExerciseDBRepository(),
        workoutStore: WorkoutStoreProtocol = UserDefaultsWorkoutStore()
    ) {
        self.exerciseRepository = exerciseRepository
        self.workoutStore = workoutStore
        self.discoverViewModel = DiscoverViewModel(
            repository: exerciseRepository,
            store: workoutStore
        )
        self.workoutViewModel = WorkoutViewModel(store: workoutStore)
        self.profileViewModel = ProfileViewModel(store: workoutStore)
    }
}
