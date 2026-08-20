extension RaceAlgorithm {
    /// Returns the longer beginner-friendly explanation shown after the race.
    var studentExplanation: String {
        switch self {
        case .constantLookup:
            return "An array index is like a seat number. If you ask for position 50, the computer calculates that address directly instead of checking positions 0 through 49 first. That is why the work stays at about one access whether the array has 10 items or 500 items. In the race, this usually finishes first because n does not add more steps."
        case .linearSearch:
            return "Linear search has no shortcut. It starts at the beginning and asks, 'Is this the target?' for each item until it finds the answer. If the list gets twice as long, there can be about twice as many checks. That direct relationship is why it is O(n). In the race, it falls behind constant lookup because more input means more possible work."
        case .binarySearch:
            return "Binary search only works on sorted data. It checks the middle item, then throws away the half that cannot contain the target. One check turns 100 items into 50, then 25, then 12, and so on. Because each step removes half the remaining problem, doubling n adds only one extra middle check. That repeated halving is the logic behind O(log n)."
        case .jumpSearch:
            return "Jump search uses sorted data and moves in blocks instead of checking every item. It jumps ahead by about sqrt(n) positions until it passes the target, then scans inside just that block. The jump phase and the short scan phase balance each other, so the work grows around sqrt(n), which is slower than log n but faster than checking every item."
        case .interpolationSearch:
            return "Interpolation search guesses where the target should be by using the values in the sorted array, like estimating a page number in a dictionary. If the data is evenly spread out, the guess lands very close and the search space shrinks extremely fast. That is why it can be shown as O(log log n) for good data, although uneven data can make it worse."
        case .exponentialSearch:
            return "Exponential search first grows a search window very quickly: 1, 2, 4, 8, 16, and so on. Once the target must be inside that window, it switches to binary search. The first phase finds the right range in logarithmic steps, and the second phase halves that range, so the total shape is still O(log n)."
        case .selectionSort:
            return "Selection sort builds the sorted list one position at a time. For each position, it scans the remaining unsorted items to find the smallest value. That means a scan inside another repeated pass: many comparisons for the first item, almost as many for the next, and so on. This nested work is why the race grows like O(n^2)."
        case .insertionSort:
            return "Insertion sort keeps a sorted section at the front. Each new item is inserted into that section, and larger items may need to shift right to make room. If many items are out of order, each insert can move through a large part of the sorted section. Repeating that for many items creates O(n^2) work in the average or worst case."
        case .mergeSort:
            return "Merge sort splits the list in half until the pieces are tiny, then merges those pieces back together in sorted order. Splitting in half creates about log n levels. At each level, all n items are touched during merging. n items per level times log n levels gives O(n log n)."
        case .quickSort:
            return "Quick sort picks a pivot, partitions smaller values to one side and larger values to the other, then repeats on the smaller parts. With balanced pivots, there are about log n partition levels, and each level touches about n items. That gives O(n log n) on average. Bad pivots can make it slower, but the race models the usual balanced shape."
        case .heapSort:
            return "Heap sort first arranges the data into a heap, where the largest item can be removed efficiently. Each removal places one item into its final sorted position, then fixes the heap by moving through its levels. A heap has about log n levels, and doing that for n removals gives O(n log n)."
        case .shellSort:
            return "Shell sort improves insertion sort by comparing items that are far apart first, then gradually shrinking the gap. Early passes move items closer to their final area, so the final local insertion pass has less disorder to fix. Its exact Big-O depends on the gap pattern; this app shows it near n log n to compare its improved growth shape."
        case .bubbleSort:
            return "Bubble sort repeatedly walks through the list comparing neighbors and swapping them if they are out of order. One pass is not enough; it must make many passes because each pass only moves values gradually. A repeated pass over many items creates nested work, so the number of comparisons grows like n x n, or O(n^2)."
        }
    }
}

