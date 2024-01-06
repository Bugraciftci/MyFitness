import SwiftUI

struct WorkoutPlan: Identifiable {
    let id = UUID()
    var title: String
    var description: String
    var imageName: String
    var difficultyLevel: Int
}


// Define the Day and WorkoutDay structs if not already defined
struct Day: Identifiable {
    let id = UUID()
    var dayNumber: Int
    // Add more properties as needed
}

struct WorkoutDay: Identifiable {
    let id = UUID()
    var dayNumber: Int
    var exercises: [Exercise] // Ensure this is the correct Exercise struct
}

struct PersonalWorkoutView: View {
    let workoutPlans: [WorkoutPlan] = []

    let workoutDays: [Day] = []

    var body: some View {
        NavigationView {
            List(workoutPlans) { plan in
                NavigationLink(destination: WorkoutPlanDetailView(workoutPlan: plan)) {
                    WorkoutPlanRowView(plan: plan)
                }
            }
            .navigationBarTitle("Workout Plans", displayMode: .large)
        }
    }
}

struct PersonalWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        PersonalWorkoutView()
    }
}
