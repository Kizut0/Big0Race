import SwiftUI

/// Presentation-only visualization subsystem. It maps normalized race progress to an illustrative 72-bar teaching animation; measured algorithm work lives in `RaceAlgorithm`, and orchestration lives in `RaceViewModel`.
struct AlgorithmRacePanel: View {
    let result: RaceResult
    let progress: Double
    let place: String?
    let bars: [Double]
    let isRacing: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(result.algorithm.displayName)
                    .font(.subheadline.weight(.semibold))
                Text(result.algorithm.bigOLabel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                if let place {
                    Text(place)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.orange)
                }
                Text("\(result.operationCount) ops")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(result.algorithm.displayName), \(result.algorithm.bigOLabel)")
            .accessibilityValue("\(result.operationCount) measured operations. \(place.map { "Finished \($0)." } ?? "Race in progress, \(Int(progress * 100)) percent complete.")")

            AlgorithmVisualizer(
                algorithm: result.algorithm,
                bars: bars,
                progress: progress,
                isRacing: isRacing
            )

            AnimationDetail(
                algorithm: result.algorithm,
                progress: progress,
                itemCount: bars.count
            )
        }
        .padding(12)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))
    }
}

private struct AnimationDetail: View {
    let algorithm: RaceAlgorithm
    let progress: Double
    let itemCount: Int

    private var target: Int {
        // A target past the midpoint lets sequential searches demonstrate meaningful traversal within the fixed-size teaching sample.
        max(0, min(itemCount - 1, Int(Double(itemCount) * 0.62)))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 12) {
                LegendItem(symbol: "scope", color: .green, text: greenMeaning)
                LegendItem(symbol: "line.diagonal", color: .red, text: redMeaning)
                LegendItem(symbol: "minus", color: .white, text: whiteMeaning)
            }

            Text(stepText)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Current animation state")
        .accessibilityValue("\(stepText) Green means \(greenMeaning). Red means \(redMeaning). White means \(whiteMeaning).")
    }

    private var greenMeaning: String {
        switch algorithm {
        case .constantLookup: return "direct index"
        case .linearSearch, .jumpSearch, .interpolationSearch, .exponentialSearch: return "current probe"
        case .binarySearch: return "middle probe"
        case .selectionSort: return "current minimum"
        case .insertionSort: return "key item"
        case .mergeSort: return "merge split"
        case .quickSort: return "pivot"
        case .heapSort: return "heap root"
        case .shellSort: return "current item"
        case .bubbleSort: return "right compare"
        }
    }

    private var redMeaning: String {
        switch algorithm {
        case .constantLookup: return "not touched"
        case .linearSearch: return "already checked"
        case .binarySearch, .exponentialSearch: return "discarded range"
        case .jumpSearch: return "active block"
        case .interpolationSearch: return "probe zone"
        case .selectionSort: return "scan range"
        case .insertionSort: return "shifting"
        case .mergeSort: return "merging block"
        case .quickSort: return "partition range"
        case .heapSort: return "heap area"
        case .shellSort: return "same gap"
        case .bubbleSort: return "left compare"
        }
    }

    private var whiteMeaning: String {
        switch algorithm {
        case .constantLookup: return "other data"
        case .linearSearch, .jumpSearch, .interpolationSearch, .exponentialSearch: return "unchecked"
        case .binarySearch: return "still possible"
        case .selectionSort, .insertionSort, .mergeSort, .quickSort, .heapSort, .shellSort, .bubbleSort:
            return "waiting/sorted"
        }
    }

    private var stepText: String {
        let p = min(max(progress, 0), 1)
        let current = min(itemCount - 1, Int(Double(max(itemCount - 1, 1)) * p))

        switch algorithm {
        case .constantLookup:
            return "Reads one known array position immediately. No loop is needed, so n does not change the step count."
        case .linearSearch:
            return "Checks bar \(min(target, current) + 1) after scanning every earlier bar from left to right."
        case .binarySearch:
            let window = RaceVisualizationEngine.binaryWindow(itemCount: itemCount, target: target, progress: p)
            return "Keeps only bars \(window.low + 1)-\(window.high + 1), probes the middle at bar \(window.mid + 1), then halves again."
        case .jumpSearch:
            let step = max(1, Int(Double(itemCount).squareRoot()))
            let block = min(target / step, Int((Double(target / step) + 1) * p))
            return "Jumps by blocks of \(step). The red block is block \(block + 1), then it scans inside that block."
        case .interpolationSearch:
            let probe = min(target, max(0, Int(Double(target) * min(1, p * 1.18))))
            return "Estimates the likely position from value spacing and probes around bar \(probe + 1)."
        case .exponentialSearch:
            if p < 0.55 {
                let step = min(max(0, Int(p / 0.55 * 7)), 7)
                let bound = min(itemCount - 1, 1 << step)
                return "Doubles the checked range up to bar \(bound + 1) until the target is covered."
            }
            let window = RaceVisualizationEngine.binaryWindow(itemCount: itemCount, target: target, progress: (p - 0.55) / 0.45)
            return "After range growth, binary search narrows bars \(window.low + 1)-\(window.high + 1)."
        case .selectionSort:
            return "Position \(current + 1) is being filled by scanning the remaining bars for the smallest value."
        case .insertionSort:
            return "Uses bar \(max(2, current + 1)) as the key and shifts larger previous bars right to insert it."
        case .mergeSort:
            let stages = max(1, Int(ceil(log2(Double(max(itemCount, 2))))))
            let stage = min(stages, max(0, Int(Double(stages) * p)))
            let blockSize = min(itemCount, max(2, 1 << stage))
            return "Merges sorted blocks of about \(blockSize) bars, doubling block size after each level."
        case .quickSort:
            let pivot = min(itemCount - 1, max(0, Int(Double(itemCount) * (0.18 + p * 0.64))))
            return "Chooses pivot bar \(pivot + 1), then partitions nearby bars into smaller-left and larger-right groups."
        case .heapSort:
            let sorted = Int(Double(itemCount) * p)
            return "Maintains the red heap, swaps the root out, and grows the sorted suffix to \(sorted) bars."
        case .shellSort:
            let gaps = [32, 16, 8, 4, 2, 1].filter { $0 < itemCount }
            let safeGaps = gaps.isEmpty ? [1] : gaps
            let gapIndex = min(safeGaps.count - 1, Int(Double(safeGaps.count) * p))
            return "Compares bars separated by gap \(safeGaps[gapIndex]), then shrinks the gap toward 1."
        case .bubbleSort:
            return "Compares adjacent bars around position \(current + 1) and pushes larger values toward the right."
        }
    }


}

private struct LegendItem: View {
    let symbol: String
    let color: Color
    let text: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: symbol)
                .foregroundStyle(color)
                .frame(width: 12, height: 12)
                .accessibilityHidden(true)
            Text(text)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

private struct AlgorithmVisualizer: View {
    @Environment(\.colorScheme) private var colorScheme
    let algorithm: RaceAlgorithm
    let bars: [Double]
    let progress: Double
    let isRacing: Bool

    var body: some View {
        GeometryReader { geo in
            let clampedProgress = min(max(progress, 0), 1)
            let sortedBars = bars.sorted()
            let engine = RaceVisualizationEngine(algorithm: algorithm, bars: bars, isRacing: isRacing)
            let spacing: CGFloat = 2
            let totalSpacing = spacing * CGFloat(max(bars.count - 1, 0))
            let barWidth = max(2, (geo.size.width - totalSpacing) / CGFloat(max(bars.count, 1)))
            let isSearch = algorithm.category == "Search methods"

            ZStack {
                AppPalette.visualizationCanvas(for: colorScheme)

                HStack(alignment: .bottom, spacing: spacing) {
                    ForEach(bars.indices, id: \.self) { index in
                        let heightValue = isSearch ? sortedBars[index] : engine.sortHeight(at: index, sortedBars: sortedBars, progress: clampedProgress)
                        let color = isSearch ? engine.searchColor(index: index, count: bars.count, progress: clampedProgress) : engine.sortColor(index: index, count: bars.count, progress: clampedProgress)

                        Rectangle()
                            .fill(color)
                            .frame(width: barWidth, height: max(6, geo.size.height * heightValue))
                            .animation(AppMotion.bars, value: clampedProgress)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 12)
                .padding(.bottom, 10)
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.secondary.opacity(0.18), lineWidth: 1)
            }
            .accessibilityHidden(true)
        }
        .frame(height: 156)
    }

}
