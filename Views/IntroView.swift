import SwiftUI

/// Opening story that invites learners to choose an algorithm comparison.
struct IntroView: View {
    let vm: RaceViewModel

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Text("Which one wins?")
                .font(AppType.hero)
                .multilineTextAlignment(.center)
            Text("Choose search or sorting methods, compare their performance, and explore why the results.")
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .accessibilityLabel("Choose search or sorting methods, compare their performance, and explore why the results.")
            Spacer()
            Button {
                withAnimation(AppMotion.navigation) {
                    vm.goToSetup()
                }
            } label: {
                Text("Start race")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .accessibilityHint("Opens race setup")
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
        .padding()
        .frame(maxWidth: 720)
        .frame(maxWidth: .infinity)
    }
}
