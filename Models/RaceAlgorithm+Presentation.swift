extension RaceAlgorithm {
    /// Groups the algorithm under the search or sorting section in setup.
    var category: String {
        switch self {
        case .constantLookup, .linearSearch, .binarySearch, .jumpSearch, .interpolationSearch, .exponentialSearch:
            return "Search methods"
        case .selectionSort, .insertionSort, .mergeSort, .quickSort, .heapSort, .shellSort, .bubbleSort:
            return "Sort methods"
        }
    }

    /// Provides the learner-facing name used throughout the interface.
    var displayName: String {
        switch self {
        case .constantLookup: return "Array lookup"
        case .linearSearch:   return "Linear search"
        case .binarySearch:   return "Binary search"
        case .jumpSearch: return "Jump search"
        case .interpolationSearch: return "Interpolation search"
        case .exponentialSearch: return "Exponential search"
        case .selectionSort: return "Selection sort"
        case .insertionSort: return "Insertion sort"
        case .mergeSort:      return "Merge sort"
        case .quickSort: return "Quick sort"
        case .heapSort: return "Heap sort"
        case .shellSort: return "Shell sort"
        case .bubbleSort:     return "Bubble sort"
        }
    }

    /// Provides the simplified Big-O label displayed beside the algorithm.
    var bigOLabel: String {
        switch self {
        case .constantLookup: return "O(1)"
        case .linearSearch:   return "O(n)"
        case .binarySearch:   return "O(log n)"
        case .jumpSearch: return "O(sqrt n)"
        case .interpolationSearch: return "O(log log n)"
        case .exponentialSearch: return "O(log n)"
        case .selectionSort: return "O(n\u{00B2})"
        case .insertionSort: return "O(n\u{00B2})"
        case .mergeSort:      return "O(n log n)"
        case .quickSort: return "O(n log n)"
        case .heapSort: return "O(n log n)"
        case .shellSort: return "O(n log n)"
        case .bubbleSort:     return "O(n\u{00B2})"
        }
    }

    /// Returns a short summary suitable for the ranked result list.
    var explanation: String {
        switch self {
        case .constantLookup:
            return "Jumps straight to the memory address. The array's size never enters the calculation."
        case .linearSearch:
            return "Checks each element in order until it finds a match, so work grows in direct proportion to n."
        case .binarySearch:
            return "Cuts the remaining search space in half on every comparison, so doubling n only adds one more step."
        case .jumpSearch:
            return "Skips forward by block-sized jumps, then scans inside the block where the target should be."
        case .interpolationSearch:
            return "Estimates where the target should be based on its value, which is very fast on evenly distributed sorted data."
        case .exponentialSearch:
            return "Doubles the search range until the target is inside it, then finishes with binary search."
        case .selectionSort:
            return "Repeatedly finds the next smallest item and places it at the front, scanning the remaining list each time."
        case .insertionSort:
            return "Builds a sorted prefix one item at a time, shifting larger items to make room."
        case .mergeSort:
            return "Splits the array in half repeatedly (log n levels), then merges linearly at each level."
        case .quickSort:
            return "Partitions items around a pivot, then recursively sorts the smaller partitions."
        case .heapSort:
            return "Builds a heap, then repeatedly removes the largest item into its final position."
        case .shellSort:
            return "Starts by insertion-sorting far-apart items, then reduces the gap until the final pass is local."
        case .bubbleSort:
            return "Compares nearly every pair of elements against every other, so work grows with n multiplied by itself."
        }
    }

}

