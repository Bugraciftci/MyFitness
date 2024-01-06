import SwiftUI

struct DayView: View {
    var workoutDay: WorkoutDay // Ensure this is the correct WorkoutDay struct

    var body: some View {
        List(workoutDay.exercises) { exercise in
            HStack {
                Image(exercise.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                VStack(alignment: .leading) {
                    Text(exercise.name)
                    Text("x\(exercise.repetitions)")
                }
            }
        }
        .navigationBarTitle("\(workoutDay.dayNumber). gün", displayMode: .inline)
    }
}

struct DayView_Previews: PreviewProvider {
    static var previews: some View {
        DayView(workoutDay: WorkoutDay(dayNumber: 5, exercises: [
            Exercise(name: "Dinamik Göğüs", repetitions: 12, imageName: "exercise_chest", photo: Image("exercise_chest")),
            // More exercises...
        ]))
    }
}
