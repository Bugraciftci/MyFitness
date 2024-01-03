import SwiftUI

class FavoritesManager: ObservableObject {
    @Published var favoriteExercises: [String] {
        didSet {
            UserDefaults.standard.set(favoriteExercises, forKey: "Favorites")
        }
    }

    init() {
        // UserDefaults'tan favori egzersizleri yükleyin
        self.favoriteExercises = UserDefaults.standard.object(forKey: "Favorites") as? [String] ?? []
    }

    func addFavorite(exerciseName: String) {
        guard !favoriteExercises.contains(exerciseName) else { return }
        favoriteExercises.append(exerciseName)
    }

    func removeFavorite(exerciseName: String) {
        if let index = favoriteExercises.firstIndex(of: exerciseName) {
            favoriteExercises.remove(at: index)
        }
    }
}
