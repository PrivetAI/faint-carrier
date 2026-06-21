import SwiftUI

// Tab 2 — the lore archive, the multiplier upgrades, and the prestige (Recalibrate) control.
struct ArchiveView: View {
    @EnvironmentObject var game: SignalGame
    @State private var showRecalibrateConfirm = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                upgradesSection
                prestigeSection
                loreSection
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background(SignalTheme.bg.edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
    }

    private var upgradesSection: some View {
        VStack(spacing: 10) {
            sectionTitle("Calibrations", "Permanent, additive boosts to all signal gain.")
            ForEach(SignalDefs.upgrades) { up in
                upgradeRow(up)
            }
        }
    }

    private func upgradeRow(_ up: UpgradeKind) -> some View {
        let owned = game.purchasedUpgrades.contains(up.id)
        let affordable = game.canBuyUpgrade(up)
        return Button(action: { game.buyUpgrade(up) }) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10).fill(SignalTheme.cardRaised).frame(width: 44, height: 44)
                    if owned {
                        CheckIcon(size: 24, color: SignalTheme.teal)
                    } else {
                        Text("+\(Int(up.bonus*100))%")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(affordable ? SignalTheme.accent : SignalTheme.textFaint)
                    }
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(up.name)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(SignalTheme.text)
                    Text(up.blurb)
                        .font(.system(size: 11, design: .rounded))
                        .foregroundColor(SignalTheme.textFaint)
                        .lineLimit(2)
                }
                Spacer()
                if !owned {
                    Text(SignalFormat.short(up.cost))
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(affordable ? SignalTheme.teal : SignalTheme.textFaint)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(SignalTheme.card)
                    .overlay(RoundedRectangle(cornerRadius: 12)
                        .stroke(owned ? SignalTheme.teal.opacity(0.4) : (affordable ? SignalTheme.accent.opacity(0.5) : SignalTheme.stroke.opacity(0.5)), lineWidth: 1))
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(owned || !affordable)
        .opacity(owned ? 0.85 : (affordable ? 1 : 0.7))
    }

    private var prestigeSection: some View {
        SignalCard {
            VStack(spacing: 10) {
                HStack {
                    Text("Recalibrate Array")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(SignalTheme.text)
                    Spacer()
                    Text("x\(game.recalibrations)")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(SignalTheme.violet)
                }
                Text("Reset Signal, dishes and calibrations — but keep every decoded fragment and gain permanent Resonance.")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(SignalTheme.textDim)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack {
                    Text("Resonance now: +\(Int(game.resonanceFromRecalibrations*100))%")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(SignalTheme.teal)
                    Spacer()
                    Text("Next: +\(Int(game.pendingResonanceGain*100))%")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(SignalTheme.amber)
                }

                if game.prestigeUnlocked {
                    Button(action: { showRecalibrateConfirm = true }) {
                        Text("Recalibrate")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(SignalTheme.bgDeep)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(RoundedRectangle(cornerRadius: 12).fill(SignalTheme.violet))
                    }
                    .buttonStyle(PlainButtonStyle())
                } else {
                    Text("Decode \(SignalDefs.prestigeUnlockLore) fragments to unlock (\(game.unlockedLore.count)/\(SignalDefs.prestigeUnlockLore)).")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(SignalTheme.textFaint)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .alert(isPresented: $showRecalibrateConfirm) {
            Alert(
                title: Text("Recalibrate the array?"),
                message: Text("Signal, dishes and calibrations reset. Fragments and Resonance are kept."),
                primaryButton: .destructive(Text("Recalibrate")) { game.recalibrate() },
                secondaryButton: .cancel()
            )
        }
    }

    private var loreSection: some View {
        VStack(spacing: 10) {
            sectionTitle("Archive of Sehl", "Each decode recovers one fragment, in order.")
            ForEach(SignalLore.fragments) { frag in
                loreRow(frag)
            }
        }
    }

    private func loreRow(_ frag: LoreFragment) -> some View {
        let unlocked = game.unlockedLore.contains(frag.id)
        return SignalCard {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    if unlocked {
                        ArchiveIcon(size: 18, color: SignalTheme.accent)
                    } else {
                        LockIcon(size: 18, color: SignalTheme.textFaint)
                    }
                    Text(unlocked ? frag.title : "Encrypted Fragment")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(unlocked ? SignalTheme.text : SignalTheme.textFaint)
                    Spacer()
                }
                Text(unlocked ? frag.body : "████ ███████ ██ ████ ████████ ███ █████ ██████████ ████ ███████.")
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(unlocked ? SignalTheme.textDim : SignalTheme.textFaint.opacity(0.6))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func sectionTitle(_ title: String, _ subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(SignalTheme.text)
            Text(subtitle)
                .font(.system(size: 12, design: .rounded))
                .foregroundColor(SignalTheme.textFaint)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
