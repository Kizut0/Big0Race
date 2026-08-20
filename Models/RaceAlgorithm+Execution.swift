extension RaceAlgorithm {
    /// Runs the real algorithm on the race's shared data and returns the exact number of elementary operations it performed.
    func run(input: RaceInput) -> Int {
        let unsortedData = input.unsortedData
        let sortedData = input.sortedData
        let target = input.searchTarget
        let n = unsortedData.count
        guard n > 0 else { return 0 }
        var operations = 0

        switch self {
        case .constantLookup:
            _ = sortedData[n / 2]
            operations = 1

        case .linearSearch:
            for value in sortedData {
                operations += 1
                if value == target { break }
            }

        case .binarySearch:
            var low = 0, high = n - 1
            while low <= high {
                operations += 1
                let mid = (low + high) / 2
                if sortedData[mid] == target { break }
                else if sortedData[mid] < target { low = mid + 1 }
                else { high = mid - 1 }
            }

        case .jumpSearch:
            let step = max(1, Int(Double(n).squareRoot()))
            var previous = 0
            var current = step
            while previous < n && sortedData[min(current, n) - 1] < target {
                operations += 1
                previous = current
                current += step
            }
            while previous < min(current, n) {
                operations += 1
                if sortedData[previous] == target { break }
                previous += 1
            }

        case .interpolationSearch:
            var low = 0
            var high = n - 1
            while low <= high && target >= sortedData[low] && target <= sortedData[high] {
                operations += 1
                if sortedData[high] == sortedData[low] {
                    break
                }
                let position = low + ((target - sortedData[low]) * (high - low)) / (sortedData[high] - sortedData[low])
                let clampedPosition = min(max(position, low), high)
                if sortedData[clampedPosition] == target { break }
                if sortedData[clampedPosition] < target {
                    low = clampedPosition + 1
                } else {
                    high = clampedPosition - 1
                }
            }

        case .exponentialSearch:
            if sortedData[0] == target {
                operations = 1
                break
            }
            var bound = 1
            while bound < n && sortedData[bound] < target {
                operations += 1
                bound *= 2
            }
            var low = bound / 2
            var high = min(bound, n - 1)
            while low <= high {
                operations += 1
                let mid = (low + high) / 2
                if sortedData[mid] == target { break }
                else if sortedData[mid] < target { low = mid + 1 }
                else { high = mid - 1 }
            }

        case .selectionSort:
            var array = unsortedData
            for i in 0..<array.count {
                var minIndex = i
                for j in (i + 1)..<array.count {
                    operations += 1
                    if array[j] < array[minIndex] {
                        minIndex = j
                    }
                }
                if minIndex != i {
                    array.swapAt(i, minIndex)
                }
            }

        case .insertionSort:
            var array = unsortedData
            for i in 1..<array.count {
                let key = array[i]
                var j = i - 1
                while j >= 0 {
                    operations += 1
                    if array[j] <= key { break }
                    array[j + 1] = array[j]
                    if j == 0 {
                        j = -1
                        break
                    }
                    j -= 1
                }
                array[j + 1] = key
            }

        case .mergeSort:
            var array = unsortedData
            operations = Self.mergeSortCount(&array, 0, array.count - 1)

        case .quickSort:
            var array = unsortedData
            operations = Self.quickSortCount(&array, 0, array.count - 1)

        case .heapSort:
            var array = unsortedData
            operations = Self.heapSortCount(&array)

        case .shellSort:
            var array = unsortedData
            var gap = array.count / 2
            while gap > 0 {
                for i in gap..<array.count {
                    let temp = array[i]
                    var j = i
                    while j >= gap {
                        operations += 1
                        if array[j - gap] <= temp { break }
                        array[j] = array[j - gap]
                        j -= gap
                    }
                    array[j] = temp
                }
                gap /= 2
            }

        case .bubbleSort:
            var array = unsortedData
            for i in 0..<array.count {
                for j in 0..<array.count - i - 1 {
                    operations += 1
                    if array[j] > array[j + 1] {
                        array.swapAt(j, j + 1)
                    }
                }
            }

        }
        return operations
    }

    /// Recursively merge-sorts the requested range and returns key comparisons.
    private static func mergeSortCount(_ array: inout [Int], _ lo: Int, _ hi: Int) -> Int {
        guard lo < hi else { return 0 }
        let mid = (lo + hi) / 2
        var count = mergeSortCount(&array, lo, mid)
        count += mergeSortCount(&array, mid + 1, hi)

        let left = Array(array[lo...mid])
        let right = Array(array[(mid + 1)...hi])
        var i = 0, j = 0, k = lo
        while i < left.count && j < right.count {
            count += 1
            if left[i] <= right[j] { array[k] = left[i]; i += 1 }
            else { array[k] = right[j]; j += 1 }
            k += 1
        }
        while i < left.count { array[k] = left[i]; i += 1; k += 1 }
        while j < right.count { array[k] = right[j]; j += 1; k += 1 }
        return count
    }

    /// Quick-sorts a range using its final element as the pivot and counts comparisons.
    private static func quickSortCount(_ array: inout [Int], _ low: Int, _ high: Int) -> Int {
        guard low < high else { return 0 }
        var count = 0
        let pivot = array[high]
        var i = low
        for j in low..<high {
            count += 1
            if array[j] <= pivot {
                array.swapAt(i, j)
                i += 1
            }
        }
        array.swapAt(i, high)
        count += quickSortCount(&array, low, i - 1)
        count += quickSortCount(&array, i + 1, high)
        return count
    }

    /// Heap-sorts the full array and returns the number of child comparisons.
    private static func heapSortCount(_ array: inout [Int]) -> Int {
        var count = 0

        /// Restores the max-heap property below `root` for the active heap size.
        func heapify(_ size: Int, _ root: Int) {
            var largest = root
            let left = 2 * root + 1
            let right = 2 * root + 2

            if left < size {
                count += 1
                if array[left] > array[largest] {
                    largest = left
                }
            }
            if right < size {
                count += 1
                if array[right] > array[largest] {
                    largest = right
                }
            }
            if largest != root {
                array.swapAt(root, largest)
                heapify(size, largest)
            }
        }

        for i in stride(from: array.count / 2 - 1, through: 0, by: -1) {
            heapify(array.count, i)
        }
        for i in stride(from: array.count - 1, through: 1, by: -1) {
            array.swapAt(0, i)
            heapify(i, 0)
        }

        return count
    }
}
