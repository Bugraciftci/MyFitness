import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var favoritesManager: FavoritesManager  // Güncelleme
    @State private var showingFavorites = true
    
    var body: some View {
        NavigationView {
            Group {  // Group kullanarak her iki durum için aynı türde bir view döndürün
                if showingFavorites {
                    favoriteExercisesList
                } else {
                    personalWorkoutPlan
                }
            }
            .navigationTitle(showingFavorites ? "Favori Egzersizler" : "Antrenman Planım")
            .navigationBarItems(
                leading: Button("Favoriler") {
                    showingFavorites = true
                },
                trailing: Button("Planım") {
                    showingFavorites = false
                }
            )
        }
    }
    
    // Favori egzersizler listesini oluşturan bir alt görünüm
    private var favoriteExercisesList: some View {
        List {
            ForEach(favoritesManager.favoriteExercises, id: \.self) { exerciseName in
                Text(exerciseName)
            }
            .onDelete(perform: delete)
        }
    }
    
    // Kişisel antrenman planını oluşturan bir alt görünüm
    private var personalWorkoutPlan: some View {
        Text("Kendi Workout Planım")
        // Burada kişisel planınızın içeriğini ve yönetimini ekleyebilirsiniz.
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
            .environmentObject(FavoritesManager())  // FavoritesManager örneğini sağla
    }
}
