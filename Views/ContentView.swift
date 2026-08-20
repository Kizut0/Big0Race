import SwiftUI

/// Root navigation host with shared motion, color, and matched-geometry context.
struct ContentView: View {
    @State private var vm = RaceViewModel()
    @Environment(\.colorScheme) private var colorScheme
    @Namespace private var screenNamespace

    var body: some View {
        Group {
            switch vm.screen {
            case .intro:   IntroView(vm: vm).matchedGeometryEffect(id: "screenSurface", in: screenNamespace)
            case .setup:   SetupView(vm: vm).matchedGeometryEffect(id: "screenSurface", in: screenNamespace)
            case .race:    RaceView(vm: vm).matchedGeometryEffect(id: "screenSurface", in: screenNamespace)
            case .reveal:  RevealView(vm: vm).matchedGeometryEffect(id: "screenSurface", in: screenNamespace)
            case .reflect: ReflectView(vm: vm).matchedGeometryEffect(id: "screenSurface", in: screenNamespace)
            }
        }
        .transition(.raceScreenDepth)
        .animation(AppMotion.navigation, value: vm.screen)
        .tint(AppPalette.accent)
        .background(AppPalette.background(for: colorScheme).ignoresSafeArea())
    }
}
