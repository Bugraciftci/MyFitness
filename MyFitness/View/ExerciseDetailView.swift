import SwiftUI

struct ExerciseDetailView: View {
    @EnvironmentObject var favoritesManager: FavoritesManager
    var exercise: Exercise

    var body: some View {
        ScrollView {
            VStack {
                // ... Egzersiz detayları
            }
            .navigationTitle(exercise.name)
            .navigationBarItems(trailing: Button(action: {
                // Favori durumunu değiştir
                favoritesManager.toggleFavorite(exerciseName: exercise.name)
            }) {
                // Butonun görüntüsü
                Image(systemName: favoritesManager.favoriteExercises.contains(exercise.name) ? "star.fill" : "star")
                    .foregroundColor(.yellow)
            })
        }
    }
}

// FavoritesManager sınıfı içindeki toggleFavorite metodunun tanımı
extension FavoritesManager {
    func toggleFavorite(exerciseName: String) {
        if favoriteExercises.contains(exerciseName) {
            // Exercise'i favorilerden çıkar
            favoriteExercises.removeAll { $0 == exerciseName }
        } else {
            // Exercise'i favorilere ekle
            favoriteExercises.append(exerciseName)
        }
    }
}

// Önceden tanımlanmış Exercise, Muscle ve FavoritesManager yapılarınız olduğunu varsayıyorum.
struct ExerciseDetailView_Previews: PreviewProvider {
    static var previews: some View {
        // Test için geçici bir Exercise örneği oluşturun.
        ExerciseDetailView(exercise: Exercise(name: "Biceps Curl", photo: Image(systemName: "star"), videoName: "biceps_curl_video"))
            .environmentObject(FavoritesManager())  // FavoritesManager örneğini sağla
    }
}
