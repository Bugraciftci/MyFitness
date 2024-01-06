import SwiftUI

class FavoritesManager: ObservableObject {
    @Published var favoriteExercises: [String] {
        didSet {
            saveFavorites()
        }
    }

    init() {
        // UserDefaults'tan favori egzersizleri yükleyin
        self.favoriteExercises = UserDefaults.standard.object(forKey: "Favorites") as? [String] ?? []
    }

    // Egzersizi favorilere ekleyin
    func addFavorite(exerciseName: String) {
        guard !favoriteExercises.contains(exerciseName) else { return }
        favoriteExercises.append(exerciseName)
    }

    // Egzersizi favorilerden çıkarın
    func removeFavorite(exerciseName: String) {
        if let index = favoriteExercises.firstIndex(of: exerciseName) {
            favoriteExercises.remove(at: index)
        }
    }

    // Asenkron olarak favorileri kaydedin
    func saveFavorites() {
        DispatchQueue.global(qos: .background).async {
            UserDefaults.standard.set(self.favoriteExercises, forKey: "Favorites")
        }
    }

    // Egzersizin favori durumunu değiştirin
    func toggleFavorite(exerciseName: String) {
        if favoriteExercises.contains(exerciseName) {
            removeFavorite(exerciseName: exerciseName)
        } else {
            addFavorite(exerciseName: exerciseName)
        }
    }
}
