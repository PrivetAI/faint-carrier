import SwiftUI

// Tab 0 — the idle home: starfield, the dish you tap, live Signal readout, and the dish shop.
struct ObservatoryView: View {
    @EnvironmentObject var game: SignalGame
    @State private var pulse: Double = 0
    @State private var floats: [TapFloat] = []

    struct TapFloat: Identifiable {
        let id = UUID()
        let amount: Double
        let x: CGFloat
        var y: CGFloat
        var opacity: Double
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                counterCard
                dishStage
                shop
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background(SignalTheme.bg.edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
    }

    private var counterCard: some View {
        VStack(spacing: 4) {
            Text("SIGNAL")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .tracking(3)
                .foregroundColor(SignalTheme.textFaint)
            Text(SignalFormat.short(game.signal))
                .font(.system(size: 44, weight: .heavy, design: .rounded))
                .foregroundColor(SignalTheme.accent)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            Text(SignalFormat.rate(game.signalPerSecond))
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(SignalTheme.textDim)
            Text(SignalFormat.mult(game.globalMultiplier) + " gain")
                .font(.system(size: 12, design: .rounded))
                .foregroundColor(SignalTheme.teal.opacity(0.9))
                .padding(.top, 2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(SignalTheme.card)
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(SignalTheme.stroke.opacity(0.6), lineWidth: 1))
        )
    }

    private var dishStage: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(SignalTheme.bgDeep)
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(SignalTheme.stroke.opacity(0.5), lineWidth: 1))
            SignalStarfield(pulse: pulse)
                .clipShape(RoundedRectangle(cornerRadius: 18))
            // The tappable dish.
            DishIcon(size: 120, color: SignalTheme.accent)
                .scaleEffect(1 + 0.04 * pulse)
            // Floating tap rewards — clearly labelled so taps are never mistaken for passive gain.
            ForEach(floats) { f in
                Text("+\(SignalFormat.short(f.amount)) Signal")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(SignalTheme.teal)
                    .position(x: f.x, y: f.y)
                    .opacity(f.opacity)
            }
        }
        .frame(height: 240)
        .contentShape(Rectangle())
        // iOS 15 has no location-providing tap; a zero-distance drag gives the tap point.
        .gesture(DragGesture(minimumDistance: 0).onEnded { value in
            handleTap(at: value.location)
        })
        .overlay(
            Text("Tap the dish to amplify")
                .font(.system(size: 11, design: .rounded))
                .foregroundColor(SignalTheme.textFaint)
                .padding(8),
            alignment: .bottom
        )
    }

    private func handleTap(at location: CGPoint) {
        game.tapBoost()
        withAnimation(.easeOut(duration: 0.25)) { pulse = 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            withAnimation(.easeIn(duration: 0.35)) { pulse = 0 }
        }
        let f = TapFloat(amount: game.tapReward, x: location.x, y: location.y, opacity: 1)
        floats.append(f)
        if let idx = floats.firstIndex(where: { $0.id == f.id }) {
            withAnimation(.easeOut(duration: 0.9)) {
                floats[idx].y -= 60
                floats[idx].opacity = 0
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.95) {
            floats.removeAll { $0.id == f.id }
        }
    }

    private var shop: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Receivers")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(SignalTheme.text)
                Spacer()
            }
            ForEach(SignalDefs.dishes) { dish in
                dishRow(dish)
            }
        }
    }

    private func dishRow(_ dish: DishKind) -> some View {
        let owned = game.dishCounts[dish.id]
        let cost = game.dishCost(dish)
        let affordable = game.canBuyDish(dish)
        // Show a tier once the previous tier is owned (keeps early UI focused).
        let visible = dish.id == 0 || game.dishCounts[max(0, dish.id - 1)] > 0 || owned > 0
        return Group {
            if visible {
                Button(action: { game.buyDish(dish) }) {
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10).fill(SignalTheme.cardRaised)
                                .frame(width: 46, height: 46)
                            DishIcon(size: 28, color: affordable ? SignalTheme.accent : SignalTheme.textFaint)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            HStack {
                                Text(dish.name)
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                    .foregroundColor(SignalTheme.text)
                                Spacer()
                                Text("x\(owned)")
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundColor(SignalTheme.textDim)
                            }
                            Text(dish.blurb)
                                .font(.system(size: 11, design: .rounded))
                                .foregroundColor(SignalTheme.textFaint)
                                .lineLimit(1)
                            HStack(spacing: 6) {
                                Text(SignalFormat.short(cost) + " signal")
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundColor(affordable ? SignalTheme.teal : SignalTheme.textFaint)
                                Text("• +" + SignalFormat.rate(dish.baseRate * game.globalMultiplier))
                                    .font(.system(size: 11, design: .rounded))
                                    .foregroundColor(SignalTheme.textFaint)
                            }
                        }
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(SignalTheme.card)
                            .overlay(RoundedRectangle(cornerRadius: 12)
                                .stroke(affordable ? SignalTheme.accent.opacity(0.5) : SignalTheme.stroke.opacity(0.5), lineWidth: 1))
                    )
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(!affordable)
                .opacity(affordable ? 1 : 0.75)
            }
        }
    }
}
