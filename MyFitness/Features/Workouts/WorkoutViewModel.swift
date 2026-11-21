//
//  WorkoutViewModel.swift
//  MyFitness
//

import Combine
import Foundation

struct DailyVolumePoint: Identifiable, Hashable {
    let id: String
    let dayLabel: String
    let volumeKg: Double
    let sessionsCount: Int
}

@MainActor
final class WorkoutViewModel: ObservableObject {
    @Published private(set) var curatedPlans: [WorkoutPlan] = WorkoutPlan.curatedPlans
    @Published private(set) var completedSessions: [WorkoutSession] = []

    // Active Live Session State
    @Published var isSessionActive = false
    @Published var activeSessionTitle: String = ""
    @Published var activeEntries: [ExerciseLogEntry] = []
    @Published private(set) var elapsedSeconds: Int = 0
    @Published private(set) var restSecondsRemaining: Int = 0
    @Published var lastFinishedSession: WorkoutSession?

    private let store: WorkoutStoreProtocol
    private var timerCancellable: AnyCancellable?

    init(store: WorkoutStoreProtocol) {
        self.store = store
        self.completedSessions = store.loadSessions()
    }

    // MARK: - Session Lifecycle

    func startSession(title: String, exercises: [Exercise], setsPerExercise: Int = 3) {
        activeSessionTitle = title
        activeEntries = exercises.map { exercise in
            let initialSets = (0..<max(1, setsPerExercise)).map { _ in
                LoggedSet(weightKg: exercise.formattedEquipment == "Bodyweight" ? 0 : 20, reps: 10, isCompleted: false)
            }
            return ExerciseLogEntry(
                exerciseID: exercise.id,
                exerciseName: exercise.name,
                muscleGroup: exercise.muscleGroup,
                primaryImagePath: exercise.images.first,
                sets: initialSets
            )
        }
        elapsedSeconds = 0
        restSecondsRemaining = 0
        isSessionActive = true
        startTicking()
    }

    func startQuickSession(with exercise: Exercise) {
        startSession(title: exercise.name, exercises: [exercise], setsPerExercise: 3)
    }

    func addExerciseToActiveSession(_ exercise: Exercise) {
        guard !activeEntries.contains(where: { $0.exerciseID == exercise.id }) else { return }
        let entry = ExerciseLogEntry(
            exerciseID: exercise.id,
            exerciseName: exercise.name,
            muscleGroup: exercise.muscleGroup,
            primaryImagePath: exercise.images.first
        )
        activeEntries.append(entry)
    }

    func addSet(toEntryID entryID: UUID) {
        guard let idx = activeEntries.firstIndex(where: { $0.id == entryID }) else { return }
        let previous = activeEntries[idx].sets.last
        let newSet = LoggedSet(
            weightKg: previous?.weightKg ?? 20,
            reps: previous?.reps ?? 10,
            isCompleted: false
        )
        activeEntries[idx].sets.append(newSet)
    }

    func removeSet(entryID: UUID, setID: UUID) {
        guard let idx = activeEntries.firstIndex(where: { $0.id == entryID }) else { return }
        guard activeEntries[idx].sets.count > 1 else { return }
        activeEntries[idx].sets.removeAll { $0.id == setID }
    }

    func toggleSetCompletion(entryID: UUID, setID: UUID, defaultRestSeconds: Int = 90) {
        guard let eIdx = activeEntries.firstIndex(where: { $0.id == entryID }),
              let sIdx = activeEntries[eIdx].sets.firstIndex(where: { $0.id == setID }) else { return }

        activeEntries[eIdx].sets[sIdx].isCompleted.toggle()
        if activeEntries[eIdx].sets[sIdx].isCompleted {
            startRestTimer(seconds: defaultRestSeconds)
        }
    }

    func updateSet(entryID: UUID, setID: UUID, weightKg: Double, reps: Int) {
        guard let eIdx = activeEntries.firstIndex(where: { $0.id == entryID }),
              let sIdx = activeEntries[eIdx].sets.firstIndex(where: { $0.id == setID }) else { return }
        activeEntries[eIdx].sets[sIdx].weightKg = max(0, weightKg)
        activeEntries[eIdx].sets[sIdx].reps = max(1, reps)
    }

    func startRestTimer(seconds: Int) {
        restSecondsRemaining = max(0, seconds)
    }

    func skipRestTimer() {
        restSecondsRemaining = 0
    }

    @discardableResult
    func finishActiveSession() -> WorkoutSession? {
        stopTicking()
        let session = WorkoutSession(
            title: activeSessionTitle.isEmpty ? "Custom Workout" : activeSessionTitle,
            date: Date(),
            durationSeconds: max(60, elapsedSeconds),
            entries: activeEntries
        )
        if session.totalCompletedSets > 0 {
            completedSessions.insert(session, at: 0)
            store.saveSessions(completedSessions)
            lastFinishedSession = session
        }
        isSessionActive = false
        activeEntries = []
        elapsedSeconds = 0
        restSecondsRemaining = 0
        return session.totalCompletedSets > 0 ? session : nil
    }

    func discardActiveSession() {
        stopTicking()
        isSessionActive = false
        activeEntries = []
        elapsedSeconds = 0
        restSecondsRemaining = 0
    }

    func deleteSession(id: UUID) {
        completedSessions.removeAll { $0.id == id }
        store.saveSessions(completedSessions)
    }

    func reloadFromStore() {
        completedSessions = store.loadSessions()
    }

    // MARK: - Analytics & Derived Metrics

    var activeSessionVolumeKg: Double {
        activeEntries.reduce(0) { $0 + $1.totalVolumeKg }
    }

    var activeCompletedSetsCount: Int {
        activeEntries.reduce(0) { $0 + $1.completedSetsCount }
    }

    var sessionsThisWeekCount: Int {
        let calendar = Calendar.current
        guard let weekAgo = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: Date())) else {
            return 0
        }
        return completedSessions.filter { $0.date >= weekAgo }.count
    }

    var totalLifetimeVolumeKg: Double {
        completedSessions.reduce(0) { $0 + $1.totalVolumeKg }
    }

    var weeklyVolumeChartData: [DailyVolumePoint] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"

        return (0..<7).reversed().compactMap { offset -> DailyVolumePoint? in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            let daySessions = completedSessions.filter { calendar.isDate($0.date, inSameDayAs: date) }
            let totalVol = daySessions.reduce(0) { $0 + $1.totalVolumeKg }
            return DailyVolumePoint(
                id: "\(offset)",
                dayLabel: formatter.string(from: date),
                volumeKg: totalVol,
                sessionsCount: daySessions.count
            )
        }
    }

    var formattedElapsedTime: String {
        let mins = elapsedSeconds / 60
        let secs = elapsedSeconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }

    private func startTicking() {
        stopTicking()
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                self.elapsedSeconds += 1
                if self.restSecondsRemaining > 0 {
                    self.restSecondsRemaining -= 1
                }
            }
    }

    private func stopTicking() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }
}
