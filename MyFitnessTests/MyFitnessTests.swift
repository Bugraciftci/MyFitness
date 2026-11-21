//
//  MyFitnessTests.swift
//  MyFitnessTests
//

import XCTest
@testable import MyFitness

// MARK: - Test Doubles

private final class MockExerciseRepository: ExerciseRepositoryProtocol, @unchecked Sendable {
    var seedResult: Result<[Exercise], ExerciseRepositoryError> = .success([])
    var remoteResult: Result<ExerciseLoadPayload, ExerciseRepositoryError> = .failure(.networkUnavailable)

    func loadOfflineSeed() -> Result<[Exercise], ExerciseRepositoryError> {
        seedResult
    }

    func fetchExercises() async -> Result<ExerciseLoadPayload, ExerciseRepositoryError> {
        remoteResult
    }
}

private final class InMemoryWorkoutStore: WorkoutStoreProtocol {
    var favorites: Set<String> = []
    var sessions: [WorkoutSession] = []
    var preferences = UserPreferences()

    func loadFavoriteIDs() -> Set<String> { favorites }
    func saveFavoriteIDs(_ ids: Set<String>) { favorites = ids }
    func loadSessions() -> [WorkoutSession] { sessions }
    func saveSessions(_ sessions: [WorkoutSession]) { self.sessions = sessions }
    func loadPreferences() -> UserPreferences { preferences }
    func savePreferences(_ preferences: UserPreferences) { self.preferences = preferences }
    func resetAllData() {
        favorites = []
        sessions = []
        preferences = UserPreferences()
    }
}

// MARK: - Unit Tests

@MainActor
final class MyFitnessTests: XCTestCase {

    func testExerciseDecodingAndImageURLGeneration() throws {
        let json = """
        {
          "id": "Barbell_Curl",
          "name": "Barbell Curl",
          "force": "pull",
          "level": "beginner",
          "mechanic": "isolation",
          "equipment": "barbell",
          "primaryMuscles": ["biceps"],
          "secondaryMuscles": ["forearms"],
          "instructions": ["Stand upright.", "Curl the bar."],
          "category": "strength",
          "images": ["Barbell_Curl/0.jpg", "Barbell_Curl/1.jpg"]
        }
        """
        let data = try XCTUnwrap(json.data(using: .utf8))
        let exercise = try JSONDecoder().decode(Exercise.self, from: data)

        XCTAssertEqual(exercise.id, "Barbell_Curl")
        XCTAssertEqual(exercise.muscleGroup, .biceps)
        XCTAssertEqual(exercise.level, .beginner)
        XCTAssertEqual(exercise.formattedEquipment, "Barbell")
        XCTAssertEqual(exercise.imageURLs.count, 2)
        XCTAssertEqual(
            exercise.imageURLs[0].absoluteString,
            "https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Barbell_Curl/0.jpg"
        )
    }

    func testDiscoverViewModelFiltersByMuscleEquipmentAndDifficulty() async {
        let repo = MockExerciseRepository()
        let store = InMemoryWorkoutStore()
        let bench = Exercise.sample
        let pushup = Exercise(
            id: "Pushups",
            name: "Pushups",
            level: .beginner,
            equipment: "body only",
            primaryMuscles: ["chest"],
            images: ["Pushups/0.jpg", "Pushups/1.jpg"]
        )
        let squat = Exercise(
            id: "Barbell_Squat",
            name: "Barbell Squat",
            level: .intermediate,
            equipment: "barbell",
            primaryMuscles: ["quadriceps"],
            images: ["Barbell_Squat/0.jpg", "Barbell_Squat/1.jpg"]
        )
        repo.seedResult = .success([bench, pushup, squat])

        let vm = DiscoverViewModel(repository: repo, store: store)
        XCTAssertEqual(vm.allExercises.count, 3)

        vm.selectedMuscle = .chest
        try? await Task.sleep(for: .milliseconds(250))
        XCTAssertEqual(vm.filteredExercises.count, 2)

        vm.selectedEquipment = .bodyweight
        try? await Task.sleep(for: .milliseconds(250))
        XCTAssertEqual(vm.filteredExercises.map(\.id), ["Pushups"])

        vm.clearFilters()
        vm.selectedDifficulty = .intermediate
        try? await Task.sleep(for: .milliseconds(250))
        XCTAssertEqual(vm.filteredExercises.count, 2)
    }

    func testFavoritesPersistenceRoundTrip() {
        let repo = MockExerciseRepository()
        let store = InMemoryWorkoutStore()
        repo.seedResult = .success([.sample])

        let vm = DiscoverViewModel(repository: repo, store: store)
        XCTAssertFalse(vm.isFavorite(.sample))

        vm.toggleFavorite(.sample)
        XCTAssertTrue(vm.isFavorite(.sample))
        XCTAssertEqual(store.favorites, [Exercise.sample.id])

        vm.toggleFavorite(.sample)
        XCTAssertFalse(vm.isFavorite(.sample))
        XCTAssertTrue(store.favorites.isEmpty)
    }

    func testWorkoutViewModelVolumeEpley1RMAndSessionPersistence() {
        let store = InMemoryWorkoutStore()
        let vm = WorkoutViewModel(store: store)

        vm.startQuickSession(with: .sample)
        XCTAssertTrue(vm.isSessionActive)
        XCTAssertEqual(vm.activeEntries.count, 1)

        let entry = vm.activeEntries[0]
        let firstSet = entry.sets[0]
        vm.updateSet(entryID: entry.id, setID: firstSet.id, weightKg: 100, reps: 5)
        vm.toggleSetCompletion(entryID: entry.id, setID: firstSet.id, defaultRestSeconds: 60)

        XCTAssertEqual(vm.activeSessionVolumeKg, 500, accuracy: 0.01)
        XCTAssertEqual(vm.restSecondsRemaining, 60)
        // Epley 1RM: 100 * (1 + 5/30) = 116.666...
        XCTAssertEqual(vm.activeEntries[0].bestEstimated1RMKg, 116.67, accuracy: 0.1)

        let saved = vm.finishActiveSession()
        XCTAssertNotNil(saved)
        XCTAssertFalse(vm.isSessionActive)
        XCTAssertEqual(vm.completedSessions.count, 1)
        XCTAssertEqual(store.sessions.count, 1)
    }

    func testBundledOfflineSeedJSONDecodesSuccessfully() {
        let repo = FreeExerciseDBRepository(bundle: Bundle(for: MyFitnessTests.self))
        // Also verify via main app bundle
        let mainRepo = FreeExerciseDBRepository(bundle: .main)
        let result = mainRepo.loadOfflineSeed()
        switch result {
        case .success(let exercises):
            XCTAssertGreaterThanOrEqual(exercises.count, 100)
            XCTAssertTrue(exercises.allSatisfy { !$0.images.isEmpty })
        case .failure:
            // If running unit test bundle without host app, check repo fallback gracefully
            _ = repo
            XCTFail("Bundled exercises_seed.json failed to decode from app bundle.")
        }
    }
}
