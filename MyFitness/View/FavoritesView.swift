import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var favoritesManager: FavoritesManager
    @State private var showingFavorites = true
    
    var body: some View {
        NavigationView {
            Group {
                if showingFavorites {
                    favoriteExercisesList
                } else {
                    personalWorkoutPlan
                }
            }
            .navigationTitle(showingFavorites ? "Favorite Exercises" : "My Workout Plan")
            .navigationBarItems(
                leading: Button("Favorites") {
                    showingFavorites = true
                },
                trailing: Button("My Plan") {
                    showingFavorites = false
                }
            )
        }
    }
    
    private var favoriteExercisesList: some View {
        List {
            ForEach(favoritesManager.favoriteExercises, id: \.self) { exerciseName in                NavigationLink(destination: ExerciseDetailView(exercise: Exercise(name: exerciseName, photo: Image("default_photo"), videoName: "default_video"), favoritesManager: favoritesManager)) {
                    Text(exerciseName)
                }
            }
            .onDelete(perform: delete)
        }
    }
    
    private var personalWorkoutPlan: some View {
        Text("Your personalized workout plan here...")
        // Add more content or functionality for personal workout plan
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
