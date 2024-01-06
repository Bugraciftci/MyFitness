import SwiftUI

struct WorkoutPlanRowView: View {
    var plan: WorkoutPlan
    
    var body: some View {
        HStack {
            Image(plan.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 100)
                .clipped()
                .cornerRadius(10)
            
            VStack(alignment: .leading) {
                Text(plan.title)
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text(plan.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack {
                    ForEach(0..<plan.difficultyLevel, id: \.self) { _ in
                        Image(systemName: "bolt.fill")
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding(.leading)
            
            Spacer()
        }
    }
}

// Preview for WorkoutPlanRowView
struct WorkoutPlanRowView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutPlanRowView(plan: WorkoutPlan(title: "KOL BAŞLANGIÇ DÜZEYİ", description: "Yağları yakın ve kas kütlesi kazanın", imageName: "beginner_arms", difficultyLevel: 1))
    }
}
