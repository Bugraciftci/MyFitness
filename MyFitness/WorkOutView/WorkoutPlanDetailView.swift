import SwiftUI

// Define a model for each day's workout item
struct WorkoutDayItem: Identifiable {
    let id = UUID()
    var day: String
    var isCompleted: Bool
    var completionPercentage: Double
}

struct WorkoutPlanDetailView: View {
    var workoutPlan: WorkoutPlan
    // Sample data for daily workout items
    let workoutDays: [WorkoutDayItem] = [
        WorkoutDayItem(day: "1. gün", isCompleted: true, completionPercentage: 1.0),
        WorkoutDayItem(day: "2. gün", isCompleted: true, completionPercentage: 1.0),
        WorkoutDayItem(day: "3. gün", isCompleted: false, completionPercentage: 0.76),
        // Add more days as needed
    ]

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
                        // Use a custom view if you need a progress circle
                        ProgressCircleView(percentage: item.completionPercentage)
                    }
                }
            }
        }
        .navigationTitle(workoutPlan.title)
    }
}

// Don't forget to implement previews for your custom views
struct WorkoutPlanDetailView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutPlanDetailView(workoutPlan: WorkoutPlan(title: "KOL ORTA DÜZEY", description: "Kısa süre içinde kollara şekil verin", imageName: "intermediate_arms", difficultyLevel: 2))
    }
}
