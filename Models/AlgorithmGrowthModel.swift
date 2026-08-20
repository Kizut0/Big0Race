import Foundation

/// Provides the theoretical calculations and teaching text used by the reveal screen.
enum AlgorithmGrowthModel {
    /// Formats the substituted Big-O estimate as a readable equation.
    static func formulaText(for algo: RaceAlgorithm, n: Int) -> String {
        let value = estimatedOperations(for: algo, n: n)
        switch algo {
        case .constantLookup:
            return "1 = \(format(value))"
        case .linearSearch:
            return "n = \(n) = \(format(value))"
        case .binarySearch, .exponentialSearch:
            return "log2(n + 1) = log2(\(n + 1)) = \(format(value))"
        case .jumpSearch:
            return "sqrt(n) = sqrt(\(n)) = \(format(value))"
        case .interpolationSearch:
            return "log2(log2(n + 2) + 1) = log2(log2(\(n + 2)) + 1) = \(format(value))"
        case .selectionSort, .insertionSort, .bubbleSort:
            return "n x n = \(n) x \(n) = \(format(value))"
        case .mergeSort, .quickSort, .heapSort, .shellSort:
            return "n x log2(n + 1) = \(n) x log2(\(n + 1)) = \(format(value))"
        }
    }

    /// Explains the structural reason behind an algorithm's growth category.
    static func theoryText(for algo: RaceAlgorithm) -> String {
        switch algo {
        case .constantLookup:
            return "Direct access does one indexed read. The input can grow, but the number of steps stays flat."
        case .linearSearch:
            return "Linear work means checking items one by one. If n doubles, the possible checks also double."
        case .binarySearch:
            return "Binary search halves the remaining range each step, so the step count grows by levels instead of by items."
        case .jumpSearch:
            return "Jump search skips ahead by block size, then scans inside one block. The best block size is about sqrt(n)."
        case .interpolationSearch:
            return "Interpolation search estimates the target position from the value, so evenly spaced data can shrink faster than binary search."
        case .exponentialSearch:
            return "Exponential search doubles its range until the target is covered, then uses binary search inside that range."
        case .selectionSort:
            return "Selection sort repeatedly scans the unsorted part to find the next smallest item, creating nested passes."
        case .insertionSort:
            return "Insertion sort places each item into the sorted prefix. In the average/worst case, many items shift for each insert."
        case .mergeSort:
            return "Merge sort splits into log2(n) levels, and each level processes all n items while merging."
        case .quickSort:
            return "Quick sort partitions around pivots. With balanced pivots, there are log2(n) partition levels touching n items each."
        case .heapSort:
            return "Heap sort builds a heap, then removes items one at a time. Each removal may move through log2(n) heap levels."
        case .shellSort:
            return "Shell sort uses shrinking gaps to reduce disorder before a final insertion-style pass, commonly shown near n log n here."
        case .bubbleSort:
            return "Bubble sort repeatedly compares neighboring pairs across the list, so the nested passes grow quadratically."
        }
    }

    /// Summarizes the theoretical estimate for the selected input size.
    static func calculationText(for algo: RaceAlgorithm, n: Int) -> String {
        let value = estimatedOperations(for: algo, n: n)
        switch algo {
        case .constantLookup:
            return "At n = \(n), the estimate is still 1 step because only one position is read."
        case .linearSearch:
            return "At n = \(n), the model uses \(n) possible checks."
        case .binarySearch, .exponentialSearch:
            return "At n = \(n), log2(\(n + 1)) is about \(format(value)) range-halving steps."
        case .jumpSearch:
            return "At n = \(n), sqrt(\(n)) is about \(format(value)) jumps/checks."
        case .interpolationSearch:
            return "At n = \(n), log2(log2(\(n + 2)) + 1) is about \(format(value)) estimated probes."
        case .selectionSort, .insertionSort, .bubbleSort:
            return "At n = \(n), \(n) x \(n) gives about \(format(value)) comparison-scale steps."
        case .mergeSort, .quickSort, .heapSort, .shellSort:
            return "At n = \(n), \(n) x log2(\(n + 1)) gives about \(format(value)) level-by-level steps."
        }
    }

    /// Builds the ordered teaching steps that connect Big-O theory to the measured run.
    static func calculationSteps(for algo: RaceAlgorithm, n: Int, measured: Int) -> [String] {
        let value = estimatedOperations(for: algo, n: n)
        switch algo {
        case .constantLookup:
            return [
                "Big-O shape: O(1), so the formula is a fixed 1 step.",
                "Substitute n = \(n): n is ignored because direct indexing jumps to one position.",
                "Estimate: 1 step.",
                "Measured in this race: \(measured) operation."
            ]
        case .linearSearch:
            return [
                "Big-O shape: O(n), so the estimate uses n possible checks.",
                "Substitute n = \(n): estimate = \(n) checks.",
                "A real run may stop early if the target is found before the last item.",
                "Measured in this race: \(measured) operations."
            ]
        case .binarySearch:
            let lowerPower = max(0, Int(floor(log2(Double(n + 1)))))
            let upperPower = Int(ceil(log2(Double(n + 1))))
            return [
                "Big-O shape: O(log n), because each comparison cuts the remaining range in half.",
                "Use base-2 log: log2(n + 1) = log2(\(n + 1)).",
                "Since 2^\(lowerPower) <= \(n + 1) <= 2^\(upperPower), the estimate is about \(format(value)) halving steps.",
                "Measured in this race: \(measured) operations, depending on where the target was found."
            ]
        case .jumpSearch:
            let blockSize = Int(Double(n).squareRoot().rounded())
            return [
                "Big-O shape: O(sqrt n), because it jumps by block size, then scans inside one block.",
                "Choose block size near sqrt(n): sqrt(\(n)) = \(format(value)).",
                "Rounded block size for intuition: about \(blockSize) items per jump/block.",
                "Measured in this race: \(measured) operations."
            ]
        case .interpolationSearch:
            let inner = log2(Double(n + 2))
            return [
                "Big-O shape shown here: O(log log n), when sorted values are evenly distributed.",
                "First calculate log2(n + 2): log2(\(n + 2)) = \(format(inner)).",
                "Then calculate log2(\(format(inner)) + 1) = \(format(value)) estimated probes.",
                "Measured in this race: \(measured) operations; uneven random values can change the exact count."
            ]
        case .exponentialSearch:
            let upperPower = Int(ceil(log2(Double(n + 1))))
            return [
                "Big-O shape: O(log n), because the range grows by powers of two, then binary search halves it.",
                "Range growth looks like 1, 2, 4, 8 ... until it covers n.",
                "For n = \(n), about \(upperPower) doublings can cover the range, matching log2(\(n + 1)) = \(format(value)).",
                "Measured in this race: \(measured) operations, depending on where the target was."
            ]
        case .selectionSort:
            let exact = n * max(0, n - 1) / 2
            return [
                "Big-O shape: O(n^2), so the simple growth estimate is n x n.",
                "Substitute n = \(n): \(n) x \(n) = \(format(value)) estimated comparison-scale steps.",
                "The real selection sort scan shrinks each pass: \(n - 1) + \(n - 2) + ... + 1.",
                "Exact comparison count for this implementation: \(n) x \(n - 1) / 2 = \(exact).",
                "Measured in this race: \(measured) operations."
            ]
        case .insertionSort:
            return [
                "Big-O shape: O(n^2), because each item may shift through many earlier items.",
                "Simple growth estimate: n x n = \(n) x \(n) = \(format(value)).",
                "The exact count depends on how scrambled the random input was.",
                "Measured in this race: \(measured) operations."
            ]
        case .mergeSort:
            let levels = log2(Double(n + 1))
            return [
                "Big-O shape: O(n log n), because merge sort has halving levels and each level processes the list.",
                "Levels estimate: log2(n + 1) = log2(\(n + 1)) = \(format(levels)).",
                "Work per level: about n = \(n) items.",
                "Total estimate: \(n) x \(format(levels)) = \(format(value)) operations.",
                "Measured in this race: \(measured) operations."
            ]
        case .quickSort:
            let levels = log2(Double(n + 1))
            return [
                "Big-O shape: O(n log n) on average, when pivots split the data reasonably evenly.",
                "Estimated partition levels: log2(\(n + 1)) = \(format(levels)).",
                "Each level touches about \(n) items.",
                "Total estimate: \(n) x \(format(levels)) = \(format(value)) operations.",
                "Measured in this race: \(measured) operations; pivot balance changes the exact count."
            ]
        case .heapSort:
            let levels = log2(Double(n + 1))
            return [
                "Big-O shape: O(n log n), because each removal can move through heap levels.",
                "Heap height estimate: log2(\(n + 1)) = \(format(levels)).",
                "There are about \(n) removals/fixes.",
                "Total estimate: \(n) x \(format(levels)) = \(format(value)) operations.",
                "Measured in this race: \(measured) operations."
            ]
        case .shellSort:
            let levels = log2(Double(n + 1))
            return [
                "This app shows Shell sort near O(n log n) for comparison, though exact Shell sort complexity depends on gap choices.",
                "Gap-level estimate: log2(\(n + 1)) = \(format(levels)).",
                "Work per level: about \(n) items.",
                "Total estimate: \(n) x \(format(levels)) = \(format(value)) operations.",
                "Measured in this race: \(measured) operations."
            ]
        case .bubbleSort:
            let exact = n * max(0, n - 1) / 2
            return [
                "Big-O shape: O(n^2), so the simple growth estimate is n x n.",
                "Substitute n = \(n): \(n) x \(n) = \(format(value)) estimated comparison-scale steps.",
                "This implementation uses shrinking passes: \(n - 1) + \(n - 2) + ... + 1.",
                "Exact comparison count: \(n) x \(n - 1) / 2 = \(exact).",
                "Measured in this race: \(measured) operations."
            ]
        }
    }

    /// Evaluates the simplified Big-O growth function used by the graph and cards.
    static func estimatedOperations(for algo: RaceAlgorithm, n: Int) -> Double {
        let value = Double(n)
        switch algo {
        case .constantLookup:
            return 1
        case .linearSearch:
            return value
        case .binarySearch, .exponentialSearch:
            return log2(value + 1)
        case .jumpSearch:
            return value.squareRoot()
        case .interpolationSearch:
            return log2(log2(value + 2) + 1)
        case .selectionSort, .insertionSort, .bubbleSort:
            return value * value
        case .mergeSort, .quickSort, .heapSort, .shellSort:
            return value * log2(value + 1)
        }
    }

    /// Formats estimates with precision appropriate to their magnitude.
    private static func format(_ value: Double) -> String {
        if value >= 100 {
            return String(format: "%.0f", value)
        }
        if value >= 10 {
            return String(format: "%.1f", value)
        }
        return String(format: "%.2f", value)
    }
}
