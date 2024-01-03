import SwiftUI

struct MuscleDetailView: View {
    @EnvironmentObject var favoritesManager: FavoritesManager
    var muscle: Muscle

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(muscle.exercises, id: \.name) { exercise in
                    NavigationLink(destination: ExerciseDetailView(exercise: exercise)) {
                        VStack {
                            exercise.photo
                                .resizable()
                                .scaledToFit()
                                .frame(height: 150)
                                .cornerRadius(8)
                            Text(exercise.name)
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        .padding(.vertical)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(12)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(muscle.name)
    }
}

// Önizleme için geçici veri sağlayın
struct MuscleDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let testMuscle = Muscle(name: "Biceps", photo: Image("biceps_image"), videoName: "biceps_video", exercises: [
            Exercise(name: "Bicep Curl", photo: Image("biceps_image"), videoName: "bicep_curl_video")
        ])
        return MuscleDetailView(muscle: testMuscle)
            .environmentObject(FavoritesManager())
    }
}
