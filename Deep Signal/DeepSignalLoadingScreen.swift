import SwiftUI

// Splash shown while the launch check runs.
struct DeepSignalLoadingScreen: View {
    @State private var signalPulse = false

    var body: some View {
        ZStack {
            SignalTheme.bg.edgesIgnoringSafeArea(.all)

            VStack(spacing: 26) {
                ZStack {
                    // Pulsing rings around the dish mark.
                    ForEach(0..<3) { i in
                        Circle()
                            .stroke(SignalTheme.accent.opacity(0.35 - Double(i)*0.1), lineWidth: 2)
                            .frame(width: 90 + CGFloat(i)*36, height: 90 + CGFloat(i)*36)
                            .scaleEffect(signalPulse ? 1.12 : 0.92)
                            .animation(
                                Animation.easeInOut(duration: 1.4)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(i) * 0.18),
                                value: signalPulse
                            )
                    }
                    DishIcon(size: 64, color: SignalTheme.accent)
                }
                .frame(height: 170)

                Text("Deep Signal")
                    .font(.system(size: 26, weight: .semibold, design: .rounded))
                    .foregroundColor(SignalTheme.text)
                    .tracking(2)

                Text("Listening to the dark...")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(SignalTheme.textDim)
            }
        }
        .onAppear { signalPulse = true }
    }
}
