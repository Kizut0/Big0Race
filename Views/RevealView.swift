import SwiftUI
import Charts

/// Compares measured operation points with theoretical Big-O growth curves.
struct RevealView: View {
    let vm: RaceViewModel

    private var maxN: Int { max(Int(vm.n), 50) }
    private var inputN: Int { Int(vm.n) }

    private var takeawayText: String? {
        guard
            let fastest = vm.sortedResults.first,
            let slowest = vm.sortedResults.last,
            fastest.id != slowest.id,
            slowest.operationCount > 0
        else { return nil }

        let reduction = 1 - Double(fastest.operationCount) / Double(slowest.operationCount)
        let percentage = max(0, Int((reduction * 100).rounded()))
        return "\(fastest.algorithm.displayName) won with \(fastest.operationCount.formatted()) operations—\(percentage)% fewer than \(slowest.algorithm.displayName)."
    }

    /// Assigns a stable graph color based on the algorithm's case order.
    private func color(for algorithm: RaceAlgorithm) -> Color {
        let colors: [Color] = [
            .blue, .green, .orange, .purple, .pink, .teal, .cyan,
            .indigo, .mint, .red, .brown, .yellow, .gray
        ]
        let index = RaceAlgorithm.allCases.firstIndex(of: algorithm) ?? 0
        return colors[index % colors.count]
    }

    /// Assigns a stable line pattern so graph series are not distinguished by color alone.
    private func stroke(for algorithm: RaceAlgorithm) -> StrokeStyle {
        let patterns: [[CGFloat]] = [
            [], [10, 4], [3, 3], [12, 3, 3, 3], [7, 3, 2, 3],
            [2, 2], [14, 4], [8, 2, 2, 2], [5, 5], [1, 3],
            [10, 2, 2, 2, 2, 2], [6, 2], [4, 2, 1, 2]
        ]
        let index = RaceAlgorithm.allCases.firstIndex(of: algorithm) ?? 0
        return StrokeStyle(lineWidth: 2.5, dash: patterns[index % patterns.count])
    }

    /// Scales the algorithm's Big-O shape to the measured result, so the line
    /// passes through the real operation count at the race's input size.
    private func curvePoints(for result: RaceResult) -> [(x: Int, y: Double)] {
        let step = max(1, maxN / 60)
        var sampledInputs = Set(stride(from: 1, through: maxN, by: step))
        sampledInputs.insert(inputN)
        sampledInputs.insert(maxN)

        let measuredScale = Double(result.operationCount) / AlgorithmGrowthModel.estimatedOperations(
            for: result.algorithm,
            n: inputN
        )

        return sampledInputs.sorted().map { x in
            (
                x: x,
                y: AlgorithmGrowthModel.estimatedOperations(for: result.algorithm, n: x) * measuredScale
            )
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Button {
                    vm.goBack()
                } label: {
                    Label("Back", systemImage: "chevron.left")
                }
                .buttonStyle(.borderless)
                .accessibilityHint("Returns to the animated race")

                Spacer()
            }

            Text("What the results show")
                .font(AppType.screenTitle)
            Text("Operations needed as n grows")
                .foregroundStyle(.secondary)

            if let takeawayText {
                Label {
                    Text(takeawayText)
                        .font(.subheadline.weight(.semibold))
                        .fixedSize(horizontal: false, vertical: true)
                } icon: {
                    Image(systemName: "trophy.fill")
                        .foregroundStyle(AppPalette.accent)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppPalette.accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
                .accessibilityLabel("Race takeaway. \(takeawayText)")
            }

            Chart {
                ForEach(vm.results) { result in
                    ForEach(curvePoints(for: result), id: \.x) { point in
                        LineMark(
                            x: .value("n", point.x),
                            y: .value("operations", point.y)
                        )
                        .foregroundStyle(color(for: result.algorithm))
                        .lineStyle(stroke(for: result.algorithm))
                    }

                    PointMark(
                        x: .value("n", inputN),
                        y: .value("measured operations", result.operationCount)
                    )
                    .foregroundStyle(color(for: result.algorithm))
                    .symbolSize(110)
                }
            }
            .frame(minHeight: 260, idealHeight: 340, maxHeight: 380)
            .chartYScale(type: .log)
            .chartYAxisLabel("Operations (log scale)")
            .chartXAxisLabel("Input size (n)")
            .chartLegend(.hidden)
            .accessibilityLabel("Theoretical growth and measured operation chart")
            .accessibilityValue(vm.results.map { "\($0.algorithm.displayName), \($0.operationCount) operations" }.joined(separator: "; "))

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 190), alignment: .leading)], spacing: 8) {
                ForEach(vm.results) { result in
                    HStack(spacing: 7) {
                        Circle()
                            .fill(color(for: result.algorithm))
                            .frame(width: 9, height: 9)
                        Text(result.algorithm.displayName)
                            .font(.caption.weight(.semibold))
                        Spacer(minLength: 4)
                        Text("\(result.operationCount.formatted()) ops")
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(result.algorithm.displayName)
                    .accessibilityValue("\(result.operationCount) measured operations, \(result.algorithm.bigOLabel)")
                }
            }

            Text("Dots are measured results. Each patterned line uses that result as its anchor and shows the algorithm's Big-O growth as n changes. The log scale keeps fast and slow algorithms visible.")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("How the calculation works at n = \(inputN)")
                .font(.headline)

            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(vm.results) { result in
                        CalculationRow(
                            name: result.algorithm.displayName,
                            bigO: result.algorithm.bigOLabel,
                            formula: AlgorithmGrowthModel.formulaText(for: result.algorithm, n: inputN),
                            theory: AlgorithmGrowthModel.theoryText(for: result.algorithm),
                            calculation: AlgorithmGrowthModel.calculationText(for: result.algorithm, n: inputN),
                            steps: AlgorithmGrowthModel.calculationSteps(for: result.algorithm, n: inputN, measured: result.operationCount),
                            value: AlgorithmGrowthModel.estimatedOperations(for: result.algorithm, n: inputN),
                            measured: result.operationCount
                        )
                    }
                }
                .padding(.vertical, 2)
            }
            .frame(maxHeight: .infinity)

            Button {
                vm.goToReflect()
            } label: {
                Text("Why though?")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .accessibilityHint("Opens the ranked plain-language explanation")
        }
        .padding()
        .frame(maxWidth: 1200)
        .frame(maxWidth: .infinity)
    }
}
