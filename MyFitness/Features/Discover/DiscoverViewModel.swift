//
//  DiscoverViewModel.swift
//  MyFitness
//

import Combine
import Foundation

@MainActor
final class DiscoverViewModel: ObservableObject {
    @Published private(set) var allExercises: [Exercise] = []
    @Published private(set) var filteredExercises: [Exercise] = []
    @Published private(set) var favoriteIDs: Set<String> = []
    @Published private(set) var dataSource: ExerciseDataSource = .offlineSeed
    @Published private(set) var isSyncingLiveCatalog = false
    @Published private(set) var errorMessage: String?

    @Published var searchText: String = ""
    @Published var selectedMuscle: MuscleGroup? = nil
    @Published var selectedEquipment: EquipmentFilter = .all
    @Published var selectedDifficulty: DifficultyLevel? = nil

    private let repository: ExerciseRepositoryProtocol
    private let store: WorkoutStoreProtocol
    private var cancellables = Set<AnyCancellable>()

    init(repository: ExerciseRepositoryProtocol, store: WorkoutStoreProtocol) {
        self.repository = repository
        self.store = store
        self.favoriteIDs = store.loadFavoriteIDs()

        // Instant zero-latency boot from bundled offline seed
        if case .success(let seed) = repository.loadOfflineSeed() {
            self.allExercises = seed
        }

        bindFilteringPipeline()
        applyFilters(
            exercises: allExercises,
            query: "",
            muscle: selectedMuscle,
            equipment: selectedEquipment,
            difficulty: selectedDifficulty
        )
    }

    private func bindFilteringPipeline() {
        let debouncedSearch = $searchText
            .debounce(for: .milliseconds(180), scheduler: RunLoop.main)
            .removeDuplicates()

        Publishers.CombineLatest4(
            $allExercises,
            debouncedSearch,
            $selectedMuscle,
            Publishers.CombineLatest($selectedEquipment, $selectedDifficulty)
        )
        .sink { [weak self] exercises, query, muscle, equipmentAndDifficulty in
            let (equipment, difficulty) = equipmentAndDifficulty
            self?.applyFilters(
                exercises: exercises,
                query: query,
                muscle: muscle,
                equipment: equipment,
                difficulty: difficulty
            )
        }
        .store(in: &cancellables)
    }

    func loadLiveCatalogIfNeeded() async {
        guard dataSource != .liveGitHub, !isSyncingLiveCatalog else { return }
        await refreshCatalog()
    }

    func refreshCatalog() async {
        isSyncingLiveCatalog = true
        errorMessage = nil
        let result = await repository.fetchExercises()
        switch result {
        case .success(let payload):
            allExercises = payload.exercises
            dataSource = payload.source
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
        isSyncingLiveCatalog = false
    }

    func toggleFavorite(_ exercise: Exercise) {
        if favoriteIDs.contains(exercise.id) {
            favoriteIDs.remove(exercise.id)
        } else {
            favoriteIDs.insert(exercise.id)
        }
        store.saveFavoriteIDs(favoriteIDs)
    }

    func isFavorite(_ exercise: Exercise) -> Bool {
        favoriteIDs.contains(exercise.id)
    }

    var favoriteExercises: [Exercise] {
        allExercises.filter { favoriteIDs.contains($0.id) }
    }

    func count(for muscle: MuscleGroup) -> Int {
        allExercises.filter { $0.muscleGroup == muscle }.count
    }

    func exercises(for muscles: [MuscleGroup], limitPerMuscle: Int = 2) -> [Exercise] {
        var result: [Exercise] = []
        var seen = Set<String>()
        for muscle in muscles {
            let candidates = allExercises.filter { $0.muscleGroup == muscle }
            for ex in candidates.prefix(limitPerMuscle) where !seen.contains(ex.id) {
                seen.insert(ex.id)
                result.append(ex)
            }
        }
        return result
    }

    func clearFilters() {
        searchText = ""
        selectedMuscle = nil
        selectedEquipment = .all
        selectedDifficulty = nil
    }

    var hasActiveFilters: Bool {
        !searchText.trimmingCharacters(in: .whitespaces).isEmpty ||
        selectedMuscle != nil ||
        selectedEquipment != .all ||
        selectedDifficulty != nil
    }

    func reloadFavoritesFromStore() {
        favoriteIDs = store.loadFavoriteIDs()
    }

    private func applyFilters(
        exercises: [Exercise],
        query: String,
        muscle: MuscleGroup?,
        equipment: EquipmentFilter,
        difficulty: DifficultyLevel?
    ) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        filteredExercises = exercises.filter { exercise in
            if let muscle, exercise.muscleGroup != muscle {
                return false
            }
            if !equipment.matches(exercise) {
                return false
            }
            if let difficulty, exercise.level != difficulty {
                return false
            }
            if !trimmed.isEmpty {
                let inName = exercise.name.lowercased().contains(trimmed)
                let inMuscle = exercise.primaryMuscles.contains { $0.lowercased().contains(trimmed) }
                let inEquipment = exercise.formattedEquipment.lowercased().contains(trimmed)
                return inName || inMuscle || inEquipment
            }
            return true
        }
    }
}
