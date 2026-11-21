//
//  WorkoutModels.swift
//  MyFitness
//

import Foundation

struct WorkoutPlan: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let title: String
    let subtitle: String
    let level: DifficultyLevel
    let daysPerWeek: Int
    let estimatedMinutes: Int
    let focusMuscles: [MuscleGroup]
    let days: [WorkoutDay]
}

struct WorkoutDay: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let name: String
    let focus: String
    let targetMuscles: [MuscleGroup]
    let prescribedSets: Int
    let targetRepRange: String
}

struct LoggedSet: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var weightKg: Double
    var reps: Int
    var isCompleted: Bool

    init(id: UUID = UUID(), weightKg: Double = 20, reps: Int = 10, isCompleted: Bool = false) {
        self.id = id
        self.weightKg = weightKg
        self.reps = reps
        self.isCompleted = isCompleted
    }

    var volumeKg: Double {
        isCompleted ? (weightKg * Double(reps)) : 0
    }

    /// Epley 1RM estimation formula: `weight * (1 + reps / 30)`
    var estimatedOneRepMaxKg: Double {
        guard reps > 0, weightKg > 0 else { return 0 }
        if reps == 1 { return weightKg }
        return weightKg * (1.0 + Double(reps) / 30.0)
    }
}

struct ExerciseLogEntry: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let exerciseID: String
    let exerciseName: String
    let muscleGroup: MuscleGroup
    let primaryImagePath: String?
    var sets: [LoggedSet]

    init(
        id: UUID = UUID(),
        exerciseID: String,
        exerciseName: String,
        muscleGroup: MuscleGroup,
        primaryImagePath: String? = nil,
        sets: [LoggedSet] = [
            LoggedSet(weightKg: 20, reps: 10),
            LoggedSet(weightKg: 20, reps: 10),
            LoggedSet(weightKg: 20, reps: 10)
        ]
    ) {
        self.id = id
        self.exerciseID = exerciseID
        self.exerciseName = exerciseName
        self.muscleGroup = muscleGroup
        self.primaryImagePath = primaryImagePath
        self.sets = sets
    }

    var totalVolumeKg: Double {
        sets.reduce(0) { $0 + $1.volumeKg }
    }

    var completedSetsCount: Int {
        sets.filter(\.isCompleted).count
    }

    var bestEstimated1RMKg: Double {
        sets.filter(\.isCompleted).map(\.estimatedOneRepMaxKg).max() ?? 0
    }
}

struct WorkoutSession: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let title: String
    let date: Date
    let durationSeconds: Int
    let entries: [ExerciseLogEntry]

    init(
        id: UUID = UUID(),
        title: String,
        date: Date = Date(),
        durationSeconds: Int,
        entries: [ExerciseLogEntry]
    ) {
        self.id = id
        self.title = title
        self.date = date
        self.durationSeconds = durationSeconds
        self.entries = entries
    }

    var totalVolumeKg: Double {
        entries.reduce(0) { $0 + $1.totalVolumeKg }
    }

    var totalCompletedSets: Int {
        entries.reduce(0) { $0 + $1.completedSetsCount }
    }
}

enum WeightUnit: String, Codable, CaseIterable, Identifiable, Sendable {
    case kg = "kg"
    case lbs = "lbs"

    var id: String { rawValue }

    func formatted(_ kilograms: Double) -> String {
        let value = self == .kg ? kilograms : kilograms * 2.20462
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(value)) \(rawValue)"
        }
        return String(format: "%.1f %@", value, rawValue)
    }

    func convert(fromKg kilograms: Double) -> Double {
        self == .kg ? kilograms : kilograms * 2.20462
    }
}

enum AppAppearance: String, Codable, CaseIterable, Identifiable, Sendable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"

    var id: String { rawValue }
}

struct UserPreferences: Codable, Equatable, Sendable {
    var weightUnit: WeightUnit = .kg
    var weeklyWorkoutGoal: Int = 4
    var defaultRestSeconds: Int = 90
    var appearance: AppAppearance = .system
    var hapticsEnabled: Bool = true
}

extension WorkoutPlan {
    static let curatedPlans: [WorkoutPlan] = [
        WorkoutPlan(
            id: "ppl-hypertrophy",
            title: "Push / Pull / Legs",
            subtitle: "Classic 6-day or 3-day balanced hypertrophy split targeting every major muscle group twice.",
            level: .intermediate,
            daysPerWeek: 3,
            estimatedMinutes: 50,
            focusMuscles: [.chest, .back, .legs, .shoulders],
            days: [
                WorkoutDay(id: "ppl-push", name: "Push Day", focus: "Chest, Shoulders & Triceps", targetMuscles: [.chest, .shoulders, .triceps], prescribedSets: 3, targetRepRange: "8–12"),
                WorkoutDay(id: "ppl-pull", name: "Pull Day", focus: "Back, Biceps & Forearms", targetMuscles: [.back, .biceps, .forearms], prescribedSets: 3, targetRepRange: "8–12"),
                WorkoutDay(id: "ppl-legs", name: "Legs & Core", focus: "Quads, Glutes & Abs", targetMuscles: [.legs, .glutes, .core], prescribedSets: 4, targetRepRange: "6–12")
            ]
        ),
        WorkoutPlan(
            id: "upper-lower-strength",
            title: "Upper / Lower Power",
            subtitle: "Compound-focused 4-day strength architecture with high recovery efficiency.",
            level: .beginner,
            daysPerWeek: 4,
            estimatedMinutes: 45,
            focusMuscles: [.chest, .back, .legs, .glutes],
            days: [
                WorkoutDay(id: "ul-upper-a", name: "Upper Power", focus: "Bench, Rows & Overhead Press", targetMuscles: [.chest, .back, .shoulders], prescribedSets: 4, targetRepRange: "5–8"),
                WorkoutDay(id: "ul-lower-a", name: "Lower Power", focus: "Squats, Hinges & Core", targetMuscles: [.legs, .glutes, .core], prescribedSets: 4, targetRepRange: "5–8"),
                WorkoutDay(id: "ul-upper-b", name: "Upper Volume", focus: "Incline, Pull-ups & Arms", targetMuscles: [.chest, .biceps, .triceps], prescribedSets: 3, targetRepRange: "10–15"),
                WorkoutDay(id: "ul-lower-b", name: "Lower Volume", focus: "Posterior Chain & Stability", targetMuscles: [.glutes, .legs, .core], prescribedSets: 3, targetRepRange: "10–15")
            ]
        ),
        WorkoutPlan(
            id: "athletic-full-body",
            title: "Athletic Full Body",
            subtitle: "3-day full-body conditioning designed for busy schedules and maximum metabolic output.",
            level: .beginner,
            daysPerWeek: 3,
            estimatedMinutes: 40,
            focusMuscles: [.legs, .chest, .back, .core],
            days: [
                WorkoutDay(id: "fb-a", name: "Full Body A", focus: "Squat, Push & Core", targetMuscles: [.legs, .chest, .core], prescribedSets: 3, targetRepRange: "8–12"),
                WorkoutDay(id: "fb-b", name: "Full Body B", focus: "Hinge, Pull & Shoulders", targetMuscles: [.glutes, .back, .shoulders], prescribedSets: 3, targetRepRange: "8–12"),
                WorkoutDay(id: "fb-c", name: "Full Body C", focus: "Unilateral & Arms", targetMuscles: [.legs, .biceps, .triceps], prescribedSets: 3, targetRepRange: "10–15")
            ]
        )
    ]
}
