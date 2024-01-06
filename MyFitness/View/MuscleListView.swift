import SwiftUI

struct MuscleListView: View {
    var muscles: [Muscle]
    @EnvironmentObject var favoritesManager: FavoritesManager

    let columns = [
        GridItem(.adaptive(minimum: 150))
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(muscles, id: \.name) { muscle in
                        NavigationLink(destination: MuscleDetailView(muscle: muscle, favoritesManager: _favoritesManager)) {
                            VStack {
                                muscle.photo
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 150)
                                    .cornerRadius(8)
                                Text(muscle.name)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }
                            .padding(.vertical)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Muscles")
        }
    }
}

// Dummy data for preview
struct MuscleListView_Previews: PreviewProvider {
    static var previews: some View {
        MuscleListView(muscles: [Muscle(name: "Biceps", photo: Image("biceps_image"), videoName: "biceps_video", description: "deneeme", exercises: [])])
            .environmentObject(FavoritesManager())
    }
}
