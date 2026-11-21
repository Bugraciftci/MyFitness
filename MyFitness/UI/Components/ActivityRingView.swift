//
//  ActivityRingView.swift
//  MyFitness
//

import SwiftUI

/// Smooth Apple Fitness-inspired radial progress ring.
struct ActivityRingView: View {
    let progress: Double
    let color: Color
    var lineWidth: CGFloat = 10
    var size: CGFloat = 78
    var centerTitle: String? = nil
    var centerSubtitle: String? = nil

    private var clampedProgress: Double {
        min(max(progress, 0), 1)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.18), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: clampedProgress)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [color.opacity(0.75), color]),
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360)
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.65, dampingFraction: 0.8), value: clampedProgress)

            if let centerTitle {
                VStack(spacing: 1) {
                    Text(centerTitle)
                        .font(.system(.headline, design: .rounded).weight(.bold))
                        .monospacedDigit()
                    if let centerSubtitle {
                        Text(centerSubtitle)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .frame(width: size, height: size)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(centerTitle ?? "Progress")
        .accessibilityValue("\(Int(clampedProgress * 100)) percent")
    }
}

#Preview {
    ActivityRingView(progress: 0.75, color: AppTheme.energyGreen, centerTitle: "3/4", centerSubtitle: "Goal")
        .padding()
}
