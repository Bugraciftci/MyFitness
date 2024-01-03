//
//  Muscle.swift
//  MyFitness
//
//  Created by Muhammed Buğra on 2.01.2024.
//

import SwiftUI
import AVKit

struct Muscle: Identifiable {
    var id = UUID()
    var name: String
    var photo: Image
    var videoName: String // Yerel video dosyasının adı
}

let muscles: [Muscle] = [
    Muscle(name: "Biceps", photo: Image("biceps_image"), videoName: "biceps_video"),
    Muscle(name: "Triceps", photo: Image("triceps_image"), videoName: "triceps_video"),
    Muscle(name: "Chest", photo: Image("chest_image"), videoName: "chest_video"),
    Muscle(name: "Back", photo: Image("back_image"), videoName: "back_video"),
    Muscle(name: "Legs", photo: Image("legs_image"), videoName: "legs_video"),
    Muscle(name: "Shoulders", photo: Image("shoulders_image"), videoName: "shoulders_video"),
    Muscle(name: "Abs", photo: Image("abs_image"), videoName: "abs_video"),
    Muscle(name: "Forearms", photo: Image("forearms_image"), videoName: "forearms_video"),
    Muscle(name: "Glutes", photo: Image("glutes_image"), videoName: "glutes_video"),
    Muscle(name: "Calves", photo: Image("calves_image"), videoName: "calves_video")
]
