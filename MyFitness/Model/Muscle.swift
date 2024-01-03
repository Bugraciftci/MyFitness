//
//  Muscle.swift
//  MyFitness
//
//  Created by Muhammed Buğra on 2.01.2024.
//
import SwiftUI

struct Exercise {
    var name: String
    var photo: Image
    var videoName: String
}

struct Muscle {
    var name: String
    var photo: Image
    var videoName: String
    var exercises: [Exercise]
}

let muscles: [Muscle] = [
    Muscle(
        name: "Biceps",
        photo: Image("biceps_image"),
        videoName: "biceps_video",
        exercises: [
            Exercise(name: "Biceps Curl", photo: Image("biceps_curl_image"), videoName: "biceps_curl_video"),
            Exercise(name: "Hammer Curl", photo: Image("hammer_curl_image"), videoName: "hammer_curl_video")
        ]
    ),
    Muscle(
        name: "Triceps",
        photo: Image("triceps_image"),
        videoName: "triceps_video",
        exercises: [
            Exercise(name: "Tricep Dips", photo: Image("tricep_dips_image"), videoName: "tricep_dips_video"),
            Exercise(name: "Tricep Kickback", photo: Image("tricep_kickback_image"), videoName: "tricep_kickback_video")
        ]
    ),
    Muscle(
        name: "Chest",
        photo: Image("chest_image"),
        videoName: "chest_video",
        exercises: [
            Exercise(name: "Bench Press", photo: Image("bench_press_image"), videoName: "bench_press_video"),
            Exercise(name: "Push Ups", photo: Image("push_ups_image"), videoName: "push_ups_video")
        ]
    ),
    Muscle(
        name: "Back",
        photo: Image("back_image"),
        videoName: "back_video",
        exercises: [
            Exercise(name: "Pull Ups", photo: Image("pull_ups_image"), videoName: "pull_ups_video"),
            Exercise(name: "Deadlift", photo: Image("deadlift_image"), videoName: "deadlift_video")
        ]
    ),
    Muscle(
        name: "Legs",
        photo: Image("legs_image"),
        videoName: "legs_video",
        exercises: [
            Exercise(name: "Squats", photo: Image("squats_image"), videoName: "squats_video"),
            Exercise(name: "Lunges", photo: Image("lunges_image"), videoName: "lunges_video")
        ]
    ),
    Muscle(
        name: "Shoulders",
        photo: Image("shoulders_image"),
        videoName: "shoulders_video",
        exercises: [
            Exercise(name: "Shoulder Press", photo: Image("shoulder_press_image"), videoName: "shoulder_press_video"),
            Exercise(name: "Lateral Raise", photo: Image("lateral_raise_image"), videoName: "lateral_raise_video")
        ]
    ),
    Muscle(
        name: "Abs",
        photo: Image("abs_image"),
        videoName: "abs_video",
        exercises: [
            Exercise(name: "Crunches", photo: Image("crunches_image"), videoName: "crunches_video"),
            Exercise(name: "Plank", photo: Image("plank_image"), videoName: "plank_video")
        ]
    ),
    Muscle(
        name: "Forearms",
        photo: Image("forearms_image"),
        videoName: "forearms_video",
        exercises: [
            Exercise(name: "Wrist Curl", photo: Image("wrist_curl_image"), videoName: "wrist_curl_video"),
            Exercise(name: "Reverse Wrist Curl", photo: Image("reverse_wrist_curl_image"), videoName: "reverse_wrist_curl_video")
        ]
    ),
    Muscle(
        name: "Glutes",
        photo: Image("glutes_image"),
        videoName: "glutes_video",
        exercises: [
            Exercise(name: "Hip Thrust", photo: Image("hip_thrust_image"), videoName: "hip_thrust_video"),
            Exercise(name: "Glute Bridge", photo: Image("glute_bridge_image"), videoName: "glute_bridge_video")
        ]
    ),
    Muscle(
        name: "Calves",
        photo: Image("calves_image"),
        videoName: "calves_video",
        exercises: [
            Exercise(name: "Standing Calf Raise", photo: Image("standing_calf_raise_image"), videoName: "standing_calf_raise_video"),
            Exercise(name: "Seated Calf Raise", photo: Image("seated_calf_raise_image"), videoName: "seated_calf_raise_video")
        ]
    )
]
