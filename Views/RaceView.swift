import SwiftUI

/// Composes the race screen from measured results and presentation components.
/// Algorithm measurement and visualization heuristics intentionally live outside
/// this screen-level view.
struct RaceView: View {
    let vm: RaceViewModel
    @State private var bars: [Double] = Self.makeBars(count: 72)
    @State private var scrubProgress = 1.0

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Button { vm.goBack() } label: {
                    Label("Back", systemImage: "chevron.left")
                }
                .buttonStyle(.borderless)
                .accessibilityHint("Returns to race setup")
                Spacer()
            }

            Text("Racing with n = \(Int(vm.n))")
                .font(AppType.screenTitle)

            Label(
                "Stylized simulation — paced by real, log-compressed operation counts; not a literal operation replay.",
                systemImage: "info.circle"
            )
                .font(AppType.detail)
                .foregroundStyle(.secondary)

            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 340), spacing: 14)], spacing: 14) {
                    ForEach(vm.results) { result in
                        AlgorithmRacePanel(
                            result: result,
                            progress: vm.isRacing ? (vm.progress[result.algorithm] ?? 0) : scrubProgress,
                            place: vm.finishedOrder.firstIndex(of: result.algorithm).map { ordinal($0 + 1) },
                            bars: bars,
                            isRacing: vm.isRacing
                        )
                    }
                }
                .padding(.vertical, 2)
            }

            RaceScrubber(progress: $scrubProgress)
                .disabled(vm.isRacing)
                .opacity(vm.isRacing ? 0.55 : 1)

            HStack(spacing: 12) {
                Button {
                    bars = Self.makeBars(count: 72)
                    scrubProgress = 0
                    vm.replayRace()
                } label: {
                    Label("Replay", systemImage: "arrow.clockwise")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.bordered)
                .disabled(vm.isRacing)
                .accessibilityHint("Replays the same measured results")

                Button { vm.goToReveal() } label: {
                    Text(vm.isRacing ? "Racing…" : "See why")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .disabled(vm.isRacing)
                .accessibilityHint("Opens the theoretical and measured operation chart")
            }
            .font(.headline)
        }
        .padding()
        .frame(maxWidth: 1200)
        .frame(maxWidth: .infinity)
        .animation(AppMotion.raceProgress, value: vm.progress)
        .onAppear { bars = Self.makeBars(count: 72) }
        .onChange(of: vm.isRacing) { wasRacing, isRacing in
            guard wasRacing, !isRacing else { return }
            withAnimation(AppMotion.bars) {
                scrubProgress = 1
            }
        }
    }

    /// Creates the fixed-size teaching dataset used by every visual race panel.
    private static func makeBars(count: Int) -> [Double] {
        (0..<count).map { index in
            let wave = sin(Double(index) * 0.47) * 0.18
            let noise = Double.random(in: 0.0...0.52)
            return min(max(0.08 + wave + noise, 0.06), 1.0)
        }
    }

    /// Converts a finishing position into a compact ordinal such as `1st`.
    private func ordinal(_ number: Int) -> String {
        switch number {
        case 1: return "1st"
        case 2: return "2nd"
        case 3: return "3rd"
        default: return "\(number)th"
        }
    }
}

/// A draggable timeline for exploring every algorithm at the same race moment.
private struct RaceScrubber: View {
    @Binding var progress: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack {
                Label("Explore the race", systemImage: "hand.draw")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            GeometryReader { geometry in
                let width = max(geometry.size.width, 1)

                ZStack(alignment: .leading) {
                    Capsule().fill(.quaternary)
                    Capsule()
                        .fill(AppPalette.accent.gradient)
                        .frame(width: width * progress)
                    Circle()
                        .fill(.white)
                        .shadow(color: .black.opacity(0.22), radius: 3, y: 1)
                        .overlay(Circle().stroke(AppPalette.accent, lineWidth: 3))
                        .frame(width: 28, height: 28)
                        .offset(x: max(0, min(width - 28, width * progress - 14)))
                }
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { gesture in
                            progress = min(max(gesture.location.x / width, 0), 1)
                        }
                        .onEnded { gesture in
                            let rawValue = min(max(gesture.location.x / width, 0), 1)
                            withAnimation(AppMotion.bars) {
                                progress = (rawValue * 20).rounded() / 20
                            }
                        }
                )
            }
            .frame(height: 28)

            Text("Drag to inspect how every algorithm changes from start to finish.")
                .font(AppType.detail)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Race progress timeline")
        .accessibilityValue("\(Int(progress * 100)) percent")
        .accessibilityHint("Drag left or right to explore the race")
        .accessibilityAdjustableAction { direction in
            withAnimation(AppMotion.bars) {
                switch direction {
                case .increment: progress = min(1, progress + 0.05)
                case .decrement: progress = max(0, progress - 0.05)
                @unknown default: break
                }
            }
        }
    }
}
