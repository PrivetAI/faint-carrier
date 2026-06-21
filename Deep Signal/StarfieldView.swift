import SwiftUI

// Animated starfield + signal rings emanating from the dish focus.
// Per the canvas-size pitfall: we use a TimelineView for animation and rely on the
// canvas's own local `size` ONLY for self-contained drawing (no parent-camera math here),
// so divergence between closure size and parent geometry can't push content off-screen.
struct SignalStarfield: View {
    var pulse: Double  // 0..1 animated externally to widen rings on activity

    // Deterministic star layout so it doesn't shimmer randomly every frame.
    private static let stars: [(x: Double, y: Double, r: Double, a: Double, tw: Double)] = {
        var seed: UInt64 = 0xD1B54A32D192ED03
        func rnd() -> Double {
            seed ^= seed << 13; seed ^= seed >> 7; seed ^= seed << 17
            return Double(seed % 1_000_000) / 1_000_000.0
        }
        var arr: [(Double, Double, Double, Double, Double)] = []
        for _ in 0..<90 {
            arr.append((rnd(), rnd(), 0.4 + rnd()*1.6, 0.2 + rnd()*0.6, rnd()))
        }
        return arr
    }()

    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            Canvas { ctx, size in
                let w = size.width, h = size.height

                // Stars with gentle twinkle.
                for s in Self.stars {
                    let twinkle = 0.5 + 0.5 * sin(t * 1.2 + s.tw * 6.28)
                    let alpha = s.a * (0.5 + 0.5 * twinkle)
                    let rect = CGRect(x: s.x * w, y: s.y * h, width: s.r*2, height: s.r*2)
                    var p = Path()
                    p.addEllipse(in: rect)
                    ctx.fill(p, with: .color(SignalTheme.accent.opacity(alpha * 0.8)))
                }

                // Expanding signal rings from upper focus point.
                let focus = CGPoint(x: w*0.5, y: h*0.42)
                let maxR = max(w, h) * 0.7
                let ringCount = 4
                for i in 0..<ringCount {
                    let phase = (t * 0.25 + Double(i) / Double(ringCount)).truncatingRemainder(dividingBy: 1.0)
                    let r = phase * maxR
                    let fade = (1.0 - phase) * (0.35 + 0.4 * pulse)
                    var ring = Path()
                    ring.addEllipse(in: CGRect(x: focus.x - r, y: focus.y - r, width: r*2, height: r*2))
                    ctx.stroke(ring, with: .color(SignalTheme.accent.opacity(max(0, fade))), lineWidth: 1.5)
                }
            }
        }
    }
}
