extension RaceAlgorithm {
    /// Breaks the execution strategy into beginner-friendly steps.
    var logicSteps: [String] {
        switch self {
        case .constantLookup:
            return [
                "The algorithm already knows the exact index it wants.",
                "It calculates the memory position for that index.",
                "It reads that one position directly.",
                "It does not inspect the items before or after it."
            ]
        case .linearSearch:
            return [
                "Start at the first item.",
                "Compare the current item with the target.",
                "If it matches, stop.",
                "If it does not match, move one step right and repeat."
            ]
        case .binarySearch:
            return [
                "The list must be sorted first.",
                "Look at the middle item.",
                "If the target is smaller, ignore the right half.",
                "If the target is larger, ignore the left half.",
                "Repeat on the half that remains."
            ]
        case .jumpSearch:
            return [
                "The list must be sorted first.",
                "Jump forward by block-sized steps instead of checking every item.",
                "When the jump passes the target area, stop jumping.",
                "Search one item at a time inside that final block."
            ]
        case .interpolationSearch:
            return [
                "The list must be sorted first.",
                "Use the target value to guess where it should be.",
                "Check that guessed position.",
                "Shrink the search area based on whether the guess was too low or too high."
            ]
        case .exponentialSearch:
            return [
                "The list must be sorted first.",
                "Check a tiny range first.",
                "Double the range again and again: 1, 2, 4, 8, 16.",
                "Once the target is inside the range, use binary search there."
            ]
        case .selectionSort:
            return [
                "Find the smallest item in the unsorted part.",
                "Move it into the next sorted position.",
                "Now the sorted part is one item bigger.",
                "Scan the remaining unsorted part again.",
                "Repeat until every position is filled."
            ]
        case .insertionSort:
            return [
                "Treat the left side as already sorted.",
                "Take the next unsorted item.",
                "Move left through the sorted part until the correct position is found.",
                "Shift bigger items right to make space.",
                "Insert the item and repeat."
            ]
        case .mergeSort:
            return [
                "Split the list into two halves.",
                "Keep splitting each half until the pieces are tiny.",
                "Merge small sorted pieces back together.",
                "Each merge touches the items in those pieces.",
                "Continue merging until one sorted list remains."
            ]
        case .quickSort:
            return [
                "Choose a pivot item.",
                "Move smaller values to one side and larger values to the other.",
                "The pivot is now in a useful position.",
                "Repeat the same idea on the left and right parts."
            ]
        case .heapSort:
            return [
                "Turn the list into a heap, where the largest item is easy to remove.",
                "Remove the largest item and place it at the end.",
                "Fix the heap after the removal.",
                "Repeat until all items are placed in sorted order."
            ]
        case .shellSort:
            return [
                "Compare and move items that are far apart first.",
                "Shrink the gap between compared items.",
                "Each pass makes the list less messy.",
                "Finish with a small-gap insertion-sort style pass."
            ]
        case .bubbleSort:
            return [
                "Compare two neighboring items.",
                "Swap them if they are in the wrong order.",
                "Move one step right and compare the next pair.",
                "After one pass, one large value has moved toward the end.",
                "Repeat many passes until the list is sorted."
            ]
        }
    }

    /// Explains how repeated work produces the algorithm's Big-O growth pattern.
    var growthSteps: [String] {
        switch self {
        case .constantLookup:
            return [
                "The algorithm reads one chosen position.",
                "Adding more items does not add more positions to check.",
                "That is why the growth is constant: O(1)."
            ]
        case .linearSearch:
            return [
                "In the worst case, the target could be near the end.",
                "More items means more possible checks.",
                "Double n, and the possible checks roughly double.",
                "That is linear growth: O(n)."
            ]
        case .binarySearch:
            return [
                "Each step removes half of the remaining items.",
                "A list of 100 becomes about 50, then 25, then 12.",
                "Doubling the list usually adds only one extra halving step.",
                "That is logarithmic growth: O(log n)."
            ]
        case .jumpSearch:
            return [
                "The algorithm avoids checking every item by jumping over blocks.",
                "Then it only scans inside one block.",
                "A good block size is about sqrt(n).",
                "That gives square-root growth: O(sqrt n)."
            ]
        case .interpolationSearch:
            return [
                "Good guesses can shrink the search area very quickly.",
                "On evenly spaced data, each guess can get close to the target.",
                "That can be faster than binary search.",
                "This app labels that good-data pattern as O(log log n)."
            ]
        case .exponentialSearch:
            return [
                "The first part doubles the range, so the covered area grows very fast.",
                "The second part uses binary search, which halves the range.",
                "Both parts grow by powers of two.",
                "That keeps the shape logarithmic: O(log n)."
            ]
        case .selectionSort:
            return [
                "There is an outer process: fill one sorted position.",
                "Inside each position, there is a scan through many remaining items.",
                "A repeated scan inside a repeated process creates nested work.",
                "Nested work grows quadratically: O(n^2)."
            ]
        case .insertionSort:
            return [
                "There is an outer process: insert each item.",
                "Inside each insert, the item may move past many earlier items.",
                "Many inserts times many shifts creates nested work.",
                "That gives O(n^2) in average or worst cases."
            ]
        case .mergeSort:
            return [
                "Splitting in half creates about log n levels.",
                "At each level, merging touches all n items total.",
                "n work per level times log n levels gives n log n.",
                "That is why merge sort is O(n log n)."
            ]
        case .quickSort:
            return [
                "A good pivot splits the list into smaller parts.",
                "Balanced splits create about log n levels.",
                "Each level partitions about n items total.",
                "n work per level times log n levels gives O(n log n) on average."
            ]
        case .heapSort:
            return [
                "The heap has about log n levels.",
                "Each removal may move down through those levels.",
                "There are n removals.",
                "n removals times log n levels gives O(n log n)."
            ]
        case .shellSort:
            return [
                "Large gaps reduce disorder early.",
                "Smaller gaps clean up local disorder later.",
                "Its exact growth depends on the chosen gaps.",
                "This app shows the common comparison shape near O(n log n)."
            ]
        case .bubbleSort:
            return [
                "One pass compares many neighboring pairs.",
                "One pass is not enough, so it repeats many passes.",
                "Many comparisons repeated many times creates nested work.",
                "Nested work grows quadratically: O(n^2)."
            ]
        }
    }
}

