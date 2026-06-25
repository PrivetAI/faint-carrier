import SwiftUI

// All icons are pure SwiftUI Shapes / Canvas — no SF Symbols, no emoji.

// Tab: Observatory — a radio dish silhouette.
struct DishIcon: View {
    var size: CGFloat
    var color: Color
    var body: some View {
        Canvas { ctx, sz in
            let w = sz.width, h = sz.height
            // Bowl
            var bowl = Path()
            bowl.addEllipse(in: CGRect(x: w*0.10, y: h*0.18, width: w*0.80, height: h*0.40))
            ctx.stroke(bowl, with: .color(color), lineWidth: max(1.4, w*0.07))
            // Feed arm
            var arm = Path()
            arm.move(to: CGPoint(x: w*0.50, y: h*0.38))
            arm.addLine(to: CGPoint(x: w*0.50, y: h*0.74))
            ctx.stroke(arm, with: .color(color), lineWidth: max(1.4, w*0.07))
            // receiver
            var rec = Path()
            rec.addEllipse(in: CGRect(x: w*0.43, y: h*0.32, width: w*0.14, height: w*0.14))
            ctx.fill(rec, with: .color(color))
            // base
            var base = Path()
            base.move(to: CGPoint(x: w*0.34, y: h*0.86))
            base.addLine(to: CGPoint(x: w*0.66, y: h*0.86))
            ctx.stroke(base, with: .color(color), lineWidth: max(1.4, w*0.07))
        }
        .frame(width: size, height: size)
    }
}

// Tab: Decode — overlapping waveform pulse.
struct DecodeIcon: View {
    var size: CGFloat
    var color: Color
    var body: some View {
        Canvas { ctx, sz in
            let w = sz.width, h = sz.height
            var p = Path()
            let mid = h*0.5
            p.move(to: CGPoint(x: w*0.06, y: mid))
            p.addLine(to: CGPoint(x: w*0.24, y: mid))
            p.addLine(to: CGPoint(x: w*0.34, y: h*0.16))
            p.addLine(to: CGPoint(x: w*0.46, y: h*0.86))
            p.addLine(to: CGPoint(x: w*0.58, y: h*0.30))
            p.addLine(to: CGPoint(x: w*0.68, y: mid))
            p.addLine(to: CGPoint(x: w*0.94, y: mid))
            ctx.stroke(p, with: .color(color), lineWidth: max(1.4, w*0.07))
        }
        .frame(width: size, height: size)
    }
}

// Tab: Archive — stacked fragments.
struct ArchiveIcon: View {
    var size: CGFloat
    var color: Color
    var body: some View {
        Canvas { ctx, sz in
            let w = sz.width, h = sz.height
            let lw = max(1.4, w*0.07)
            for i in 0..<3 {
                let y = h*0.24 + CGFloat(i)*h*0.24
                let r = Path(roundedRect: CGRect(x: w*0.18, y: y, width: w*0.64, height: h*0.16), cornerRadius: w*0.04)
                ctx.stroke(r, with: .color(color), lineWidth: lw)
            }
        }
        .frame(width: size, height: size)
    }
}

// Tab: Settings — a gear approximated with a ring + teeth (no SF Symbol).
struct GearIcon: View {
    var size: CGFloat
    var color: Color
    var body: some View {
        Canvas { ctx, sz in
            let w = sz.width, h = sz.height
            let cx = w/2, cy = h/2
            let rOuter = w*0.36, rInner = w*0.20
            let teeth = 8
            var ring = Path()
            ring.addEllipse(in: CGRect(x: cx - rInner, y: cy - rInner, width: rInner*2, height: rInner*2))
            ctx.stroke(ring, with: .color(color), lineWidth: max(1.4, w*0.07))
            for i in 0..<teeth {
                let a = Double(i) / Double(teeth) * 2 * Double.pi
                var t = Path()
                t.move(to: CGPoint(x: cx + CGFloat(cos(a))*rInner, y: cy + CGFloat(sin(a))*rInner))
                t.addLine(to: CGPoint(x: cx + CGFloat(cos(a))*rOuter, y: cy + CGFloat(sin(a))*rOuter))
                ctx.stroke(t, with: .color(color), lineWidth: max(1.4, w*0.08))
            }
        }
        .frame(width: size, height: size)
    }
}

// A simple chevron used for list disclosure.
struct ChevronIcon: View {
    var size: CGFloat
    var color: Color
    var body: some View {
        Canvas { ctx, sz in
            let w = sz.width, h = sz.height
            var p = Path()
            p.move(to: CGPoint(x: w*0.35, y: h*0.22))
            p.addLine(to: CGPoint(x: w*0.65, y: h*0.5))
            p.addLine(to: CGPoint(x: w*0.35, y: h*0.78))
            ctx.stroke(p, with: .color(color), lineWidth: max(1.2, w*0.10))
        }
        .frame(width: size, height: size)
    }
}

// A lock glyph for encrypted lore.
struct LockIcon: View {
    var size: CGFloat
    var color: Color
    var body: some View {
        Canvas { ctx, sz in
            let w = sz.width, h = sz.height
            let lockBody = Path(roundedRect: CGRect(x: w*0.24, y: h*0.44, width: w*0.52, height: h*0.40), cornerRadius: w*0.06)
            ctx.fill(lockBody, with: .color(color.opacity(0.9)))
            var shackle = Path()
            shackle.addArc(center: CGPoint(x: w*0.5, y: h*0.44),
                           radius: w*0.16, startAngle: .degrees(180), endAngle: .degrees(360), clockwise: false)
            ctx.stroke(shackle, with: .color(color.opacity(0.9)), lineWidth: max(1.4, w*0.07))
        }
        .frame(width: size, height: size)
    }
}

// A small checkmark for owned upgrades.
struct CheckIcon: View {
    var size: CGFloat
    var color: Color
    var body: some View {
        Canvas { ctx, sz in
            let w = sz.width, h = sz.height
            var p = Path()
            p.move(to: CGPoint(x: w*0.22, y: h*0.54))
            p.addLine(to: CGPoint(x: w*0.42, y: h*0.74))
            p.addLine(to: CGPoint(x: w*0.80, y: h*0.28))
            ctx.stroke(p, with: .color(color), lineWidth: max(1.6, w*0.12))
        }
        .frame(width: size, height: size)
    }
}
