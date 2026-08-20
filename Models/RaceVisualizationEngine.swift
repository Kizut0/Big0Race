import SwiftUI

/// Converts normalized race progress into the semantic heights and colors used by the fixed-size teaching visualization. This engine is presentation logic: it never performs or measures an algorithm, and it is independent of View state.
struct RaceVisualizationEngine {
    let algorithm: RaceAlgorithm
    let bars: [Double]
    let isRacing: Bool

    /// Returns the illustrative bar height for one sorting-algorithm frame.
    func sortHeight(at index: Int, sortedBars: [Double], progress: Double) -> Double {
        let count = bars.count
        let current = min(count - 1, Int(Double(max(count - 1, 1)) * progress))

        switch algorithm {
        case .selectionSort, .insertionSort:
            return index <= current ? sortedBars[index] : bars[index]

        case .mergeSort:
            let stages = max(1, Int(ceil(log2(Double(max(count, 2))))))
            let stage = min(stages, max(0, Int(Double(stages) * progress)))
            let blockSize = min(count, max(1, 1 << stage))
            return blockSortedHeight(index: index, blockSize: blockSize)

        case .quickSort:
            // Sweep the illustrative pivot through the central 64% so both partitions remain visible instead of collapsing at an edge.
            let pivot = min(count - 1, max(0, Int(Double(count) * (0.18 + progress * 0.64))))
            if index < pivot {
                return sortedBars[index]
            }
            if index == pivot {
                return sortedBars[min(pivot, sortedBars.count - 1)]
            }
            return bars[index]

        case .heapSort:
            let sortedSuffixStart = max(0, count - Int(Double(count) * progress))
            return index >= sortedSuffixStart ? sortedBars[index] : bars[index]

        case .shellSort:
            // Reserve the final 28% for a visible gap-1 insertion pass.
            if progress > 0.72 {
                let sortedCount = Int(Double(count) * ((progress - 0.72) / 0.28))
                return index < sortedCount ? sortedBars[index] : bars[index]
            }
            return bars[index]

        case .bubbleSort:
            let sortedSuffixStart = max(0, count - Int(Double(count) * progress))
            return index >= sortedSuffixStart ? sortedBars[index] : bars[index]

        default:
            let sortedCount = Int(Double(count) * progress)
            return index < sortedCount ? sortedBars[index] : bars[index]
        }
    }

    /// Chooses a semantic color for one bar in a sorting visualization.
    func sortColor(index: Int, count: Int, progress: Double) -> Color {
        guard count > 0 else { return .white }

        switch algorithm {
        case .selectionSort:
            let sortedEnd = min(count - 1, Int(Double(count - 1) * progress))
            let scan = min(count - 1, sortedEnd + 1 + Int(Double(max(count - sortedEnd - 1, 1)) * phase(progress, cycles: count)))
            let minIndex = min(count - 1, sortedEnd + max(1, (scan - sortedEnd) / 2))
            if index == minIndex && isRacing { return .green }
            if index >= sortedEnd && index <= scan && isRacing { return .red }
            return .white

        case .insertionSort:
            let key = min(count - 1, max(1, Int(Double(count - 1) * progress)))
            let shiftWidth = max(2, min(key, count / 7))
            if index == key && isRacing { return .green }
            if index >= max(0, key - shiftWidth) && index < key && isRacing { return .red }
            return .white

        case .mergeSort:
            let stages = max(1, Int(ceil(log2(Double(max(count, 2))))))
            let stage = min(stages, max(0, Int(Double(stages) * progress)))
            let blockSize = min(count, max(2, 1 << stage))
            let activeBlock = min(count - 1, Int(Double(count) * phase(progress, cycles: stages + 1))) / blockSize
            let start = activeBlock * blockSize
            let mid = min(count, start + blockSize / 2)
            let end = min(count, start + blockSize)
            if index == mid && isRacing { return .green }
            if index >= start && index < end && isRacing { return .red }
            return .white

        case .quickSort:
            let pivot = min(count - 1, max(0, Int(Double(count) * (0.18 + progress * 0.64))))
            let low = max(0, pivot - count / 5)
            let high = min(count - 1, pivot + count / 5)
            if index == pivot && isRacing { return .green }
            if index >= low && index <= high && isRacing { return .red }
            return .white

        case .heapSort:
            let sortedSuffixStart = max(0, count - Int(Double(count) * progress))
            let heapSize = max(1, sortedSuffixStart)
            if index == 0 && isRacing { return .green }
            if index < heapSize && isRacing { return .red }
            return .white

        case .shellSort:
            let gaps = [32, 16, 8, 4, 2, 1].filter { $0 < count }
            let safeGaps = gaps.isEmpty ? [1] : gaps
            let gapIndex = min(safeGaps.count - 1, Int(Double(safeGaps.count) * progress))
            let gap = safeGaps[gapIndex]
            let current = min(count - 1, Int(Double(count - 1) * phase(progress, cycles: safeGaps.count + 1)))
            if index == current && isRacing { return .green }
            if isRacing && abs(index - current).isMultiple(of: gap) {
                return .red
            }
            return .white

        case .bubbleSort:
            let sortedSuffixStart = max(0, count - Int(Double(count) * progress))
            let compareLimit = max(1, sortedSuffixStart)
            let left = min(compareLimit - 1, Int(Double(compareLimit - 1) * phase(progress, cycles: count)))
            if index == left + 1 && isRacing { return .green }
            if (index == left || index == left + 1) && isRacing { return .red }
            return .white

        default:
            let sortedCount = Int(Double(count) * progress)
            let activeWidth = max(6, count / 5)
            let activeStart = min(sortedCount + 1, max(0, count - activeWidth))
            let activeEnd = min(count, activeStart + activeWidth)

            if index == sortedCount && isRacing {
                return .green
            }
            if index >= activeStart && index < activeEnd && isRacing {
                return .red
            }
            return .white
        }
    }

    /// Chooses a semantic color for checked, active, and possible search positions.
    func searchColor(index: Int, count: Int, progress: Double) -> Color {
        let target = max(0, min(count - 1, Int(Double(count) * 0.62)))

        switch algorithm {
        case .constantLookup:
            return index == count / 2 ? .green : .white

        case .linearSearch:
            let current = min(target, Int(Double(target) * progress))
            if index == current { return .green }
            if index < current { return .red }
            return .white

        case .binarySearch:
            let window = binaryWindow(count: count, target: target, progress: progress)
            if index == window.mid { return .green }
            if index < window.low || index > window.high { return .red.opacity(0.7) }
            return .white

        case .jumpSearch:
            let step = max(1, Int(Double(count).squareRoot()))
            let block = min(target / step, Int((Double(target / step) + 1) * progress))
            let start = block * step
            let end = min(count, start + step)
            if index == min(target, end - 1) && progress > 0.8 { return .green }
            if index >= start && index < end { return .red }
            if index < start { return .red.opacity(0.55) }
            return .white

        case .interpolationSearch:
            let probe = min(target, max(0, Int(Double(target) * min(1, progress * 1.18))))
            let band = max(2, count / 18)
            if index == probe { return .green }
            if abs(index - probe) <= band { return .red }
            return .white

        case .exponentialSearch:
            if progress < 0.55 {
                let step = min(max(0, Int(progress / 0.55 * 7)), 7)
                let bound = min(count - 1, 1 << step)
                if index == bound { return .green }
                if index <= bound { return .red }
                return .white
            }

            let window = binaryWindow(count: count, target: target, progress: (progress - 0.55) / 0.45)
            if index == window.mid { return .green }
            if index < window.low || index > window.high { return .red.opacity(0.7) }
            return .white

        default:
            return sortColor(index: index, count: count, progress: progress)
        }
    }

    /// Delegates to the shared binary-search window simulation for this frame.
    func binaryWindow(count: Int, target: Int, progress: Double) -> (low: Int, high: Int, mid: Int) {
        let maxSteps = max(1, Int(ceil(log2(Double(count)))))
        let currentStep = min(maxSteps, Int(Double(maxSteps) * progress))
        var low = 0
        var high = count - 1

        for _ in 0..<currentStep {
            let mid = (low + high) / 2
            if mid == target {
                low = mid
                high = mid
                break
            } else if mid < target {
                low = mid + 1
            } else {
                high = mid - 1
            }
        }

        return (low, high, (low + high) / 2)
    }

    /// Sorts only the illustrative block containing `index` for staged animations.
    func blockSortedHeight(index: Int, blockSize: Int) -> Double {
        let start = (index / blockSize) * blockSize
        let end = min(bars.count, start + blockSize)
        let sortedBlock = bars[start..<end].sorted()
        return sortedBlock[index - start]
    }

    /// Converts overall progress into a repeating zero-to-one phase.
    func phase(_ progress: Double, cycles: Int) -> Double {
        let scaled = progress * Double(max(cycles, 1))
        return scaled - floor(scaled)
    }

    /// Shared binary-window model used by both visual state and spoken detail.
    static func binaryWindow(itemCount: Int, target: Int, progress: Double) -> (low: Int, high: Int, mid: Int) {
        let maxSteps = max(1, Int(ceil(log2(Double(itemCount)))))
        let currentStep = min(maxSteps, Int(Double(maxSteps) * min(max(progress, 0), 1)))
        var low = 0
        var high = itemCount - 1
        for _ in 0..<currentStep {
            let mid = (low + high) / 2
            if mid == target { low = mid; high = mid; break }
            if mid < target { low = mid + 1 } else { high = mid - 1 }
        }
        return (low, high, (low + high) / 2)
    }
}
