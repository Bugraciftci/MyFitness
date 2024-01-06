import SwiftUI

struct WorkoutPlanDetailView: View {
    var workoutPlan: WorkoutPlan
    let workoutDays: [WorkoutDayItem] = []
    struct WorkoutDayItem: Identifiable {
        let id = UUID()
        var day: String
        var isCompleted: Bool
        var completionPercentage: Double
    }

    var body: some View {
        List {
            ForEach(workoutDays) { item in
                HStack {
                    Text(item.day)
                    Spacer()
                    if item.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.blue)
                    } else {
                        ProgressCircleView(percentage: item.completionPercentage)
                    }
                }
            }
        }
        .navigationTitle(workoutPlan.title)
    }
}

struct WorkoutPlanDetailView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutPlanDetailView(workoutPlan: WorkoutPlan(title: "KOL ORTA DÜZEY", description: "Kısa süre içinde kollara şekil verin", imageName: "intermediate_arms", difficultyLevel: 2))
    }
}
