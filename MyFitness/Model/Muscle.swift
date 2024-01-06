//
//  Muscle.swift
//  MyFitness
//
//  Created by Muhammed Buğra on 2.01.2024.
//
import SwiftUI

struct Exercise: Identifiable {
    let id = UUID()
    var name: String
    var repetitions: Int
    var imageName: String // Used for the image asset name
    var photo: Image // Used for displaying the image in SwiftUI views
}

struct Muscle: Identifiable {
    let id = UUID()
    var name: String
    var photo: Image // This is correct, as you are assigning an Image
    var videoName: String
    var description: String
    var exercises: [Exercise]
}


let muscles: [Muscle] = [
    Muscle(
        name: "Biceps",
        photo: Image("biceps_image"),
        videoName: "biceps_video",
        description: "Build your bicep muscles with these exercises.",
        exercises: [
            Exercise(name: "Biceps Curl", repetitions: 12, imageName: "biceps_curl_image", photo: Image("biceps_curl_image")),
            Exercise(name: "Hammer Curl", repetitions: 10, imageName: "hammer_curl_image", photo: Image("hammer_curl_image"))
        ]
    ),
    Muscle(
        name: "Triceps",
        photo: Image("triceps_image"),
        videoName: "triceps_video",
        description: "Strengthen and tone the triceps muscles.",
        exercises: [
            Exercise(name: "Tricep Dips", repetitions: 15, imageName: "tricep_dips_image",photo: Image("biceps_curl_image")),
            Exercise(name: "Tricep Kickback", repetitions: 12, imageName: "tricep_kickback_image",photo: Image("biceps_curl_image"))
        ]
    ),
    Muscle(
        name: "Chest",
        photo: Image("chest_image"),
        videoName: "chest_video",
        description: "Build your pectoral muscles with these exercises.",
        exercises: [
            Exercise(name: "Bench Press", repetitions: 10, imageName: "bench_press_image",photo: Image("biceps_curl_image")),
            Exercise(name: "Push Ups", repetitions: 20, imageName: "push_ups_image",photo: Image("biceps_curl_image"))
        ]
    ),
    Muscle(
        name: "Back",
        photo: Image("back_image"),
        videoName: "back_video",
        description: "Target your upper and lower back muscles.",
        exercises: [
            Exercise(name: "Pull Ups", repetitions: 8, imageName: "pull_ups_image",photo: Image("biceps_curl_image")),
            Exercise(name: "Deadlift", repetitions: 10, imageName: "deadlift_image",photo: Image("biceps_curl_image"))
        ]
    ),
    Muscle(
        name: "Legs",
        photo: Image("legs_image"),
        videoName: "legs_video",
        description: "Exercises for quadriceps, hamstrings, and calves.",
        exercises: [
            Exercise(name: "Squats", repetitions: 15, imageName: "squats_image",photo: Image("biceps_curl_image")),
            Exercise(name: "Lunges", repetitions: 12, imageName: "lunges_image",photo: Image("biceps_curl_image")),
            // Add more leg exercises here...
        ]
    ),
    Muscle(
        name: "Shoulders",
        photo: Image("shoulders_image"),
        videoName: "shoulders_video",
        description: "Workouts to build shoulder strength and mobility.",
        exercises: [
            Exercise(name: "Shoulder Press", repetitions: 10, imageName: "shoulder_press_image",photo: Image("biceps_curl_image")),
            Exercise(name: "Lateral Raise", repetitions: 15, imageName: "lateral_raise_image",photo: Image("biceps_curl_image")),
            // Add more shoulder exercises here...
        ]
    ),
    Muscle(
        name: "Abs",
        photo: Image("abs_image"),
        videoName: "abs_video",
        description: "Core exercises for a strong abdominal region.",
        exercises: [
            Exercise(name: "Crunches", repetitions: 20, imageName: "crunches_image",photo: Image("biceps_curl_image")),
            Exercise(name: "Plank", repetitions: 60, imageName: "plank_image",photo: Image("biceps_curl_image")), // Repetitions could represent seconds here
            // Add more ab exercises here...
        ]
    ),
    Muscle(
        name: "Forearms",
        photo: Image("forearms_image"),
        videoName: "forearms_video",
        description: "Exercises for grip strength and forearm girth.",
        exercises: [
            Exercise(name: "Wrist Curl", repetitions: 15, imageName: "wrist_curl_image",photo: Image("biceps_curl_image")),
            Exercise(name: "Reverse Wrist Curl", repetitions: 15, imageName: "reverse_wrist_curl_image",photo: Image("biceps_curl_image")),
            // Add more forearm exercises here...
        ]
    ),
    Muscle(
        name: "Glutes",
        photo: Image("glutes_image"),
        videoName: "glutes_video",
        description: "Strengthen your glutes for better posture and power.",
        exercises: [
            Exercise(name: "Hip Thrust", repetitions: 12, imageName: "hip_thrust_image",photo: Image("biceps_curl_image")),
            Exercise(name: "Glute Bridge", repetitions: 15, imageName: "glute_bridge_image",photo: Image("biceps_curl_image")),
            // Add more glute exercises here...
        ]
    ),
    Muscle(
        name: "Calves",
        photo: Image("calves_image"),
        videoName: "calves_video",
        description: "Calf exercises for lower leg development.",
        exercises: [
            Exercise(name: "Standing Calf Raise", repetitions: 20, imageName: "standing_calf_raise_image",photo: Image("biceps_curl_image")),
            Exercise(name: "Seated Calf Raise", repetitions: 20, imageName: "seated_calf_raise_image",photo: Image("biceps_curl_image")),
            // Add more calf exercises here...
        ]
    )
]
