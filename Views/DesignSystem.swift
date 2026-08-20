import SwiftUI

/// One Dynamic-Type-aware hierarchy shared by every screen.
enum AppType {
    static let hero = Font.system(.largeTitle, design: .rounded, weight: .bold)
    static let screenTitle = Font.system(.title2, design: .rounded, weight: .semibold)
    static let sectionTitle = Font.system(.headline, design: .rounded, weight: .semibold)
    static let body = Font.system(.body, design: .rounded)
    static let supporting = Font.system(.subheadline, design: .rounded)
    static let detail = Font.system(.caption, design: .rounded)
    static let data = Font.system(.caption, design: .monospaced, weight: .medium)
}

/// Bespoke motion curves tuned for navigation, continuous race progress, and bars.
enum AppMotion {
    static let navigation = Animation.spring(response: 0.52, dampingFraction: 0.82, blendDuration: 0.12)
    static let raceProgress = Animation.interpolatingSpring(mass: 0.38, stiffness: 185, damping: 30, initialVelocity: 0.12)
    static let bars = Animation.spring(response: 0.24, dampingFraction: 0.74, blendDuration: 0.08)
}

/// Explicit adaptive colors keep hierarchy intentional in both appearances.
enum AppPalette {
    static let accent = Color.orange

    /// Returns the app-wide background color for the active appearance.
    static func background(for scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 0.035, green: 0.047, blue: 0.075)
            : Color(red: 0.965, green: 0.972, blue: 0.985)
    }

    /// Returns the dark teaching-canvas color used behind animated bars.
    static func visualizationCanvas(for scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 0.015, green: 0.025, blue: 0.055)
            : Color(red: 0.055, green: 0.075, blue: 0.12)
    }
}

private struct ScreenDepthModifier: ViewModifier {
    let isActive: Bool
    let direction: CGFloat

    /// Applies the blur, depth, and directional movement used during navigation.
    func body(content: Content) -> some View {
        content
            .opacity(isActive ? 0 : 1)
            .scaleEffect(isActive ? 0.94 : 1)
            .offset(x: isActive ? direction * 72 : 0)
            .blur(radius: isActive ? 8 : 0)
            .rotation3DEffect(
                .degrees(isActive ? Double(direction) * 4 : 0),
                axis: (x: 0, y: 1, z: 0),
                perspective: 0.7
            )
    }
}

extension AnyTransition {
    static var raceScreenDepth: AnyTransition {
        .asymmetric(
            insertion: .modifier(
                active: ScreenDepthModifier(isActive: true, direction: 1),
                identity: ScreenDepthModifier(isActive: false, direction: 1)
            ),
            removal: .modifier(
                active: ScreenDepthModifier(isActive: true, direction: -1),
                identity: ScreenDepthModifier(isActive: false, direction: -1)
            )
        )
    }
}
