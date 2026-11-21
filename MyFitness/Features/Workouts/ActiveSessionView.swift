//
//  ActiveSessionView.swift
//  MyFitness
//

import SwiftUI

struct ActiveSessionView: View {
    @ObservedObject var workoutVM: WorkoutViewModel
    @ObservedObject var discoverVM: DiscoverViewModel
    @ObservedObject var profileVM: ProfileViewModel

    @State private var showDiscardAlert = false
    @State private var showAddExerciseSheet = false
    @FocusState private var isInputFocused: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.md) {
                    sessionMetricsHeader

                    if workoutVM.restSecondsRemaining > 0 {
                        restTimerBanner
                    }

                    ForEach(workoutVM.activeEntries) { entry in
                        exerciseLoggerCard(entry)
                    }

                    Button {
                        showAddExerciseSheet = true
                    } label: {
                        Label("Add Another Exercise", systemImage: "plus.circle.fill")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.bordered)
                    .tint(AppTheme.brandAccent)
                }
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.vertical, AppTheme.Spacing.sm)
            }
            .background(AppTheme.surfaceGrouped)
            .navigationTitle(workoutVM.activeSessionTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel", role: .destructive) {
                        if workoutVM.activeCompletedSetsCount > 0 {
                            showDiscardAlert = true
                        } else {
                            workoutVM.discardActiveSession()
                        }
                    }
                    .foregroundStyle(AppTheme.crimson)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Finish") {
                        workoutVM.finishActiveSession()
                        HapticEngine.success(enabled: profileVM.preferences.hapticsEnabled)
                    }
                    .font(.headline)
                    .disabled(workoutVM.activeCompletedSetsCount == 0)
                }

                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { isInputFocused = false }
                }
            }
            .alert("Discard Workout?", isPresented: $showDiscardAlert) {
                Button("Keep Training", role: .cancel) {}
                Button("Discard", role: .destructive) {
                    workoutVM.discardActiveSession()
                }
            } message: {
                Text("You have \(workoutVM.activeCompletedSetsCount) completed sets that will not be saved.")
            }
            .sheet(isPresented: $showAddExerciseSheet) {
                ExercisePickerSheet(discoverVM: discoverVM) { exercise in
                    workoutVM.addExerciseToActiveSession(exercise)
                }
            }
        }
    }

    private var sessionMetricsHeader: some View {
        HStack(spacing: 10) {
            StatPillView(
                title: "Elapsed",
                value: workoutVM.formattedElapsedTime,
                symbol: "timer",
                color: AppTheme.brandAccent
            )
            StatPillView(
                title: "Volume",
                value: profileVM.preferences.weightUnit.formatted(workoutVM.activeSessionVolumeKg),
                symbol: "scalemass.fill",
                color: AppTheme.energyGreen
            )
            StatPillView(
                title: "Sets",
                value: "\(workoutVM.activeCompletedSetsCount)",
                symbol: "checkmark.circle.fill",
                color: AppTheme.heatOrange
            )
        }
    }

    private var restTimerBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "hourglass")
                .font(.headline)
                .foregroundStyle(.white)
            VStack(alignment: .leading, spacing: 2) {
                Text("Rest Timer")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.85))
                Text(String(format: "%02d:%02d remaining", workoutVM.restSecondsRemaining / 60, workoutVM.restSecondsRemaining % 60))
                    .font(.system(.headline, design: .rounded).weight(.bold))
                    .monospacedDigit()
                    .foregroundStyle(.white)
            }
            Spacer()
            Button("Skip") {
                workoutVM.skipRestTimer()
            }
            .font(.caption.weight(.bold))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.22), in: Capsule())
            .foregroundStyle(.white)
        }
        .padding(14)
        .background(AppTheme.brandAccent.gradient, in: RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
    }

    private func exerciseLoggerCard(_ entry: ExerciseLogEntry) -> some View {
        let imgURL = entry.primaryImagePath.flatMap { path in
            let encoded = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? path
            return URL(string: Exercise.imageBaseURL + encoded)
        }

        return VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                AsyncCachedImage(url: imgURL, fallbackSymbol: entry.muscleGroup.symbolName)
                    .frame(width: 48, height: 48)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.exerciseName)
                        .font(.subheadline.weight(.bold))
                        .lineLimit(2)
                    HStack(spacing: 8) {
                        Text(entry.muscleGroup.rawValue)
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(AppTheme.accentColor(for: entry.muscleGroup))
                        if entry.bestEstimated1RMKg > 0 {
                            Text("Est. 1RM: \(profileVM.preferences.weightUnit.formatted(entry.bestEstimated1RMKg))")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                Spacer()
            }

            // Column Labels
            HStack {
                Text("SET").frame(width: 34, alignment: .leading)
                Text(profileVM.preferences.weightUnit.rawValue.uppercased()).frame(maxWidth: .infinity)
                Text("REPS").frame(maxWidth: .infinity)
                Text("DONE").frame(width: 44, alignment: .trailing)
            }
            .font(.caption2.weight(.bold))
            .foregroundStyle(.secondary)

            ForEach(Array(entry.sets.enumerated()), id: \.element.id) { idx, setItem in
                HStack(spacing: 10) {
                    Text("\(idx + 1)")
                        .font(.caption.weight(.bold))
                        .frame(width: 34, alignment: .leading)
                        .foregroundStyle(.secondary)

                    TextField(
                        "0",
                        value: Binding(
                            get: { setItem.weightKg },
                            set: { workoutVM.updateSet(entryID: entry.id, setID: setItem.id, weightKg: $0, reps: setItem.reps) }
                        ),
                        format: .number
                    )
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                    .focused($isInputFocused)
                    .padding(.vertical, 7)
                    .background(Color.primary.opacity(0.05), in: RoundedRectangle(cornerRadius: 8))

                    TextField(
                        "10",
                        value: Binding(
                            get: { setItem.reps },
                            set: { workoutVM.updateSet(entryID: entry.id, setID: setItem.id, weightKg: setItem.weightKg, reps: $0) }
                        ),
                        format: .number
                    )
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .focused($isInputFocused)
                    .padding(.vertical, 7)
                    .background(Color.primary.opacity(0.05), in: RoundedRectangle(cornerRadius: 8))

                    Button {
                        workoutVM.toggleSetCompletion(
                            entryID: entry.id,
                            setID: setItem.id,
                            defaultRestSeconds: profileVM.preferences.defaultRestSeconds
                        )
                        HapticEngine.impact(.medium, enabled: profileVM.preferences.hapticsEnabled)
                    } label: {
                        Image(systemName: setItem.isCompleted ? "checkmark.circle.fill" : "circle")
                            .font(.title3)
                            .foregroundStyle(setItem.isCompleted ? AppTheme.energyGreen : .secondary)
                            .frame(width: 44, alignment: .trailing)
                    }
                    .buttonStyle(.plain)
                }
            }

            Button {
                workoutVM.addSet(toEntryID: entry.id)
                HapticEngine.impact(.soft, enabled: profileVM.preferences.hapticsEnabled)
            } label: {
                Label("Add Set", systemImage: "plus")
                    .font(.caption.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.primary.opacity(0.05), in: RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
        }
        .fitnessCard()
    }
}

private struct ExercisePickerSheet: View {
    @ObservedObject var discoverVM: DiscoverViewModel
    let onSelect: (Exercise) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""

    private var matches: [Exercise] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if q.isEmpty { return Array(discoverVM.allExercises.prefix(60)) }
        return discoverVM.allExercises.filter {
            $0.name.lowercased().contains(q) || $0.muscleGroup.rawValue.lowercased().contains(q)
        }
    }

    var body: some View {
        NavigationStack {
            List(matches) { ex in
                Button {
                    onSelect(ex)
                    dismiss()
                } label: {
                    HStack(spacing: 12) {
                        AsyncCachedImage(url: ex.primaryImageURL, fallbackSymbol: ex.muscleGroup.symbolName)
                            .frame(width: 44, height: 44)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(ex.name)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.primary)
                            Text("\(ex.muscleGroup.rawValue) · \(ex.formattedEquipment)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .searchable(text: $query, prompt: "Search exercises")
            .navigationTitle("Add Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}
