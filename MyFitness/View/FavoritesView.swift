import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var favoritesManager: FavoritesManager

    var body: some View {
        NavigationView {
            List {
                ForEach(favoritesManager.favoriteExercises, id: \.self) { exerciseName in
                    NavigationLink(destination: ExerciseDetailView(exercise: Exercise(name: exerciseName, photo: Image("default_photo"), videoName: "default_video"), favoritesManager: FavoritesManager())) {
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
            .environmentObject(FavoritesManager())
    }
}
