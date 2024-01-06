import SwiftUI

struct ExerciseDetailView: View {
    @EnvironmentObject var favoritesManager: FavoritesManager
    @State private var showingAlert = false
    @State private var isFavorite: Bool
    var exercise: Exercise

    init(exercise: Exercise, favoritesManager: FavoritesManager) {
        self.exercise = exercise
        self._isFavorite = State(initialValue: favoritesManager.favoriteExercises.contains(exercise.name))
    }


    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                exercise.photo
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipped()
                    .cornerRadius(10)
                    .shadow(radius: 5)

                Text(exercise.name)
                    .font(.title)
                    .fontWeight(.bold)


                Button(action: {
                    if isFavorite {
                        favoritesManager.removeFavorite(exerciseName: exercise.name)
                    } else {
                        favoritesManager.addFavorite(exerciseName: exercise.name)
                    }
                    isFavorite.toggle()
                    showingAlert = true  // Alert'i göstermek için
                }) {
                    HStack {
                        Image(systemName: isFavorite ? "star.fill" : "star")
                        Text(isFavorite ? "Remove from Favorites" : "Add to Favorites")
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(isFavorite ? Color.red : Color.green)
                    .cornerRadius(40)
                }
                .alert(isPresented: $showingAlert) {
                    Alert(
                        title: Text("Favorites Updated"),
                        message: Text(isFavorite ? "This exercise has been added to your favorites." : "This exercise has been removed from your favorites."),
                        dismissButton: .default(Text("OK"))
                    )
                }

                Text("Place your exercise details here...")
                    .font(.body)
                // Add more details or video player if needed
                Spacer()
            }
            .padding()
        }
        .navigationTitle(exercise.name)
    }
}

struct ExerciseDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let fakeFavoritesManager = FavoritesManager()
        return ExerciseDetailView(exercise: Exercise(name: "Biceps Curl", photo: Image("biceps_image"), videoName: "biceps_curl_video"), favoritesManager: fakeFavoritesManager)
            .environmentObject(fakeFavoritesManager)
    }
}
