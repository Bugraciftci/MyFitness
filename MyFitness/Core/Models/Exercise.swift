//
//  Exercise.swift
//  MyFitness
//

import Foundation

/// Value-type exercise model matching `yuhonas/free-exercise-db` JSON schema.
struct Exercise: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let name: String
    let force: String?
    let level: DifficultyLevel
    let mechanic: String?
    let equipment: String?
    let primaryMuscles: [String]
    let secondaryMuscles: [String]
    let instructions: [String]
    let category: String
    let images: [String]

    static let imageBaseURL = "https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/"

    var imageURLs: [URL] {
        images.compactMap { path in
            let encoded = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? path
            return URL(string: Self.imageBaseURL + encoded)
        }
    }

    var primaryImageURL: URL? {
        imageURLs.first
    }

    var muscleGroup: MuscleGroup {
        MuscleGroup.from(rawMuscle: primaryMuscles.first ?? "")
    }

    var formattedEquipment: String {
        guard let equipment, !equipment.trimmingCharacters(in: .whitespaces).isEmpty else {
            return "Bodyweight"
        }
        return equipment.capitalized
    }

    var formattedMechanic: String {
        (mechanic ?? "Compound").capitalized
    }

    var formattedForce: String {
        (force ?? "Dynamic").capitalized
    }

    enum CodingKeys: String, CodingKey {
        case id, name, force, level, mechanic, equipment
        case primaryMuscles, secondaryMuscles, instructions, category, images
    }

    init(
        id: String,
        name: String,
        force: String? = nil,
        level: DifficultyLevel = .intermediate,
        mechanic: String? = nil,
        equipment: String? = nil,
        primaryMuscles: [String],
        secondaryMuscles: [String] = [],
        instructions: [String] = [],
        category: String = "strength",
        images: [String] = []
    ) {
        self.id = id
        self.name = name
        self.force = force
        self.level = level
        self.mechanic = mechanic
        self.equipment = equipment
        self.primaryMuscles = primaryMuscles
        self.secondaryMuscles = secondaryMuscles
        self.instructions = instructions
        self.category = category
        self.images = images
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        force = try container.decodeIfPresent(String.self, forKey: .force)
        let rawLevel = try container.decodeIfPresent(String.self, forKey: .level) ?? "intermediate"
        level = DifficultyLevel(rawValue: rawLevel.lowercased()) ?? .intermediate
        mechanic = try container.decodeIfPresent(String.self, forKey: .mechanic)
        equipment = try container.decodeIfPresent(String.self, forKey: .equipment)
        primaryMuscles = try container.decodeIfPresent([String].self, forKey: .primaryMuscles) ?? []
        secondaryMuscles = try container.decodeIfPresent([String].self, forKey: .secondaryMuscles) ?? []
        instructions = try container.decodeIfPresent([String].self, forKey: .instructions) ?? []
        category = try container.decodeIfPresent(String.self, forKey: .category) ?? "strength"
        images = try container.decodeIfPresent([String].self, forKey: .images) ?? []
    }
}

enum DifficultyLevel: String, Codable, CaseIterable, Identifiable, Sendable {
    case beginner
    case intermediate
    case expert

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .beginner: return "Beginner"
        case .intermediate: return "Intermediate"
        case .expert: return "Expert"
        }
    }
}

enum MuscleGroup: String, CaseIterable, Identifiable, Codable, Sendable {
    case chest = "Chest"
    case back = "Back"
    case shoulders = "Shoulders"
    case biceps = "Biceps"
    case triceps = "Triceps"
    case legs = "Legs"
    case glutes = "Glutes"
    case core = "Core"
    case forearms = "Forearms"

    var id: String { rawValue }

    var symbolName: String {
        switch self {
        case .chest: return "figure.strengthtraining.traditional"
        case .back: return "figure.rowing"
        case .shoulders: return "figure.arms.open"
        case .biceps: return "dumbbell.fill"
        case .triceps: return "bolt.fill"
        case .legs: return "figure.run"
        case .glutes: return "flame.fill"
        case .core: return "figure.core.training"
        case .forearms: return "hand.raised.fill"
        }
    }

    var subtitle: String {
        switch self {
        case .chest: return "Pectorals & pressing power"
        case .back: return "Lats, traps & upper back"
        case .shoulders: return "Deltoids & overhead stability"
        case .biceps: return "Arm flexors & peak strength"
        case .triceps: return "Lockout & arm volume"
        case .legs: return "Quads, hamstrings & calves"
        case .glutes: return "Hip drive & posterior chain"
        case .core: return "Abs, obliques & bracing"
        case .forearms: return "Grip & wrist conditioning"
        }
    }

    static func from(rawMuscle: String) -> MuscleGroup {
        switch rawMuscle.lowercased() {
        case "chest":
            return .chest
        case "lats", "middle back", "lower back", "traps", "neck":
            return .back
        case "shoulders":
            return .shoulders
        case "biceps":
            return .biceps
        case "triceps":
            return .triceps
        case "quadriceps", "hamstrings", "calves", "adductors", "abductors":
            return .legs
        case "glutes":
            return .glutes
        case "abdominals":
            return .core
        case "forearms":
            return .forearms
        default:
            return .core
        }
    }
}

enum EquipmentFilter: String, CaseIterable, Identifiable, Sendable {
    case all = "All"
    case barbell = "Barbell"
    case dumbbell = "Dumbbell"
    case bodyweight = "Body Only"
    case cable = "Cable"
    case machine = "Machine"

    var id: String { rawValue }

    func matches(_ exercise: Exercise) -> Bool {
        switch self {
        case .all:
            return true
        case .bodyweight:
            let eq = (exercise.equipment ?? "").lowercased()
            return eq.isEmpty || eq == "body only"
        default:
            return (exercise.equipment ?? "").lowercased() == rawValue.lowercased()
        }
    }
}

extension Exercise {
    static let sample = Exercise(
        id: "Barbell_Bench_Press_-_Medium_Grip",
        name: "Barbell Bench Press - Medium Grip",
        force: "push",
        level: .intermediate,
        mechanic: "compound",
        equipment: "barbell",
        primaryMuscles: ["chest"],
        secondaryMuscles: ["shoulders", "triceps"],
        instructions: [
            "Lie back on a flat bench. Using a medium width grip, lift the bar from the rack and hold it straight over you with your arms locked.",
            "From the starting position, breathe in and begin coming down slowly until the bar touches your middle chest.",
            "After a brief pause, push the bar back to the starting position as you breathe out, focusing on driving through your chest."
        ],
        category: "strength",
        images: [
            "Barbell_Bench_Press_-_Medium_Grip/0.jpg",
            "Barbell_Bench_Press_-_Medium_Grip/1.jpg"
        ]
    )
}
