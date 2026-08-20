import Foundation

struct RaceResult: Identifiable {
    let id = UUID()
    let algorithm: RaceAlgorithm
    let operationCount: Int
    /// Duration for an illustrative, log-compressed animation. This is not a literal operation replay or a wall-clock benchmark.
    var raceDuration: Double {
        let minDuration = 0.9
        let scale = 0.35
        return minDuration + scale * log2(Double(operationCount) + 1)
    }
}

enum AppScreen {
    case intro
    case setup
    case race
    case reveal
    case reflect
}
