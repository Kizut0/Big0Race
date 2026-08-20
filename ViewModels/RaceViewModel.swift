import Foundation
import Observation

@MainActor
@Observable
final class RaceViewModel {
    static let selectionLimit = 4
    var screen: AppScreen = .intro
    var n: Double = 100
    var selected: Set<RaceAlgorithm> = []
    var results: [RaceResult] = []
    var progress: [RaceAlgorithm: Double] = [:]
    var isRacing = false
    var isPreparing = false
    var finishedOrder: [RaceAlgorithm] = []

    private var timer: Timer?
    private var preparationTask: Task<Void, Never>?
    private var raceStart: Date = .now

    /// Orders completed measurements from the fewest operations to the most.
    var sortedResults: [RaceResult] {
        results.sorted { $0.operationCount < $1.operationCount }
    }

    /// Adds or removes a racer while enforcing the four-algorithm limit.
    func toggle(_ algorithm: RaceAlgorithm) {
        if selected.contains(algorithm) { selected.remove(algorithm) }
        else if selected.count < Self.selectionLimit { selected.insert(algorithm) }
    }

    /// Advances from the introduction to race setup.
    func goToSetup() { screen = .setup }

    /// Moves one screen backward and cancels work that no longer belongs onscreen.
    func goBack() {
        switch screen {
        case .intro:
            break
        case .setup:
            preparationTask?.cancel()
            preparationTask = nil
            isPreparing = false
            screen = .intro
        case .race:
            stopRace()
            screen = .setup
        case .reveal:
            screen = .race
        case .reflect:
            screen = .reveal
        }
    }

    /// Measures algorithms off the main actor so quadratic inputs cannot block UI.
    func startRace() {
        guard !isPreparing else { return }
        let count = Int(n)
        let algorithms = RaceAlgorithm.allCases.filter { selected.contains($0) }
        isPreparing = true
        preparationTask = Task { [weak self] in
            let measurements = await Task.detached(priority: .userInitiated) {
                let input = RaceInput.generate(size: count)
                return algorithms.map { ($0, $0.run(input: input)) }
            }.value
            guard let self, !Task.isCancelled else { return }
            self.isPreparing = false
            self.results = measurements.map { RaceResult(algorithm: $0.0, operationCount: $0.1) }
            self.beginAnimation()
        }
    }

    /// Resets animation state and starts the display timer for measured results.
    private func beginAnimation() {
        progress = Dictionary(uniqueKeysWithValues: results.map { ($0.algorithm, 0.0) })
        finishedOrder = []
        screen = .race
        isRacing = true
        raceStart = .now

        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tick() }
        }
    }

    /// Converts elapsed time into per-algorithm progress and finishing order.
    private func tick() {
        let elapsed = Date.now.timeIntervalSince(raceStart)
        var allDone = true
        for result in results {
            let p = min(1.0, elapsed / result.raceDuration)
            progress[result.algorithm] = p
            if p >= 1.0, !finishedOrder.contains(result.algorithm) {
                finishedOrder.append(result.algorithm)
            }
            if p < 1.0 { allDone = false }
        }
        if allDone {
            stopRace()
        }
    }

    /// Opens the measured-result and growth-curve screen.
    func goToReveal() { screen = .reveal }

    /// Opens the ranked plain-language explanation screen.
    func goToReflect() { screen = .reflect }

    /// Replays the existing measurements without generating or measuring new input.
    func replayRace() {
        guard !results.isEmpty else { return }
        stopRace()
        progress = Dictionary(uniqueKeysWithValues: results.map { ($0.algorithm, 0.0) })
        finishedOrder = []
        isRacing = true
        raceStart = .now
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tick() }
        }
    }

    /// Clears the previous race and returns to setup for a new comparison.
    func raceAgain() {
        preparationTask?.cancel()
        preparationTask = nil
        isPreparing = false
        stopRace()
        results = []
        progress = [:]
        finishedOrder = []
        screen = .setup
    }

    /// Invalidates the animation timer and marks the race as stopped.
    private func stopRace() {
        timer?.invalidate()
        timer = nil
        isRacing = false
    }
}
