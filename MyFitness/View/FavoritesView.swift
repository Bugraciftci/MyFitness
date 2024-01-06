import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var favoritesManager: FavoritesManager // This is your shared instance

    var body: some View {
        NavigationView {
            List {
                ForEach(favoritesManager.favoriteExercises, id: \.self) { exerciseName in
                    NavigationLink(destination: ExerciseDetailView(exercise: Exercise(name: exerciseName,repetitions: 10, imageName: "", photo: Image("default_photo")), favoritesManager: favoritesManager)) { // Pass the shared instance
                        Text(exerciseName)
                    }
                }
                .onDelete(perform: delete)
            }
            .navigationTitle("Favorites")
        }
    }
    
    func delete(at offsets: IndexSet) {
        offsets.forEach { index in
            let exerciseName = favoritesManager.favoriteExercises[index]
            favoritesManager.removeFavorite(exerciseName: exerciseName)
        }
    }
}

struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView()
            .environmentObject(FavoritesManager()) // Provide the environment object for the preview
    }
}
