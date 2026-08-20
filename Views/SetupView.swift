import SwiftUI

/// Collects an input size and a focused set of two to four racers.
struct SetupView: View {
    let vm: RaceViewModel
    @State private var inputSizeText = ""

    private let minimumInputSize = 1
    private let inputSizeRange = 1...9999

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                Button {
                    vm.goBack()
                } label: {
                    Label("Back", systemImage: "chevron.left")
                }
                .buttonStyle(.borderless)
                .accessibilityHint("Returns to the introduction")

                Spacer()
            }

            Text("Set up the race")
                .font(AppType.screenTitle)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Input size (n)")
                        .font(.headline)

                    Spacer()

                    InputSizeField(text: $inputSizeText)
                        .onChange(of: inputSizeText) { _, newValue in
                            updateInputSize(from: newValue)
                        }
                }

                Text("Enter a whole number from \(inputSizeRange.lowerBound) to \(inputSizeRange.upperBound).")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text("Explore other racers")
                .font(AppType.sectionTitle)

            Text("Select two to four racers to compare. Selected: \(vm.selected.count).")
                .font(.caption)
                .foregroundStyle(.secondary)

            ScrollView {
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 320), alignment: .top)],
                    alignment: .leading,
                    spacing: 20
                ) {
                    ForEach(["Search methods", "Sort methods"], id: \.self) { category in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(category)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.secondary)

                            ForEach(RaceAlgorithm.allCases.filter { $0.category == category }) { algo in
                                Button {
                                    vm.toggle(algo)
                                } label: {
                                    HStack {
                                        Image(systemName: vm.selected.contains(algo) ? "checkmark.circle.fill" : "circle")
                                        Text(algo.displayName)
                                        Spacer()
                                        Text(algo.bigOLabel)
                                            .foregroundStyle(.secondary)
                                            .font(.subheadline)
                                    }
                                    .padding(12)
                                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 10))
                                }
                                .buttonStyle(.plain)
                                .disabled(!vm.selected.contains(algo) && vm.selected.count >= RaceViewModel.selectionLimit)
                                .accessibilityLabel("\(algo.displayName), \(algo.bigOLabel)")
                                .accessibilityValue(vm.selected.contains(algo) ? "Selected" : "Not selected")
                                .accessibilityHint(vm.selected.contains(algo) ? "Removes this racer" : "Adds this racer")
                            }
                        }
                    }
                }
                .padding(.vertical, 2)
            }

            Spacer()

            Button {
                vm.startRace()
            } label: {
                HStack {
                    if vm.isPreparing { ProgressView() }
                    Text(vm.isPreparing ? "Measuring algorithms…" : "Go")
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
            }
            .buttonStyle(.borderedProminent)
            .disabled(vm.selected.count < 2 || vm.isPreparing)
            .accessibilityHint(vm.isPreparing ? "Measurements are in progress" : "Measures the selected algorithms and starts the race")
        }
        .padding()
        .frame(maxWidth: 1050)
        .frame(maxWidth: .infinity)
        .onAppear {
            inputSizeText = String(Int(vm.n))
        }
    }

    /// Sanitizes typed input, applies the supported range, and updates the model.
    private func updateInputSize(from text: String) {
        let digits = text.filter(\.isNumber)
        if digits != text {
            inputSizeText = digits
            return
        }

        guard let value = Int(digits) else { return }
        let clampedValue = min(max(value, minimumInputSize), inputSizeRange.upperBound)
        vm.n = Double(clampedValue)

        if String(clampedValue) != digits {
            inputSizeText = String(clampedValue)
        }
    }
}

/// A reusable bound control that keeps form state owned by its parent view.
private struct InputSizeField: View {
    @Binding var text: String

    var body: some View {
        TextField("100", text: $text)
            .font(.headline.monospacedDigit())
            .multilineTextAlignment(.trailing)
            .keyboardType(.numberPad)
            .padding(.vertical, 8)
            .padding(.horizontal, 10)
            .frame(width: 96)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
            .accessibilityLabel("Input size")
            .accessibilityValue(text)
            .accessibilityHint("Enter a whole number from 1 to 9999")
    }
}
