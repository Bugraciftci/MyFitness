import SwiftUI

struct WorkoutPlan: Identifiable {
    let id = UUID()
    var title: String
    var description: String
    var imageName: String
    var difficultyLevel: Int
}

struct PersonalWorkoutView: View {
    let workoutPlans: [WorkoutPlan] = [
        WorkoutPlan(title: "KOL BAŞLANGIÇ DÜZEYİ", description: "Yağları yakın ve kas kütlesi kazanın", imageName: "beginner_arms", difficultyLevel: 1),
        WorkoutPlan(title: "KOL ORTA DÜZEY", description: "Kısa süre içinde kollara şekil verin", imageName: "intermediate_arms", difficultyLevel: 2),
        WorkoutPlan(title: "KOL GELİŞMİŞ", description: "Daha büyük ve güçlü kollara sahip olun", imageName: "advanced_arms", difficultyLevel: 3)
    ]

    var body: some View {
        NavigationView {
            List(workoutPlans) { plan in
                NavigationLink(destination: WorkoutPlanDetailView(workoutPlan: plan)) {
                    WorkoutPlanRowView(plan: plan)
                }
            }
            .navigationBarTitle("Antrenman Planı Seçin")
        }
    }
}

struct WorkoutPlanSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        PersonalWorkoutView()
    }
}
