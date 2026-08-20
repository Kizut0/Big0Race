/// Each case is a real algorithm. `run(input:)` actually executes it on a shared race input and returns the true number of elementary operations (comparisons / array accesses) it performed.
enum RaceAlgorithm: String, CaseIterable, Identifiable, Sendable {
    case constantLookup
    case linearSearch
    case binarySearch
    case jumpSearch
    case interpolationSearch
    case exponentialSearch
    case selectionSort
    case insertionSort
    case mergeSort
    case quickSort
    case heapSort
    case shellSort
    case bubbleSort

    var id: String { rawValue }
}

