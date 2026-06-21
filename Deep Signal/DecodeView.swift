import SwiftUI

// Tab 1 — spend accumulated Signal to run a decode: a small, always-winnable pattern-match.
// Success grants a permanent Insight multiplier and unlocks the next lore fragment.
struct DecodeView: View {
    @EnvironmentObject var game: SignalGame

    @State private var inPuzzle = false
    @State private var target: [Bool] = Array(repeating: false, count: 9)
    @State private var current: [Bool] = Array(repeating: false, count: 9)
    @State private var resultMessage: String? = nil
    @State private var unlockedTitle: String? = nil

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                statusCard
                if inPuzzle {
                    puzzleCard
                } else {
                    startCard
                }
                if let msg = resultMessage {
                    resultBanner(msg)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background(SignalTheme.bg.edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
    }

    private var statusCard: some View {
        SignalCard {
            VStack(spacing: 8) {
                SignalHeader(title: "Decode", subtitle: "Resolve a transmission into meaning.")
                HStack {
                    metric("Insight", SignalFormat.mult(game.insightMultiplier), SignalTheme.teal)
                    Divider().frame(height: 30).background(SignalTheme.stroke)
                    metric("Decoded", "\(game.decodeCount)", SignalTheme.accent)
                    Divider().frame(height: 30).background(SignalTheme.stroke)
                    metric("Fragments", "\(game.unlockedLore.count)/\(SignalLore.count)", SignalTheme.violet)
                }
                .padding(.top, 4)
            }
        }
    }

    private func metric(_ label: String, _ value: String, _ color: Color) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 11, design: .rounded))
                .foregroundColor(SignalTheme.textFaint)
        }
        .frame(maxWidth: .infinity)
    }

    private var startCard: some View {
        SignalCard {
            VStack(spacing: 14) {
                if game.allLoreDecoded {
                    Text("Every fragment recovered.")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(SignalTheme.text)
                    Text("The archive of Sehl is complete. Recalibrate the array in the Archive tab to carry its Resonance forward.")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(SignalTheme.textDim)
                        .multilineTextAlignment(.center)
                } else {
                    DecodeIcon(size: 64, color: SignalTheme.accent)
                    Text("Decode cost: " + SignalFormat.short(game.decodeCost) + " signal")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(game.canAffordDecode() ? SignalTheme.teal : SignalTheme.textFaint)
                    Button(action: startPuzzle) {
                        Text(game.canAffordDecode() ? "Begin Decode" : "Not Enough Signal")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(game.canAffordDecode() ? SignalTheme.bgDeep : SignalTheme.textFaint)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(RoundedRectangle(cornerRadius: 12)
                                .fill(game.canAffordDecode() ? SignalTheme.accent : SignalTheme.cardRaised))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(!game.canAffordDecode())
                }
            }
        }
    }

    private var puzzleCard: some View {
        SignalCard {
            VStack(spacing: 14) {
                Text("Match the carrier pattern")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(SignalTheme.text)

                HStack(alignment: .top, spacing: 22) {
                    VStack(spacing: 6) {
                        miniGrid(target, interactive: false, size: 26)
                        Text("Target")
                            .font(.system(size: 11, design: .rounded))
                            .foregroundColor(SignalTheme.textFaint)
                    }
                    VStack(spacing: 6) {
                        miniGrid(current, interactive: true, size: 40)
                        Text("Tap to tune")
                            .font(.system(size: 11, design: .rounded))
                            .foregroundColor(SignalTheme.textFaint)
                    }
                }

                if current == target {
                    Button(action: confirmDecode) {
                        Text("Lock Signal")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(SignalTheme.bgDeep)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(RoundedRectangle(cornerRadius: 12).fill(SignalTheme.teal))
                    }
                    .buttonStyle(PlainButtonStyle())
                } else {
                    Button(action: cancelPuzzle) {
                        Text("Abort (refund)")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(SignalTheme.textDim)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 11)
                            .background(RoundedRectangle(cornerRadius: 12).stroke(SignalTheme.stroke, lineWidth: 1))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }

    private func miniGrid(_ cells: [Bool], interactive: Bool, size: CGFloat) -> some View {
        VStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { row in
                HStack(spacing: 4) {
                    ForEach(0..<3, id: \.self) { col in
                        let idx = row*3 + col
                        RoundedRectangle(cornerRadius: 6)
                            .fill(cells[idx] ? SignalTheme.accent : SignalTheme.cardRaised)
                            .frame(width: size, height: size)
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(SignalTheme.stroke.opacity(0.6), lineWidth: 1))
                            .onTapGesture {
                                if interactive { current[idx].toggle() }
                            }
                    }
                }
            }
        }
    }

    private func resultBanner(_ msg: String) -> some View {
        SignalCard {
            VStack(spacing: 6) {
                Text(msg)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(SignalTheme.teal)
                if let title = unlockedTitle {
                    Text("New fragment: \(title)")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(SignalTheme.textDim)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: Logic

    private func startPuzzle() {
        guard game.payForDecode() else { return }
        resultMessage = nil
        unlockedTitle = nil
        // Generate a non-trivial target (at least 2 lit, not all), seeded by progress so it varies.
        var t = Array(repeating: false, count: 9)
        let seedBase = game.decodeCount * 7 + 3
        var lit = 0
        for i in 0..<9 {
            let on = ((seedBase &* (i + 1)) % 5) >= 3
            t[i] = on
            if on { lit += 1 }
        }
        if lit < 2 { t[0] = true; t[4] = true; t[8] = true }
        if lit == 9 { t[1] = false }
        target = t
        current = Array(repeating: false, count: 9)
        inPuzzle = true
    }

    private func confirmDecode() {
        let unlocked = game.completeDecode()
        if let idx = unlocked, idx < SignalLore.count {
            unlockedTitle = SignalLore.fragments[idx].title
        } else {
            unlockedTitle = nil
        }
        resultMessage = "Decode locked. Insight raised to " + SignalFormat.mult(game.insightMultiplier) + "."
        inPuzzle = false
    }

    private func cancelPuzzle() {
        // Refund the decode cost the player paid to start.
        game.signal += game.decodeCost
        inPuzzle = false
        resultMessage = nil
    }
}
