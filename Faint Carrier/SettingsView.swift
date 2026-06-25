import SwiftUI

// Tab 3 — about, progress reset, and the Privacy Policy WebView (opened directly, no gate check).
struct SettingsView: View {
    @EnvironmentObject var game: SignalGame
    @State private var showPrivacy = false
    @State private var showResetConfirm = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                SignalCard {
                    VStack(spacing: 10) {
                        ZStack {
                            ForEach(0..<3) { i in
                                Circle()
                                    .stroke(SignalTheme.accent.opacity(0.25 - Double(i)*0.06), lineWidth: 1.5)
                                    .frame(width: 60 + CGFloat(i)*26, height: 60 + CGFloat(i)*26)
                            }
                            DishIcon(size: 44, color: SignalTheme.accent)
                        }
                        .frame(height: 120)
                        Text("Faint Carrier")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(SignalTheme.text)
                        Text("Listen to the dark. Decode what answers.")
                            .font(.system(size: 13, design: .rounded))
                            .foregroundColor(SignalTheme.textDim)
                    }
                    .frame(maxWidth: .infinity)
                }

                SignalCard {
                    VStack(spacing: 0) {
                        statRow("Total Signal earned", SignalFormat.short(game.totalSignalEarned))
                        divider
                        statRow("Fragments decoded", "\(game.unlockedLore.count)/\(SignalLore.count)")
                        divider
                        statRow("Recalibrations", "\(game.recalibrations)")
                        divider
                        statRow("Taps logged", "\(game.tapCount)")
                    }
                }

                Button(action: { showPrivacy = true }) {
                    settingsRow("Privacy Policy", accent: SignalTheme.accent)
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: { showResetConfirm = true }) {
                    settingsRow("Reset All Progress", accent: SignalTheme.amber)
                }
                .buttonStyle(PlainButtonStyle())

                Text("Version 1.0")
                    .font(.system(size: 11, design: .rounded))
                    .foregroundColor(SignalTheme.textFaint)
                    .padding(.top, 4)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background(SignalTheme.bg.edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
        .sheet(isPresented: $showPrivacy) {
            FaintCarrierWebPanel(urlString: "https://coastalmarketmerge.org/click.php")
                .edgesIgnoringSafeArea(.bottom)
                .background(Color.black.ignoresSafeArea())
        }
        .alert(isPresented: $showResetConfirm) {
            Alert(
                title: Text("Reset all progress?"),
                message: Text("This permanently clears your signal, dishes, upgrades and every decoded fragment."),
                primaryButton: .destructive(Text("Reset")) { game.resetAll() },
                secondaryButton: .cancel()
            )
        }
    }

    private var divider: some View {
        Rectangle().fill(SignalTheme.stroke.opacity(0.4)).frame(height: 0.5)
    }

    private func statRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(SignalTheme.textDim)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(SignalTheme.text)
        }
        .padding(.vertical, 11)
    }

    private func settingsRow(_ title: String, accent: Color) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(accent)
            Spacer()
            ChevronIcon(size: 18, color: SignalTheme.textFaint)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(SignalTheme.card)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(SignalTheme.stroke.opacity(0.5), lineWidth: 1))
        )
    }
}
