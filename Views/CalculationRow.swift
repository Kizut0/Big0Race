import SwiftUI

/// Displays measured and estimated work with optional step-by-step details.
struct CalculationRow: View {
    let name: String
    let bigO: String
    let formula: String
    let theory: String
    let calculation: String
    let steps: [String]
    let value: Double
    let measured: Int
    @State private var isExpanded = false

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            VStack(alignment: .leading, spacing: 8) {
                Text(theory)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(calculation)
                    .font(.caption)

                VStack(alignment: .leading, spacing: 5) {
                    ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                        HStack(alignment: .top, spacing: 6) {
                            Text("\(index + 1).")
                                .font(.caption.monospacedDigit())
                                .foregroundStyle(.secondary)
                                .frame(width: 20, alignment: .trailing)
                            Text(step)
                                .font(.caption)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }

                Text("Formula: \(formula)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 8)
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline) {
                    Text(name)
                        .font(.subheadline.weight(.semibold))
                    Text(bigO)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(measured.formatted()) ops")
                        .font(.subheadline.weight(.semibold).monospacedDigit())
                }

                Text("Big-O estimate: \(format(value)) operations")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(10)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
        .accessibilityHint(isExpanded ? "Collapses the calculation" : "Expands the calculation")
    }

    /// Formats the estimate displayed in this expandable calculation row.
    private func format(_ value: Double) -> String {
        if value >= 100 {
            return String(format: "%.0f", value)
        }
        if value >= 10 {
            return String(format: "%.1f", value)
        }
        return String(format: "%.2f", value)
    }
}
