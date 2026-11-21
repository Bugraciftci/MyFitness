//
//  AppTheme.swift
//  MyFitness
//

import SwiftUI
import UIKit

enum AppTheme {
    // Adaptive Accent & Surface Tokens
    static let brandAccent = Color(red: 0.06, green: 0.65, blue: 0.91)   // Crisp Sky Cyan (#0EA5E9)
    static let energyGreen = Color(red: 0.13, green: 0.77, blue: 0.37)   // Apple Fitness Green
    static let heatOrange  = Color(red: 0.98, green: 0.45, blue: 0.09)   // Intensity Orange
    static let crimson     = Color(red: 0.90, green: 0.18, blue: 0.32)   // Peak Effort Red
    static let indigo      = Color(red: 0.39, green: 0.40, blue: 0.95)   // Strength Indigo

    static let surfacePrimary = Color(uiColor: .systemBackground)
    static let surfaceSecondary = Color(uiColor: .secondarySystemGroupedBackground)
    static let surfaceGrouped = Color(uiColor: .systemGroupedBackground)

    static func accentColor(for muscle: MuscleGroup) -> Color {
        switch muscle {
        case .chest: return crimson
        case .back: return brandAccent
        case .shoulders: return indigo
        case .biceps: return heatOrange
        case .triceps: return Color.purple
        case .legs: return energyGreen
        case .glutes: return Color.pink
        case .core: return Color.teal
        case .forearms: return Color.orange
        }
    }

    static func accentColor(for level: DifficultyLevel) -> Color {
        switch level {
        case .beginner: return energyGreen
        case .intermediate: return brandAccent
        case .expert: return crimson
        }
    }

    static func gradient(for muscle: MuscleGroup) -> LinearGradient {
        let base = accentColor(for: muscle)
        return LinearGradient(
            colors: [base, base.opacity(0.68)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    enum Spacing {
        static let xs: CGFloat = 6
        static let sm: CGFloat = 10
        static let md: CGFloat = 16
        static let lg: CGFloat = 22
    }

    enum Radius {
        static let sm: CGFloat = 10
        static let md: CGFloat = 16
        static let lg: CGFloat = 22
    }
}

enum HapticEngine {
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light, enabled: Bool = true) {
        guard enabled else { return }
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    static func success(enabled: Bool = true) {
        guard enabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

struct GlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat = AppTheme.Radius.md
    var padding: CGFloat = AppTheme.Spacing.md

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(AppTheme.surfaceSecondary)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 3)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
            )
    }
}

extension View {
    func fitnessCard(cornerRadius: CGFloat = AppTheme.Radius.md, padding: CGFloat = AppTheme.Spacing.md) -> some View {
        modifier(GlassCardModifier(cornerRadius: cornerRadius, padding: padding))
    }
}
