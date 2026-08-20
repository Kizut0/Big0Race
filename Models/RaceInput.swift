import Foundation

/// The single input shared by every algorithm in one race. Search methods also share the same sorted view and target.
struct RaceInput: Sendable {
    let unsortedData: [Int]
    let sortedData: [Int]
    let searchTarget: Int

    /// Builds one random input shared by every racer in a comparison.
    /// Search algorithms use `sortedData` and the same guaranteed-present target; sorting algorithms receive an identical copy of `unsortedData`.
    static func generate(size: Int) -> RaceInput {
        precondition(size > 0)
        let unsortedData = (0..<size).map { _ in Int.random(in: 0...1_000_000) }
        let sortedData = unsortedData.sorted()
        let searchTarget = sortedData[Int.random(in: sortedData.indices)]
        return RaceInput(
            unsortedData: unsortedData,
            sortedData: sortedData,
            searchTarget: searchTarget
        )
    }
}

