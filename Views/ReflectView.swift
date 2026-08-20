import SwiftUI

/// Ranked reflection screen with expandable, plain-language explanations.
struct ReflectView: View {
    let vm: RaceViewModel
    private var inputN: Int { Int(vm.n) }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Button {
                    vm.goBack()
                } label: {
                    Label("Back", systemImage: "chevron.left")
                }
                .buttonStyle(.borderless)
                .accessibilityHint("Returns to the growth chart")

                Spacer()
            }

            Text("Why it happened")
                .font(AppType.screenTitle)

            Text("The race uses the real operation count from each algorithm. Big-O explains the shape of that count as n grows.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ScrollView {
                VStack(spacing: 10) {
                    ForEach(Array(vm.sortedResults.enumerated()), id: \.element.id) { index, result in
                        DisclosureGroup {
                            VStack(alignment: .leading, spacing: 14) {
                                Text(result.algorithm.studentExplanation)
                                    .font(.subheadline)
                                    .fixedSize(horizontal: false, vertical: true)

                                Divider()

                                ExplanationSection(
                                    title: "What the app did",
                                    items: systemSteps(for: result)
                                )

                                ExplanationSection(
                                    title: "How the algorithm thinks",
                                    items: result.algorithm.logicSteps
                                )

                                ExplanationSection(
                                    title: "Why this Big-O happens",
                                    items: result.algorithm.growthSteps
                                )

                            }
                            .padding(.top, 8)
                        } label: {
                            HStack(alignment: .firstTextBaseline) {
                                Text("\(index + 1)")
                                    .font(.headline.monospacedDigit())
                                    .foregroundStyle(.secondary)
                                    .frame(width: 24, alignment: .leading)

                                VStack(alignment: .leading, spacing: 3) {
                                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                                        Text(result.algorithm.displayName)
                                            .font(.headline)
                                        Text(result.algorithm.bigOLabel)
                                            .font(.caption)
                                            .foregroundStyle(.blue)
                                    }
                                    Text(result.algorithm.explanation)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Text("\(result.operationCount) ops")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .monospacedDigit()
                            }
                        }
                        .padding(12)
                        .background(.quaternary, in: RoundedRectangle(cornerRadius: 10))
                        .accessibilityLabel("Rank \(index + 1), \(result.algorithm.displayName), \(result.algorithm.bigOLabel)")
                        .accessibilityValue("\(result.operationCount) measured operations. Expand for explanation.")
                    }
                }
            }

            Button {
                vm.raceAgain()
            } label: {
                Text("Race again")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .accessibilityHint("Returns to setup for another comparison")
        }
        .padding()
        .frame(maxWidth: 1100)
        .frame(maxWidth: .infinity)
    }

    /// Describes how the app produced and presented one measured result.
    private func systemSteps(for result: RaceResult) -> [String] {
        return [
            "The app creates an input list with n = \(inputN) items.",
            "It runs \(result.algorithm.displayName) for real, not as a fake animation.",
            "Every important comparison or array access adds to the operation counter.",
            "This run counted \(result.operationCount) operations.",
            "The race animation uses that count, so fewer operations usually means a faster racer."
        ]
    }
}

